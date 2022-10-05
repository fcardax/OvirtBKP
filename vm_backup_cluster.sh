#!/bin/bash

## CHANGE with correct install dir
INSTALL_DIR="/opt/OvirtBKP"

source $INSTALL_DIR/vm_backup.conf
source $INSTALL_DIR/functions.sh

CMD="vm_backup.sh"
CMD_BOOT="vm_backup_boot.sh"
DRYRUN=0

while getopts "dnbc:" flag
do
    case "${flag}" in
        c)
		CLUSTER_NAME=$OPTARG
		;;
        n)
                CMD="$INSTALL_DIR/$CMD"
		;;

        b)
                CMD="$INSTALL_DIR/$CMD_BOOT"
		;;
	d)
		DRYRUN=1
		;;
    esac
done

CLUSTER_ID=$(get_cluster_id $CLUSTER_NAME)
echo "BACKUP $(date)"
echo
for VM_IN in $(get_all_vms_cluster $CLUSTER_ID)
do
	if [[ $DRYRUN == 1 ]]
	then
		echo $CMD $VM_IN
	else
		$CMD $VM_IN | tee -a /var/log/vm_backup.log
	fi
done
