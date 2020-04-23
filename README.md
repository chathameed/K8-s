1) Setup Azure cli on a ubuntu vm

Document Reference : https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest


		sudo apt-get update

		Setup Repo details
		------------------
		sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
		curl -sL https://packages.microsoft.com/keys/microsoft.asc | 
		    gpg --dearmor | 
		    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null
		AZ_REPO=$(lsb_release -cs)
		echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | 
		    sudo tee /etc/apt/sources.list.d/azure-cli.list
		
		Install Azure-Cli
		-----------------
		sudo apt-get update
		sudo apt-get install azure-cli

az login

2 ) Create AKS Cluster using Azure cli

Document Reference : https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough

          Create a Kubernetes cluster within aa existing resource group
          -------------------------------------------------------------

          az aks create --resource-group myResourceGroup --name myAKSCluster --node-count 1 --enable-addons monitoring -- generate-ssh-keys

          Install Kubernetes Cli
          ----------------------

          az aks install-cli

          az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

          kubectl get nodes
	 
	 
	 
------------------------------------------------------------------------------------------------------------------------------

Helm has a simple architecture, which is comprised of a client and an in-cluster server:

Tiller Server: Helm manages Kubernetes application through a component called Tiller Server installed within a Kubernates cluster. Tiller interacts with the Kubernetes API server to install, upgrade, query and remove Kubernetes resources.
Helm Client: Helm provides a command-line interface for users to work with Helm Charts. Helm Client is responsible for interacting with the Tiller Server to perform various operations like install, upgrade and rollback charts

Helm manages Kubernetes resource packages through Charts.

A chart is nothing but a set of information necessary to create a Kubernetes application, given a Kubernetes cluster:

A chart is a collection of files organized in a specific directory structure
The configuration information related to a chart is managed in the configuration
Finally, a running instance of a chart with a specific config is called a release


Installing  HELM
-----------------
Document reference : https://helm.sh/docs/intro/install/
Download link : https://github.com/helm/helm/releases
wget https://get.helm.sh/helm-v2.16.5-linux-amd64.tar.gz

gunzip helm-v3.0.0-linux-amd64.tar.gz
tar xvf helm-v3.0.0-linux-amd64.tar
cp helm /usr/local/bin/
cp tiller   /usr/local/bin/  

Setting up HELM:

Document reference : https://www.digitalocean.com/community/tutorials/how-to-install-software-on-kubernetes-clusters-with-the-helm-package-manager

create a service account for tiller 
-----------------------------------
kubectl -n kube-system create serviceaccount tiller

Bind the service account to a role, we are using cluster-admin just for thr purpose of exploring helm
 
---------------------------------------------------------------------------------------------------------

kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

we can run helm init, which installs Tiller on our cluster, along with some local housekeeping tasks such as downloading the stable repo details

helm init --service-account tiller

To verify that Tiller is running, list the pods in thekube-system namespace:

kubectl get pods --namespace kube-system





######################################


Application deployment
======================

1. Deploying NGINX ingress controller in AKS.

Document reference https://docs.microsoft.com/en-us/azure/aks/ingress-basic

   
    Create a namespace for your ingress resources
        kubectl create namespace ingress-basic
   
    Adding Repo to Helm for NGINX ingress controller
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/

   
    Use Helm to deploy an NGINX ingress controller
    helm install nginx-ingress stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
   
    Validating Ingress controller in AKS
    kubectl get service -l app=nginx-ingress --namespace ingress-basic
   
2. Installing Hello-World App from AKS Repo.
============================================

    Adding repo to Helm.
    helm repo add azure-samples https://azure-samples.github.io/helm-charts/
   
    Deploying Hello-World one  App including services using helm.
    helm install aks-helloworld azure-samples/aks-helloworld --namespace ingress-basic
   
    Deploying Hello-World two  App including services using helm.
    helm install aks-helloworld-two azure-samples/aks-helloworld \
    --namespace ingress-basic \
    --set title="AKS Ingress Demo" \
    --set serviceName="aks-helloworld-two"
   
3. Create  hello-world-ingress with the below file for communicating ingress to Service to Pod.



