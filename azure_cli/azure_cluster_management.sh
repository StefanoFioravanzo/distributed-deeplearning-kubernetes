#!bin/bash

# List cluster under Subscription
az acs list --output table

# List cluster in resource group
az acs list -g <rs> --output table

# Display details of a container service cluster
az acs show -g <rs> -n <cluster-name> --output list

# Scale the cluster
az acs scale -g <rs> -n <cluster-name> --new-agent-count 4
