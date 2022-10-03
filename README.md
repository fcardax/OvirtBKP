# OvirtBCK
# backup script ovirt platform in bash
# 
bash script to use rest api ovirt to make backup VM

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

the directory where the backup are stored
BACKUP_DIR=/mnt/backup

