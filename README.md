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



