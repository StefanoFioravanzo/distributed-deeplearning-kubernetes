# Azure Storage Management Sample - Demonstrates how to create and manage storage accounts.
# For more documentation, refer to http://go.microsoft.com/fwlink/?LinkId=786322

# Provide your subscription ID
# To retrieve your subscription ID, run the following two commands:
  # az login
  # az account list
subscription_id="<Subscription ID>"

# Provide the name of the resource group that will be created.
resource_group_name="<Resource Group Name>"

# Provide the name of the Storage account that will be created.
storage_account_name="<Storage Account Name>"

# Specify the type of Storage account to create and another type that will be used for updating the Storage account. Valid values are:
  # LRS (locally-redundant storage)
  # ZRS (zone-redundant storage)
  # GRS (geo-redundant storage)
  # RAGRS (read access geo-redundant storage)
  # PLRS (premium locally-redundant storage)
type="<GRS>"
new_type="<RAGRS>"

# Specify the location of the Storage account to create.
# To view available locations for Storage, go to http://go.microsoft.com/fwlink/?LinkId=786652 or run the following command:
  # az provider show Microsoft.Storage
#NOTE: Location names must be lowercase with no spaces. For example, East US = eastus.
location="<Location>"

# Enable Azure CLI Resource Manager commands
az config mode arm

# Set default Azure subscription
az account set $subscription_id

# Create new resource group
az group create $resource_group_name $location

# Create new Storage account
az storage account create --resource-group $resource_group_name --location $location --type $type $storage_account_name

# Show details of Storage account
az storage account show --resource-group $resource_group_name $storage_account_name

# List all Storage accounts in subscription
az storage account list

# Get access keys for Azure Storage account
az storage account keys list --resource-group $resource_group_name $storage_account_name

# Renew primary access key for Azure Storage account
az storage account keys renew --resource-group $resource_group_name --primary $storage_account_name

# Print Azure Storage connection string
az storage account connectionstring show --resource-group $resource_group_name $storage_account_name

# Update Storage account type
az storage account set --resource-group $resource_group_name --type $new_type $storage_account_name
az storage account show --resource-group $resource_group_name $storage_account_name

# Delete Storage account
az storage account delete --resource-group $resource_group_name $storage_account_name

# Delete resource group
az group delete $resource_group_name
