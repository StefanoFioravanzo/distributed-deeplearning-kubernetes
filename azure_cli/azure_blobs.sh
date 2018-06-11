#!/usr/bin/env bash

# Azure Storage Blob Sample - Demonstrates how to use the Blob Storage service.
# Blob storage stores unstructured data such as text, binary data, documents or media files.
# For more documentation, refer to http://go.microsoft.com/fwlink/?LinkId=786322

# set as env variable to automatically connecto to storage account using az
export AZURE_STORAGE_ACCOUNT="<Storage Account Name>"
export AZURE_STORAGE_ACCESS_KEY="<Storage Account Key>"

# Create a new container
az storage container create <container_name>

# Upload a blob into a container
az storage blob upload <file_to_upload> <container_name> <blob_name>

# List all blobs in a container
az storage blob list <container_name>

# List all blobs in a container (json)
az storage blob list --json <container_name>

# Download blob
az storage blob download <container_name> <blob_name> <destination_folder>/<blob_name>

# Delete container
az storage container delete <container_name>
