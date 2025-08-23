```sh
minikube start
````

```sh
minikube status
````

```sh
kubectl cluster-info
````

```sh
minikube dashboard
````

```sh
kubectl get node
````

```sh
kubectl get pods -n terraform-test
````

```sh
kubectl delete namespace terraform-test
````


# Terraform

```sh
cd terraform-k8s-test
````

```sh
terraform init -upgrade 
````

```sh
terraform apply
````


```sh
for dir in cloud-config-server cloud-hello-service; do cd cloud/$dir && mvn spring-boot:build-image && cd ../..; done
````

```sh

````

```sh
docker system prune --all
````


Once Docker Desktop has restarted, you can verify that Kubernetes is running by opening a command prompt or PowerShell and running the following command:

1 kubectl get nodes

You should see a single node with a status of "Ready". kubectl is the command-line tool for interacting with Kubernetes, and it's included with Docker Desktop.

Let me know once you have your Kubernetes cluster up and running. After that, we'll connect Terraform to your new cluster.