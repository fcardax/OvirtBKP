#!/bin/bash

## CHANGE with correct install dir
INSTALL_DIR="/root/OvirtBKP"

source $INSTALL_DIR/vm_backup.conf
source $INSTALL_DIR/functions.sh

CMD="vm_backup.sh"
CMD_BOOT="vm_backup_boot.sh"

while getopts "nbc:" flag
do
    case "${flag}" in
        c)
		CLUSTER_NAME=$OPTARG
		;;
        n)
                CMD="echo $INSTALL_DIR/$CMD"
		;;

        b)
                CMD="echo $INSTALL_DIR/$CMD_BOOT"
		;;
    esac
done

CLUSTER_ID=$(get_cluster_id $CLUSTER_NAME)
for VM_IN in $(get_all_vms_cluster $CLUSTER_ID)
do
	$CMD $VM_IN
done
