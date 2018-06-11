#!/usr/bin/env bash

# Azure Storage File Sample - Demonstrates how to use the File Storage service.
# For more documentation, refer to http://go.microsoft.com/fwlink/?LinkId=786322

# set as env variable to automatically connecto to storage account using az
export AZURE_STORAGE_ACCOUNT="<Storage Account Name>"
export AZURE_STORAGE_ACCESS_KEY="<Storage Account Key>"

# create directory to download file to
mkdir <destination_path>

# Create a new share
az storage share create <share_name>

# Create a new directory within the share
az storage directory create <share_name> <directory_name>

# Upload new file into directory
az storage file upload <full_path_to_file> <share_name> <directory_name>

# List contents within share
az storage file list --share-name=<share_name> --output=table
# list the files in a directory within a share
az storage file list --share-name <share_name>/myDir --output table
# list the files in a path within a share
az storage file list --share-name <share_name> --path myDir/mySubDir/MySubDir2 --output table

# Download the file
source_path=<directory_name>/<file_name>
az storage file download <share_name> <source_path> <destination_path>

# Delete the share
az storage share delete <share_name>
