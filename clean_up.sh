#!/usr/bin/env bash

# load config variables
source ./config.sh

# get all resources in resource group
az resource list --resource-group ${RESOURCE_GROUP}
az aks delete --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --yes --no-wait


# TODO: Cleanup file share. Clean up secrets.