####################################
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-world-ingress
  namespace: ingress-basic
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: aks-helloworld
          servicePort: 80
        path: /(.*)
      - backend:
          serviceName: aks-helloworld-two
          servicePort: 80
        path: /hello-world-two(/|$)(.*)
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-world-ingress-static
  namespace: ingress-basic
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/rewrite-target: /static/$2
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: aks-helloworld    
###############################################   
kubectl apply -f hello-world-ingress.yaml

4. Validation
==============


root@vm001:~# kubectl get svc -A
NAMESPACE       NAME                            TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                      AGE
default         kubernetes                      ClusterIP      10.0.0.1      <none>          443/TCP                      2d11h
ingress-basic   aks-helloworld                  ClusterIP      10.0.126.26   <none>          80/TCP                       7m27s
ingress-basic   aks-helloworld-two              ClusterIP      10.0.115.44   <none>          80/TCP                       6m41s
ingress-basic   nginx-ingress-controller        LoadBalancer   10.0.3.56     52.188.25.105   80:32609/TCP,443:31169/TCP   22m
ingress-basic   nginx-ingress-default-backend   ClusterIP      10.0.252.21   <none>          80/TCP                       22m
kube-system     kube-dns                        ClusterIP      10.0.0.10     <none>          53/UDP,53/TCP                2d11h
kube-system     kubernetes-dashboard            ClusterIP      10.0.96.117   <none>          80/TCP                       2d11h
kube-system     metrics-server                  ClusterIP      10.0.110.72   <none>          443/TCP                      2d11h
########
iNGRESS-BASIC   NGINX-INGRESS-CONTROLLER        LOADBALANCER   10.0.3.56     52.188.25.105   80:32609/TCP,443:31169/TCP   22M

Http://52.188.25.105 to view the actual app running urlwith the external ip of the Ingress controller.




1) create a deployment using the below file 
===========================================

apiVersion: apps/v1 # for versions before 1.9.0 use apps/v1beta2
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: hameedns
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80

kubectl apply -f nginxdeployment.yaml


2) create a node port service with the below yaml 
==================================================

apiVersion: v1
kind: Service
metadata:
   name: hameednodeportservice
   namespace: hameedns
spec:
   type: NodePort
   ports:
     - targetPort: 80
       port: 80
       nodePort: 30025
   selector:
     app: nginx
kubectl apply -f createnodeportservice.yaml


we cannot expose the service because the nodes doesnt have the external ip so we would need to use LB for exposing the resource:
=======================================================================================================================

root@vm001:~# kubectl get nodes -o wide
NAME                                STATUS   ROLES   AGE     VERSION    INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
aks-agentpool-58930864-vmss000000   Ready    agent   3d10h   v1.15.10   10.240.0.4    <none>        Ubuntu 16.04.6 LTS   4.15.0-1071-azure   docker://3.0.10+azure
aks-agentpool-58930864-vmss000001   Ready    agent   3d10h   v1.15.10   10.240.0.5    <none>        Ubuntu 16.04.6 LTS   4.15.0-1071-azure   docker://3.0.10+azure
aks-agentpool-58930864-vmss000002   Ready    agent   3d10h   v1.15.10   10.240.0.6    <none>        Ubuntu 16.04.6 LTS   4.15.0-1071-azure   docker://3.0.10+azure
root@vm001:~#



Accessing Kubernetes Dashboard: 
================================

Get the port details of any services 
=====================================

kubectl describe pod kubernetes-dashboard-74d8c675bc-jlbkm -n kube-system |grep -i port

Create cluster role binding to access the dashboard on a AKS cluster:
=====================================================================
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard


get the kubedashboard name from below:
=====================================

kubectl get pods -A

kubectl port-forward  pod/kubernetes-dashboard-74d8c675bc-jlbkm -n kube-system 3000:9090

Access any application on kubernetes: 
=====================================

kubectl port-forward  pod/petclinic-deployment-54479fb7f7-cnbpt -n petclinic 3000:8080

reference links:
================

https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard 

az aks browse --resource-group hameedrg --name hameedakscluster01

kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

