#!/bin/bash
source vm_backup.conf
source functions.sh

WDIR=/root/bash_snapshots
[ ! -z $1 ] && LIST=$(get_all_vms | egrep -e $1)
[ -z $1 ] && LIST=$(get_all_vms)
for I in $LIST
do
	$WDIR/vm_backup.sh $I 
done
