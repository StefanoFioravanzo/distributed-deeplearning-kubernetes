#!/usr/bin/env bash

# ----------------------------------------
# Azure specific settings
RESOURCE_GROUP="KubeCluster"
LOCATION="eastus"
KUBERNETES_VERSION="1.9.6"

# ----------------------------------------
# CPU machines:
#   - Standard_D2_2: smaller
# GPU machines:
#   - Standard_NC6: smaller

VM_SIZE="Standard_NC6"
# How many nodes in the cluster
VM_NUMBER=1
# ----------------------------------------


# ----------------------------------------
# Kubernetes settings
CLUSTER_NAME="mxoperator-cluster"
# ----------------------------------------


# ----------------------------------------
# Operator settings
CHART=https://storage.googleapis.com/tf-on-k8s-dogfood-releases/latest/tf-job-operator-chart-latest.tgz
OPERATOR_NAME="tf-job"
HELM_ARGS="--set cloud=azure"


# ----------------------------------------
# Distributed job settings
JOB_TEMPLATE_PATH=/path/to/template
