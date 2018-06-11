#!/usr/bin/env bash

RESOURCE_GROUP=""
STORAGE_ACCOUNT_NAME="mxsa"
FILESHARE_NAME="dloperator-share"

AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
                                        --name ${STORAGE_ACCOUNT_NAME} \
                                        --resource-group ${RESOURCE_GROUP} \
                                        -o tsv)

load_file () {
    az storage file upload --share-name ${SHARE_NAME} --path ${fs_path} --source ${file_path}
}

load_dir () {
    # iterate over contents. If find a dicrectory create the directory in the file share
    # otherwise load the file
    for i in "$1"/*
    do
        if [ -d "$i" ];then
            echo "create direcotry: $i"
            az storage directory create --share-name ${SHARE_NAME} --name $i
            # recursive call to subdirectory
            load_dir "$i"
        elif [ -f "$i" ]; then
            echo "load file: $i"
            az storage file upload --share-name ${SHARE_NAME} --path $(dirname $i) --source $(basename $i)
        fi
    done
}

print_help () {
    echo "Azure file loader."
    echo "-- author: Stefano Fioravanzo"
    echo
    echo "Args:"
    echo -e "\t-f|\tLoad single file"
    echo -e "\t-R|\tLoad recursively all directory contents"
    echo -e "\t-h|--help\t\tPrint this help and exit"

    exit 0
}

# Parse CLI arguments
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    print_help
    shift
    ;; # past argument
    -f)
    file_path="$2"
    shift # past argument
    shift # past value
    ;;
    --path)
    fs_path="$2"
    shift # past argument
    shift # past value
    ;;
    -R)
    dir_path="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ -n "$file_path" ]
then
    if [[ -f $file_path ]]; then
        load_file
    elif [[ -d $file_path ]]; then
        echo "$file_path is a directory"
        exit 1
    else
        echo "$file_path is not valid"
        exit 1
    fi
fi

if [ -n "$dir_path" ]
then
    if [[ -f $dir_path ]]; then
        echo "$dir_path is a file"
    elif [[ -d $dir_path ]]; then
        load_dir $dir_path
        exit 1
    else
        echo "$dir_path is not valid"
        exit 1
    fi
fi
