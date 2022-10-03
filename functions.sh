## return vm id 
get_vm_id () {
	VM_NAME=$1
	[ -f /tmp/vms.xml ] && rm -f /tmp/vms.xml
	curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" $URL/vms/ -o /tmp/vms.xml
	A=0
	for LINE in $(xml2 < /tmp/vms.xml | egrep -e '/vms/vm/@id=' -e '/vms/vm/name=' | sed -e 's/^.*=\(.*\)/\1/' | paste -sd";\n" | grep -v HostedEngine)
	do
		IFS=';'
		read -ra ATTR <<< "$LINE"
		if [[ $VM_NAME == ${ATTR[1]} ]]
		then
			echo ${ATTR[0]}
		fi
	done
}

get_boot_disk_id(){
	[ -f /tmp/boot_disk.xml ] && rm -f /tmp/boot_disk.xml
	curl -sk -X GET -H "$H1" -H "$H2" -H "$H3" $URL/vms/$1/diskattachments -o /tmp/boot_disk.xml
	echo $(xml2 </tmp/boot_disk.xml | egrep -e '/disk_attachments/disk_attachment/@id=' -e '/disk_attachments/disk_attachment/bootable=' |  sed -e 's/^.*=\(.*\)/\1/' | paste -sd ';\n' | egrep 'true' | cut -d';' -f1)
}

get_disk_id(){
        [ -f /tmp/disks.xml ] && rm -f /tmp/disks.xml
        curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" $URL/disks -o /tmp/disks.xml
	echo $(xml2 </tmp/disks.xml | egrep -e '/disks/disk/name=' -e '/disks/disk/image_id=' | sed -e 's/^.*=\(.*\)/\1/' | paste -sd ';\n' | egrep "$1;" | cut -d';' -f2 )
}

## get disk name using the id
get_disk_name_by_id() {
        [ -f /tmp/disks.out ] && rm -f /tmp/disks.out
        curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" -i $URL/disks -o /tmp/disks.out
        ITER=0
        FILE=( $( cat /tmp/disks.out ) )
        for LINE in ${FILE[@]}
        do
                ITER=$((ITER+1))
                if [[ $LINE =~ $1 ]]
                then
                        for LINE2 in ${FILE[@]:$ITER}
                        do
                                if [[ $LINE2 =~ "<name>" ]]
                                then
                                        DISK_NAME=$LINE2
                                        break 2
                                fi
                        done
                fi
        done
        DISK_NAME=${DISK_NAME/<name>/}
        DISK_NAME=${DISK_NAME/<\/name>/}
        echo $DISK_NAME
}

get_snapshot_id() {
	for LINE in $(cat /tmp/snapshot_status.xml | xml2  | egrep -e '/snapshots/snapshot/@id=' -e '/snapshots/snapshot/description=' | sed -e 's/^.*=\(.*\)/\1/' | paste -sd";\n" | grep -v 'Active VM')
	do
		IFS=';'
		read -ra SNAP_ATTR <<< "$LINE"
		if [[ ${SNAP_ATTR[1]} == $1 ]]
		then
			echo ${SNAP_ATTR[0]}
		fi
	done
}

snapshot_status2() {
	LINES=$(cat /tmp/snapshot_status.xml | xml2 | egrep -e '/snapshots/snapshot/description=' -e '/snapshots/snapshot/snapshot_status' | egrep -A1 "$1$")
		if [[ -z $LINES ]]
		then
			return 1
		fi
	for LINE in $LINES
	do

		if [[ $LINE =~ 'snapshot_status=ok' ]]
		then
			break 2
		fi
	done
}

## check status of snapshot
snapshot_status() {
	ITER=0
	FILE=( $( cat /tmp/snapshot_status.xml ) )
	for LINE in ${FILE[@]}
	do
		ITER=$((ITER+1))
		if [[ $LINE =~ $1 ]]
		then
			for LINE2 in ${FILE[@]:$ITER}
			do
				if [ $LINE2 == '<snapshot_status>ok</snapshot_status>' ]
				then
					break 3
				fi
			done
		fi
	done
}
get_all_vms(){
	[ -f /tmp/vms.xml ] && rm -f /tmp/vms.xml
	curl -sk -X GET -H "$H1" -H "$H2" -H "$H3" $URL/vms/ -o /tmp/vms.xml
	for VM in $(xml2 </tmp/vms.xml | egrep '/vms/vm/name=' | egrep -v -e 'HostedEngine' -e "$BACKUP_VM_NAME" | sed -e 's/^.*=\(.*\)/\1/')
	do
		echo ${VM/\/vms\/vm\/name\=/}
	done
}

get_all_vms_cluster(){

	[ -f /tmp/vms.xml ] && rm -f /tmp/vms.xml
	curl -sk -X GET -H "$H1" -H "$H2" -H "$H3" $URL/vms/ -o /tmp/vms.xml
	for VM in $(xml2 </tmp/vms.xml | egrep -e '/vms/vm/cluster/@id=' -e '/vms/vm/name='  | sed -e 's/^.*=\(.*\)/\1/' | paste -sd ';\n' | egrep "$1" | cut -d';' -f1 | egrep -v -e 'HostedEngine' -e $BACKUP_VM_NAME )
	do
		echo $VM
	done
}
get_cluster_id(){
	[ -f /tmp/clusters.xml ] && rm -f /tmp/clusters.xml
	curl -sk -X GET -H "$H1" -H "$H2" -H "$H3" $URL/clusters/ -o /tmp/clusters.xml
	xml2 </tmp/clusters.xml | egrep -e '/clusters/cluster/name=' -e '/clusters/cluster/@id=' | sed -e 's/^.*=\(.*\)/\1/' | paste -sd ';\n' | grep "$1$"  | cut -d';' -f1 
}
