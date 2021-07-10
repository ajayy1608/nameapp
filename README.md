# nameapp

Tools & Technologies used
=======
 - AWS: For providing the infrastructure
 - Bash: To write automation in a simple form
 - Kubernetes: As the orchestration layer to manage workloads (used k3d to prepare purgeable environment)
 - Docker: For building and sharing containerized application
 - Helm: Supplemental kubernetes tool to create/share configurable k-native applications

What does the repo contains
=======
 - A Dockerfile: which is used to build an image using github actions.
 - The `nameapp.py` application exposing `/name` endpoint which when hit return a string in predefined format.
 - Bunch of manifest files to deploy the application and make it available for users
 - A shell script `stack-up.sh` to automate environment creation and deploying the application.

How it works
=======
Whenever a PR is raised with changes in either `Dockerfile` or `nameapp.py`, the github action workflow is triggered to build and push the image to set repository with custom tags.

Once the tag is built and pushed you just need to run `stack-up.sh` on any machine running on amazon-linux-2 (as some installation commands are specific to that but can be generalized if required).

The `stack-up.sh` performs below tasks:
- Prepares the environment by installing tools like docker, helm, k3d and kubectl cli.
- Creates a purgeable kubernetes cluster with single master and single worker.
- Deploys nginx-ingress-controller using helm.
- Deploys all the manifests to bring up the application.
- Hits the application through ingress (using the nodeport type nginx-ingress-controller service).