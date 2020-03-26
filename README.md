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

