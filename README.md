# nameapp

This is a very simple application exposing just one endpoint `/name` which responds with a message of the format `30/07/2021 12:00 Hello TG, your password is 1234` consisting of current date-time, a custom name and a password made available to it through environment variables. The application is deployed on a kubernetes cluster and will be accessible through a custom domain defined by the associated Ingress object.

Tools & Technologies used
=======
 - AWS: For providing the infrastructure
 - Bash: To write automation in a simple form
 - Kubernetes (1.21): As the orchestration layer to manage workloads
 - k3d (4.4.7): To prepare purgeable kubernetes cluster
 - Docker (20.10.4): For building and sharing containerized application
 - Helm (3.6.2): Supplemental kubernetes tool to create/share configurable k-native applications

What does the repo contains
=======
 - A Dockerfile: which is used to build an image using github actions.
 - The `nameapp.py` application exposing `/name` endpoint which when hit return a string in predefined format.
 - Bunch of manifest files to deploy the application and make it available for users.
 - A shell script `stack-up.sh` to automate environment creation and deploying the application.

How it works
=======
Whenever a PR is raised with changes in either `Dockerfile` or `nameapp.py`, the github action workflow is triggered to build and push the image to set repository with custom tags.

Once the tag is built and pushed you just need to run `stack-up.sh` on any machine running on amazon-linux-2 (as some installation commands are specific to that but can be generalized if required, used a t3.xlarge machine running ami-00f22f6155d6d92c5 in eu-central-1 for testing here).

The `stack-up.sh` performs below tasks:
- Prepares the environment by installing tools like docker, helm, k3d and kubectl cli.
- Creates a purgeable kubernetes cluster with single master and single worker.
- Deploys nginx-ingress-controller using helm.
- Deploys all the manifests to bring up the application.
- Hits the application through ingress (using the nodeport type nginx-ingress-controller service).
