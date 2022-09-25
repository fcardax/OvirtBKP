#!/bin/bash
##
GREEN='\033[0;32m'
NC='\033[0m'

## HEADER HTTP
H1="Accept: application/xml"
H2="Content-Type: application/xml"
H3="Authorization: Basic YWRtaW5AaW50ZXJuYWw6ZGFpdGFybjMk"
URL="https://engine.ovirt.local/ovirt-engine/api/"


## vm id backup 
BACKUP_VM_ID="806823fa-afee-4a75-bda8-c3e1c5923762"
BACKUP_DIR=/mnt/backup

## arg 1 vm name
VM=$1

source functions.sh
VM_ID=$(get_vm_id $VM)

#eseguo snapshot VM
[ -f /tmp/snapshot.out ] && rm -f /tmp/snapshot.out
echo -e "${GREEN}SNAPSHOST ${NC}$VM"
SNAPSHOT_NAME="BACKUP_$(date "+%d%m%y%H%M%S")"
SNAPSHOT_DATA="<snapshot> <description>$SNAPSHOT_NAME</description> </snapshot>"
curl -s -X POST -k -H "$H1" -H "$H2" -H "$H3" -i $URL/vms/$VM_ID/snapshots --data "$SNAPSHOT_DATA" -o /tmp/snapshot.out
sleep 1

## loop check status of snapshot
while true
do
	curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" -i $URL/vms/$VM_ID/snapshots --data "$SNAPSHOT_DATA" -o /tmp/snapshot_status.out
	echo -n .
	snapshot_status $SNAPSHOT_NAME
	sleep 1
done
echo

SNAPSHOT_ID=$(cat /tmp/snapshot.out | grep "snapshot href" | sed -e 's/^.*id="\(.*\)">/\1/')
[ -f /tmp/disks.out ] && rm -f /tmp/disks.out
		
# get disk id 
curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" -i $URL/vms/$VM_ID/snapshots/$SNAPSHOT_ID/disks -o /tmp/disks.out

# attach disks id to backup vm
DISKS_ID=$(cat /tmp/disks.out | grep "disk id" | sed -e 's/.*="\(.*\)">/\1/')
for DISK_ID in $DISKS_ID
do
	DISKATTACHMENT_DATA="<disk_attachment> <active>true</active> <interface>virtio_scsi</interface> <disk id=\"$DISK_ID\" > <snapshot id=\"$SNAPSHOT_ID\" /> </disk> </disk_attachment>"
	echo -e "${GREEN}ATTACH DISK $NC"
	curl -X POST -k -H "$H1" -H "$H2" -H "$H3" -i $URL/vms/$BACKUP_VM_ID/diskattachments/ --data "$DISKATTACHMENT_DATA"

	DISK_NAME=$(get_disk_name_by_id "$DISK_ID")

	## backup procedure
	DEV=$(dmesg  | grep 'Attached SCSI disk'| grep -v sda | awk '{print $5}' | grep -v Attached | sed -e 's/\[//' -e 's/\]//'| sort | uniq)
	echo DEBUG: $DEV
	for DISK in $DEV
	do
		if [ -e /dev/${DISK} ]
		then
			dd if=/dev/${DISK} of=${BACKUP_DIR}/$DISK_NAME status=progress
		fi
	done

	echo -e "${GREEN}DETACH DISK $NC"
	curl -X DELETE -k -H "$H1" -H "$H2" -H "$H3" -i $URL/vms/$BACKUP_VM_ID/diskattachments/$DISK_ID
done

echo -e "${GREEN}REMOVE SNAPSHOST $NC"
curl -X DELETE -k -H "$H1" -H "$H2" -H "$H3" -i $URL/vms/$VM_ID/snapshots/$SNAPSHOT_ID 
