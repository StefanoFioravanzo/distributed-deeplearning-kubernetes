#!/usr/bin/env bash

RESOURCE_GROUP="KubeCluster"
CLUSTER_NAME="mxoperator-cluster"
# Smaller CPU machine
#VM_SIZE="Standard_D2_v2"
# Smaller GPU machine
VM_SIZE="Standard_NC6"
VM_NUMBER=1
STORAGE_ACCOUNT_NAME="mxsa"
SHARE_NAME="mxsn"

az login

# create resource group
az group create --name ${RESOURCE_GROUP} --location "East US"
# get available versions
az aks get-versions
# create container service
# CPU
az aks create --node-vm-size ${VM_SIZE} --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --node-count ${VM_NUMBER} --kubernetes-version 1.9.6 --location "East US" --generate-ssh-keys
# GPU

# add providers to enable resouces
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network

# get kubernetes config file
az aks get-credentials --name ${CLUSTER_NAME} --resource-group ${RESOURCE_GROUP}
# open kuernetes dashboard
az aks browse --resource-group KubeCluster --name mxoperator-cluster

# show kubectl config
kubectl config current-context
# set default context to <cluster-name>
kubectl config use-context "<cluster_name>"

# see that nodes have been created successfully
kubectl get nodes

# Setup SharedStorage and upload training data
az storage account list --output table  # list available storage accounts
az storage account create --resource-group ${RESOURCE_GROUP} --name ${STORAGE_ACCOUNT_NAME} --location eastus --sku Standard_LRS
# set connection string to account storage - used to create file share and interact with account storage.
export AZURE_STORAGE_CONNECTION_STRING=$(az storage accou   nt show-connection-string --name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} -o tsv)
export AZURE_STORAGE_ACCOUNT_NAME_BASE64=$(echo -n ${STORAGE_ACCOUNT_NAME} | base64)
export AZURE_STORAGE_ACCOUNT_KEY_BASE64=$(az storage account keys list --account-name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP} -o tsv  | head -n 1 | awk '{print $3}' | tr -d '\n' | base64)

# setup the storage account
kubectl create -f path/to/storage_class.yml  # TODO: What is a storage class?
# create file share
az storage share create --name ${SHARE_NAME}
# list fileshares present in the account storage
az storage share List

#TODO: What to we need secrets for?
kubectl get secrets
kubectl create -f secret.yml  # create secret with the credentials to the storage account

# Upload data into the share.
# Create data directory inside the share
az storage directory create --share-name ${SHARE_NAME} --name data
az storage file upload --share-name ${SHARE_NAME} --path data/cifar --source /Users/StefanoFiora/Work/Datasets/cifar-10/data/cifar/train.lst




# get all resources in resource group
az resource list --resource-group ${RESOURCE_GROUP}
az aks delete --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --yes --no-wait