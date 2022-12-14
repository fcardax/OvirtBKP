#!/bin/bash
##
source vm_backup.conf
source functions.sh
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

## arg 1 vm name
VM=$1

VM_ID=$(get_vm_id $VM)
DISK_ID=$(get_disk_id $2)

#eseguo snapshot VM
[ -f /tmp/snapshot.xml ] && rm -f /tmp/snapshot.out
echo -e "${GREEN}SNAPSHOST ${NC}$VM"
SNAPSHOT_NAME="BACKUP_$(date "+%d%m%y%H%M%S")"
BACKUP_DIR=${BACKUP_DIR}/${VM}/${SNAPSHOT_NAME}

[ -e /tmp/post_snapshot.xml ] && rm -f /tmp/post_snapshot.xml

cat > /tmp/post_snapshot.xml << EOF 
<snapshot>
  <description>$SNAPSHOT_NAME</description>
  <persist_memorystate>false</persist_memorystate>
  <disk_attachments>
    <disk_attachment>
      <disk id="${BOOT_DISK_ID}">
        <image_id>${IMAGE_ID}</image_id>
      </disk>
    </disk_attachment>
  </disk_attachments>
</snapshot>
EOF

curl -s -X POST -k -H "$H1" -H "$H2" -H "$H3" $URL/vms/$VM_ID/snapshots --data @/tmp/post_snapshot.xml -o /tmp/snapshot.xml
sleep 1

## loop check status of snapshot
while true
do
	curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" $URL/vms/$VM_ID/snapshots --data "$SNAPSHOT_DATA" -o /tmp/snapshot_status.xml
	echo -n .
	snapshot_status2 $SNAPSHOT_NAME
	if [[ $? == 1 ]] 
	then 
		echo
		echo -e "${RED}ERRORE ${NC}$VM"
		exit 1
	fi

	sleep 1
done
echo

#SNAPSHOT_ID=$(cat /tmp/snapshot.xml | grep "snapshot href" | sed -e 's/^.*id="\(.*\)">/\1/')
SNAPSHOT_ID=$(get_snapshot_id $SNAPSHOT_NAME)
[ -f /tmp/disks.xml ] && rm -f /tmp/disks.xml
		
# get disk id 
curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" $URL/vms/$VM_ID/snapshots/$SNAPSHOT_ID/disks -o /tmp/disks.xml

# attach disks id to backup vm
DISKS_ID=$(xml2 </tmp/disks.xml | egrep -e '/disks/disk/@id=' | sed -e 's/^.*=\(.*\)/\1/' )
for DISK_ID in $DISKS_ID
do
	DISKATTACHMENT_DATA="<disk_attachment> <active>true</active> <interface>virtio_scsi</interface> <disk id=\"$DISK_ID\" > <snapshot id=\"$SNAPSHOT_ID\" /> </disk> </disk_attachment>"
	DISK_NAME=$(get_disk_name_by_id "$DISK_ID")
	echo -e "${GREEN}ATTACH DISK $NC $DISK_NAME"
	curl -s -X POST -k -H "$H1" -H "$H2" -H "$H3" $URL/vms/$BACKUP_VM_ID/diskattachments/ --data "$DISKATTACHMENT_DATA" -o /dev/null


	## backup procedure
	#DEV=$(dmesg  | grep 'Attached SCSI disk'| grep -v sda | awk '{print $5}' | grep -v Attached | sed -e 's/\[//' -e 's/\]//'| sort | uniq)

	sleep 5
	DEV=$(ls -1 /dev/sd? | grep -v sda)
	for DISK in $DEV
	do
		if [ -e ${DISK} ]
		then
			[ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR
			dd if=${DISK} of=${BACKUP_DIR}/${DISK_NAME} bs=32k status=progress
			sleep 3
		fi
	done

	echo -e "${GREEN}DETACH DISK $NC"
	curl -s -X DELETE -k -H "$H1" -H "$H2" -H "$H3" $URL/vms/$BACKUP_VM_ID/diskattachments/$DISK_ID -o /dev/null
done

echo -e "${GREEN}REMOVE SNAPSHOST $NC"
curl -s -X DELETE -k -H "$H1" -H "$H2" -H "$H3"  $URL/vms/$VM_ID/snapshots/$SNAPSHOT_ID -o /dev/null
