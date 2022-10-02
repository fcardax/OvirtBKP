#!/bin/bash
source vm_backup.conf
source functions.sh

CLUSTER_NAME=$1
CLUSTER_ID=$(get_cluster_id $CLUSTER_NAME)
WDIR=/root/bash_snapshots

#[ ! -z $1 ] && LIST=$(get_all_vms | egrep -e $1)
#[ -z $1 ] && LIST=$(get_all_vms)
for I in $(get_all_vms_cluster $CLUSTER_ID)
do
	echo $WDIR/vm_backup.sh $I 
done
