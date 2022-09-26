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
	[ -f /tmp/vms.out ] && rm -f /tmp/vms.out
	curl -sk -X GET -H "$H1" -H "$H2" -H "$H3" $URL/vms/ -o /tmp/vms.out
	for VM in $(cat /tmp/vms.out | xml2 | grep '/vms/vm/name=')
	do
		echo ${VM/\/vms\/vm\/name\=/}
	done
}
