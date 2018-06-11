#!/bin/bash

# The 'default' account is the one useds
az account list

# To change subscription (account)
az account set -s "Example Subscription Two"

# Show current account
az account show

# Create resrouce group
az group create --name TestRG1 --location "East US"

az group list
az group show --name <rs-group>

# Get a resource by name
az resource list -n myuniquestorage

# List all the resources present in a resource group
az resource list --resource-group <rs-group-name>
GROUP_RESOURCES=$(az resource list -g k8test --output table | awk '{print $1}' | tail -n +3)

# Get resource by tag
az resource list --tag Dept=IT

# Get resources with particular resource type
az resource list --resource-type "Microsoft.Storage/storageAccounts"

# Get resource ID
webappID=$(az resource show -g exampleGroup -n exampleSite --resource-type "Microsoft.Web/sites" --query id --output tsv)

# Delete resources inside a resource group
az storage account delete -n myuniquestorage -g group
while read -r line ; do az storage account delete -n $line -g k8test --yes; done <<< $GROUP_RESOURCES

# Delete resource group and all its associated resources
az group delete -n group --yes --no-wait
