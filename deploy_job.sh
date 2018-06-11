#!/usr/bin/env bash

# Load config variables
source ./config.sh

# Login into azure cli
az login

count=`az aks list --output tsv | grep ${CLUSTER_NAME} | wc -l | awk '{$1=$1};1'`  # awk to remove whitespaces
if [ $count = 1 ]
then
    echo "Creating cluster ${CLUSTER_NAME} with ${VM_NUMBER} nodes of size ${VM_SIZE}. Running..."
    # create the cluster
    # --generate-ssh-keys wiil take the default key present in the machine (id_rsa)
    # if you want to use a different key, use --ssh-key-file <path to key>
    az aks create --node-vm-size ${VM_SIZE} --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --node-count ${VM_NUMBER} --kubernetes-version ${KUBERNETES_VERSION} --location ${LOCATION} --generate-ssh-keys
    echo "Creating cluster ${CLUSTER_NAME} with ${VM_NUMBER} nodes of size ${VM_SIZE}. Done."
else
    echo "Cluster with name ${CLUSTER_NAME} already exists."
    echo "To inspect cluster details run: az aks show --name ${CLUSTER_NAME} --resource-group ${RESOURCE_GROUP} --output table"
    echo "To delete the cluster run: az aks delete --name ${CLUSTER_NAME} --resource-group ${RESOURCE_GROUP} --no-wait -y"
fi

# ---------------------------------------------------------------------------------
# Error provisioning the cluster: MissingSubscriptionRegistration
# This happens because the resoruce provider has not been registered for the subscription

# https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-register-provider-errors

# List of registered resource providers
az provider list
# Register a provider
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network

# Show status while registering
az provider show -n Microsoft.Compute
# ---------------------------------------------------------------------------------

# Get kubernetes config file (~/.kube/config)
az aks get-credentials --name ${CLUSTER_NAME} --resource-group ${RESOURCE_GROUP}
# Open kuernetes dashboard
az aks browse --name ${CLUSTER_NAME} --resource-group ${RESOURCE_GROUP}

# ----------------------------------------------
# Initialize helm (better to upgrade in case of version mismatch)
helm init --upgrade
helm init
heml version  # check version
# ----------------------------------------------

# Deploy operator
helm install ${CHART} -n ${OPERATOR_NAME} --wait --replace ${HELM_ARGS}

# Create a distributed job
kubectl create -f ${JOB_TEMPLATE_PATH}
