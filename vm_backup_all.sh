#!/bin/bash
source vm_snapshot.conf
source functions.sh

WDIR=/root/bash_ovirt

for I in $(get_all_vms)
do
	echo ./vm_backup.sh $I
done
