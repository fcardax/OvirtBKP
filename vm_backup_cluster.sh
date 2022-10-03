#!/bin/bash
source vm_backup.conf
source functions.sh

CLUSTER_NAME=$1
CLUSTER_ID=$(get_cluster_id $CLUSTER_NAME)

for I in $(get_all_vms_cluster $CLUSTER_ID)
do
	echo $PWD/vm_backup.sh $I 
done
