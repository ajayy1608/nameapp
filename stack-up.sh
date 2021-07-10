#Install docker
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
sg docker -c "docker info"

#Install kubectl cli
echo "Installing kubectl"
[ -s /usr/local/bin/kubectl ] || (curl -s -o /tmp/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.20.4/2021-04-12/bin/linux/amd64/kubectl && \
chmod +x /tmp/kubectl && sudo mv /tmp/kubectl /usr/local/bin)
kubectl version

#Install helm
echo "Installing Helm-3"
[ -s /usr/local/bin/helm ] || curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version

#Install k3d
echo "Installing k3d"
[ -s /usr/local/bin/k3d ] || curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
k3d version

#Create a kubernetes cluster
echo "Creating kubernetes cluster"
sg docker -c "k3d cluster create tarabut -s 1 -a 1 --no-lb"

#Apply the manifest files
helm repo add stable https://charts.helm.sh/stable
helm install external-nginx-ingress stable/nginx-ingress --namespace kube-system \
   --set controller.extraArgs.publish-service=kube-system/external-nginx-ingress-controller \
   --set controller.replicaCount=1 \
   --set controller.service.type=NodePort

#Get Image Tag to deploy
echo "Enter tag to deploy (created using github actions ex. pr-1) or press enter to use default"
read TAG
DOCKERHUB_TAG=${TAG:-v1}

sed -i "s/DOCKERHUB_TAG/$DOCKERHUB_TAG/" kubernetes/deployment.yaml
kubectl apply -f kubernetes/
echo "waiting 30 seconds"
sleep 30

#Hit the endpoint
NODE_IP=$(kubectl --namespace kube-system get nodes -o jsonpath="{.items[0].status.addresses[0].address}")
NODE_PORT=$(kubectl --namespace kube-system get services -o jsonpath="{.spec.ports[0].nodePort}" external-nginx-ingress-controller)
curl -H "host:nameapp.tarabut.com" http://${NODE_IP}:${NODE_PORT}/name