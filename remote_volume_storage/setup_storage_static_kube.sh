#!/usr/bin/env bash

RESOURCE_GROUP=""

# storage account
STORAGE_ACCOUNT_NAME="dloperator-sa"
STORAGE_SKU="Standard_LRS"

# secret
SECRET_PATH="./secret.yml"
SECRET_NAME="dloperator-secret"

# sc
STORAGE_CLASS_PATH="./azure-fileshare-sc.yml"
STORAGE_CLASS_NAME="dloperator-sc"

# pv
PERSISTENT_VOLUME_PATH="./azure-fileshare-pv.yml"
PERSISTENT_VOLUME_NAME="dloperator-pv"
PERSISTENT_VOLUME_CAPACITY="5Gi"

# pvc
PERSISTENT_VOLUME_CLAIM_PATH="./azure-fileshare-pvc.yml"
PERSISTENT_VOLUME_CLAIM_NAME="dloperator-pvc"
PERSISTENT_VOLUME_CLAIM_CAPACITY="5Gi"

# file share
FILESHARE_NAME="dloperator-share"
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

# Create storage class
sed -i "s/[myStorageClassName]/${STORAGE_CLASS_NAME}/g" ${STORAGE_CLASS_PATH}
sed -i "s/[myStorageAccount]/${STORAGE_ACCOUNT_NAME}/g" ${STORAGE_CLASS_PATH}
kubectl apply -f ${STORAGE_CLASS_PATH}

# Create a PersistentVolume
sed -i "s/[myPersistentVolumeName]/${STORAGE_ACCOUNT_NAME}/g" ${PERSISTENT_VOLUME_PATH}
sed -i "s/[myPersistentVolumeCapacity]/${PERSISTENT_VOLUME_CAPACITY}/g" ${PERSISTENT_VOLUME_PATH}
sed -i "s/[myStorageClassName]/${STORAGE_CLASS_NAME}/g" ${PERSISTENT_VOLUME_PATH}
sed -i "s/[mySecretName]/${SECRET_NAME}/g" ${PERSISTENT_VOLUME_PATH}
sed -i "s/[myFileShareName]/${FILESHARE_NAME}/g" ${PERSISTENT_VOLUME_PATH}
kubectl apply -f ${PERSISTENT_VOLUME_PATH}

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
sed -i "s/[mySecretName]/${SECRET_NAME}/g" ${SECRET_PATH}
sed -i "s/[base64encodedStorageAccountName]/${AZURE_STORAGE_ACCOUNT_NAME_BASE64}/g" ${SECRET_PATH}
sed -i "s/[base64encodedStorageAccountKey]/${AZURE_STORAGE_ACCOUNT_KEY_BASE64}/g" ${SECRET_PATH}
kubectl create -f ${SECRET_PATH}

# Create PersistentVolumeClaim
sed -i "s/[myPersistentVolumeClaimName]/${PERSISTENT_VOLUME_CLAIM_NAME}/g" ${PERSISTENT_VOLUME_CLAIM_PATH}
sed -i "s/[myPersistentVolumeClaimCapacity]/${PERSISTENT_VOLUME_CLAIM_CAPACITY}/g" ${PERSISTENT_VOLUME_CLAIM_PATH}
sed -i "s/[myStorageClassName]/${STORAGE_CLASS_NAME}/g" ${PERSISTENT_VOLUME_CLAIM_PATH}
kubectl apply -f ${PERSISTENT_VOLUME_CLAIM_PATH}

# Upload data into the share.
# Create data directory inside the share
az storage directory create --share-name ${SHARE_NAME} --name data
az storage file upload --share-name ${SHARE_NAME} --path data/cifar --source /Users/StefanoFiora/Work/Datasets/cifar-10/data/cifar/train.lst
