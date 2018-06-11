#!/usr/bin/env bash

echo "ROLE "$DMLC_ROLE
echo "URI "$DMLC_PS_ROOT_URI
echo "PORT "$DMLC_PS_ROOT_PORT
echo "NS "$DMLC_NUM_SERVER
echo "NW "$DMLC_NUM_WORKER
echo "VB "$PS_VERBOSE

export DATA_PATH=/data/cifar/

if [ "$DMLC_ROLE" = "scheduler" ]
then
    echo "Executing scheduler node."
    # awk to remove possible trailing whitespace
    H_NAME=`hostname -I | awk '{$1=$1};1'`
    echo "Setting Scheduler URI: " ${H_NAME}
    # export DMLC_PS_ROOT_URI=`ip route get 8.8.8.8 | awk '{print $NF; exit}'`
    export DMLC_PS_ROOT_URI=${H_NAME}
    # exec script in this env since we updated the env variable
    exec python3 -c "import mxnet"
fi

if [ "$DMLC_ROLE" = "server" ]
then
    echo "Executing server node."
    exec python3 -c "import mxnet"
fi

if [ "$DMLC_ROLE" = "worker" ]
then
    echo "Executing worker node."
    exec python3 /app/main.py \
        --model resnet101_v1 \
        --dataset cifar10 \
        --data-dir $DATA_PATH \
        --epochs 1 \
        --mode imperative \
        --batch-size 128 \
        --kvstore dist_async \
        --num-worker $DMLC_NUM_WORKER
fi
