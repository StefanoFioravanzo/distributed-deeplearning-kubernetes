## Distributed Deep Learning Using Kubernetes and CustomOperators

Folders structure:

- `azure-cli/`: Example cli script to manage Azure resources from command line.
- `mxnet-distributed/`:
    - `docker/`: Examples of MXNET distributed implementation using Docker. Using docker-compose to run distributed setup with multiple containers on a single machine.
    - `local_distributed_kvstore/`: a couple of example of MXNET distributed mode and `kvstore` object management.
- `tf-distributed`: Some examples of Tensorflow distributed mode. Using docker-compose to run distributed setup with multiple containers on a single machine.
- `remote_volume_storage`: scripts to automate the setup of a remote volume specifically on the azure cloud or using kubernetes way for cloud agnostic configuration.
- `deploy_job.sh`: Automation script to deploy a new dljob
- `config.sh`: Set azure parameters to deploy job and storage
- `clean_up.sh`: Clean up cloud resources
