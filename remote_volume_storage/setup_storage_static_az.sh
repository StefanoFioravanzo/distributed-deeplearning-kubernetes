#!/usr/bin/env bash

# config variables
STORAGE_ACCOUNT_NAME="mxsa"
SHARE_NAME="mxsn"
STORAGE_SKU="Standard_LRS"
SECRET_PATH=""
# ----------------------------------------

# Setup SharedStorage and upload training data
az storage account list --output table  # list available storage accounts

az storage account create --resource-group ${RESOURCE_GROUP} \
                        --name ${STORAGE_ACCOUNT_NAME} \
                        --location ${LOCATION} \
                        --sku ${STORAGE_SKU}
# Set connection string to account storage - used to create file share and interact with account storage.
AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
                                        --name ${STORAGE_ACCOUNT_NAME} \
                                        --resource-group ${RESOURCE_GROUP} \
                                        -o tsv)

# Create file share
az storage share create --name ${SHARE_NAME}


# Need base64 encoding of account name and key for kubernetes secret (see <path>/secret.yml)
AZURE_STORAGE_ACCOUNT_NAME_BASE64=$(echo -n ${STORAGE_ACCOUNT_NAME} | base64)
AZURE_STORAGE_ACCOUNT_KEY_BASE64=$(az storage account keys list \
                                        --account-name ${STORAGE_ACCOUNT_NAME} \
                                        --resource-group ${RESOURCE_GROUP} \
                                        -o tsv \
                                        | head -n 1 \
                                        | awk '{print $3}' \
                                        | tr -d '\n' \
                                        | base64)
sed -i "s/azurestorageaccountname/${AZURE_STORAGE_ACCOUNT_NAME_BASE64}/g" ${SECRET_PATH}
sed -i "s/azurestorageaccountkey/${AZURE_STORAGE_ACCOUNT_KEY_BASE64}/g" ${SECRET_PATH}
kubectl create -f ${SECRET_PATH}

# Alternatively, kubectl provides a command to setup the secret automatically
# Get storage account key
# STORAGE_ACCOUNT_KEY=$(az storage account keys list \
#             --resource-group ${RESOURCE_GROUP} \
#             --account-name ${STORAGE_ACCOUNT_NAME} \
#             --query "[0].value" \
#             -o tsv)
# Create secret
# kubectl create secret generic azure-secret --from-literal=azurestorageaccountname=${STORAGE_ACCOUNT_NAME} --from-literal=azurestorageaccountkey=${STORAGE_ACCOUNT_KEY}

# Upload data into the share.
# Create data directory inside the share
az storage directory create --share-name ${SHARE_NAME} --name data
az storage file upload --share-name ${SHARE_NAME} --path data/cifar --source /Users/StefanoFiora/Work/Datasets/cifar-10/data/cifar/train.lst
