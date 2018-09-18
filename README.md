## Distributed Deep Learning Using Kubernetes and CustomOperators

This repository is a collection of resources and scripts for the deployment and automation of resources allocation for Kubernetes operators. You can find a version of my MXNet Go operator at [https://github.com/StefanoFioravanzo/mx-operator](https://github.com/StefanoFioravanzo/mx-operator) and the more general Python DLOperator at [https://github.com/StefanoFioravanzo/dl-operator](https://github.com/StefanoFioravanzo/dl-operator).


```
.
├── README.md
├── azure_cli
├── clean_up.sh
├── config.sh
├── deploy_job.sh
├── init.sh
├── mxnet_distributed
│   ├── docker
│   │   ├── cifar10
│   │   └── linear_model
│   └── local_distributed_kvstore
├── operator_deployments
├── remote_volume_storage
└── tf_distributed
    ├── image_painting_docker
    ├── mnist_docker
    └── template_cpu_distributed
```

##### `azure-cli/`

Collection of scripts to automate the setup of Azure cloud resources, management of a cluster o nodes, setup of remote storage. 

- Resource Groups & Storage Accounts: An Azure resource group is a logical container into which Azure resources are deployed and managed, useful for concerns separation and resource management. A storage account contains all the Azure Storage data objects: blobs, files, queues, ...
- AKS: Azure provides its own Kubernetes container orchestration service to manage and deploy Kubernetes clusters. 
- File Shares: Azure Files offers fully managed file shares in the cloud that are accessible via the industry standard SMB protocol. Azure Files are the optimal choice for loading and storing training data in the cloud and for result and log reporting.
- Blob Storage: Blob storage is optimized for storing massive amounts of unstructured data, such as text or binary data.

##### `mxnet-distributed/`

Examples and docker files to test MXNet distributed environment

- `docker/`: Docker is the perfect companion when testing applications that involve multiple processes that would need to run on multiple machines. The provided setup will run either a linear model or a cifar10 architecture with 1 master, 1 scheduler and 1 worker.   To test the models just cd into either `cifar10` or `linear_model` folder and run `docker-compose up`. 
- `local_distributed_kvstore/`: Test and run a linear model with the distributed MXNet distributed setup. Explore the KVStore APIs with the `kvstore` notebook.

##### `operator_deployments`

Some examples for the creation of a custom resource definition, the deployment of a new training job to the cluster and an example of using a parametrized Helm chart for hyperparameter sweep. Helm makes it easy to create dynamic Kubernetes deployments by iterating over the values provided in `values.yaml`.

##### `tf-distributed`

Some example architectures to test out Tensorflow distributed architectures, using Docker.

##### `remote_volume_storage`

Kubernetes tries to abstract the cloud provided as much as possible when creating, deleting and managing cluster resources. This is valid also for storage resources. Kubernetes offers a series of objects that can be deployed trough any Kubernetes client (e.g. `kubectl`) to create a storage account, (persistent) volume claims and file shares secrets.

These two scripts show two different paths - Azure `az` tool or Kubernetes `kubectl` - to achieve the same thing, mounting an Azure File Share:

- `setup_storage_static_az.sh`: Example script to setup an Azure File Share starting from the creation of a Storage Account, using the `az` tools.
- `setup_storage_static_kube.sh`: Example script that uses the kubernetes APIs to setup a new Azure File Share, starting from the creation of a new Storage Account.

##### `config.sh`

Settings file for the automation scripts.

##### `init.sh`

Complete automation script for the deployment of a new AKS cluster, the setup of an Azure account storage and storage file, the upload of a new dataset and the launch of a new distributed job.

##### `deploy_job.sh`

One single script to create a new Azure AKS cluster, setup the nodes, deploy a custom operator (packaged with Helm) and start a new distributed training job.

##### `clean_up.sh`

Clean up cloud resources.


