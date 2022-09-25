## return vm id 
get_vm_id () {

	VM_NAME=$1
	[ -f /tmp/vms.out ] && rm -f /tmp/vms.out
	curl -s -X GET -k -H "$H1" -H "$H2" -H "$H3" -i $URL/vms/ -o /tmp/vms.out

	for LINE in "$(cat /tmp/vms.out | egrep -e '<name>' -e 'vm href' | egrep -v 'CEST|GMT|Europe|UTC|EDT|internal-authz|ens3' | paste -d " "  - - |sed -e 's/.*id="\(.*\)"> /\1/' -e 's/<name>//' -e 's/<\/name>//')"
	do
		read -ra VM_ATTR <<<"$LINE"
		if [[ ${VM_ATTR[1]} == $VM_NAME ]]
		then
			echo "${VM_ATTR[0]}"
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
                                        break 3
                                fi
                        done
                fi
        done
        DISK_NAME=${DISK_NAME/<name>/}
        DISK_NAME=${DISK_NAME/<\/name>/}
        echo $DISK_NAME
}

## check status of snapshot
snapshot_status() {
	ITER=0
	FILE=( $( cat /tmp/snapshot_status.out ) )
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
