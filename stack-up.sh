#Install docker
sudo yum update -y
sudo amazon-linux-extras install docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
newgrp docker
docker info

#Build Image
read DOCKERHUB_REPO
docker build -t $DOCKERHUB_REPO/nameapp:v1 .
docker login
docker push $DOCKERHUB_REPO/nameapp:v1

#Install kubectl cli
curl -o /tmp/kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.20.4/2021-04-12/bin/linux/amd64/kubectl
chmod +x /tmp/kubectl
sudo mv /tmp/kubectl /usr/local/bin

#Install helm
curl -o /tmp/helm https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

#Install k3d
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

#Create a kubernetes cluster
k3d cluster create tarabut -s 1 -a 1

#Apply the manifest files
helm repo add stable https://charts.helm.sh/stable
helm install external-nginx-ingress stable/nginx-ingress --namespace kube-system \
   --set controller.extraArgs.publish-service=kube-system/external-nginx-ingress-controller \
   --set controller.replicaCount=1 \
   --set controller.service.type=NodePort
sed -i "s/DOCKERHUB_REPO/$DOCKERHUB_REPO" kubernetes/deployment.yaml
kubectl apply -f kubernetes/

#Hit the endpoint
