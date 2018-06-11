#!/usr/bin/env bash

# echo "ROLE "$DMLC_ROLE
# echo "URI "$DMLC_PS_ROOT_URI
# echo "PORT "$DMLC_PS_ROOT_PORT
# echo "NS" $DMLC_NUM_SERVER
# echo "NW" $DMLC_NUM_WORKER
# echo "VB" $PS_VERBOSE
#
# echo "POD IP: " $MY_POD_IP

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
    python3 -c "import mxnet"
fi

if [ "$DMLC_ROLE" = "worker" ]
then
    echo "Executing worker node."
    python3 /app/main.py
fi
