# OvirtBCK
# backup script ovirt platform in bash
# 
Using rest api ovirt to make backup VM in bash language
with curl and xml2 tools

INSTALL
yum install xml2

cd /opt/
git clone https://github.com/fcardax/OvirtBKP

USAGE
vm_backup.sh vm-name

EDIT
vm_backup.conf 

Replace URL with you engine
URL="https://engine.ovirt.local/ovirt-engine/api/"


## vm id backup and vm name
Replace BACKUP_VM_ID with id of you backup vm and the vm name 
BACKUP_VM_ID="806823fa-afee-4a75-bda8-c3e1c5923762"
BACKUP_VM_NAME="vm_name"

you can use the function get_vm_id to fetch the id of VM, or you can see directly on the ovirt engine web gui
example:
. vm_backup.conf
. functions.sh

get_vm_id backup-vm-name
the output will be the UUID of the vm

the directory where the backup are stored
BACKUP_DIR=/mnt/backup


## Backup all cluster's vms
vm_backup_cluster.sh -d -n -c CLUSTER-NAME

-d run-dry
-n all disks
-b only boot disk
