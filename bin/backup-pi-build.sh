#!/bin/bash
SH_VERSION=1.0.0
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: backup-pi.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi
echo -e "\nBAP Backup utility \n"
# Where to backup
BACKUP_PATH="/tmp"
MOUNT_POINT="/media/usb"

# What to backup. remember the \ for new line continuation last line has none
backup_files="${HOME}/pi-build \
${HOME}/.config \
${HOME}/.fl* \
${HOME}/.xastir \
${HOME}/.tqsl \
${HOME}/.wine/drive_c/VARA/VARA.ini \
${HOME}/Desktop \
${HOME}/qsstv \
${HOME}/patmenu2/config \
${HOME}/.local/share/WSJT-X \
${HOME}/.local/share/JS8Call \
${HOME}/.local/share/pat \
${HOME}/.conkyrc \
${HOME}/*.*"

# archive filename
day=$(date +%A)
hostname=$(hostname -s)
archive_file="BAP-Backup-$hostname-$day.tgz"

#make some extra backup notes abnout the repo we have currently
echo -e "\n\nBAP Backup Log for $($BACKUP_PATH/$archive_file)"  >> ${HOME}/BAP-backup-log.txt
echo -e "$(git show --pretty=medium | head -7)\n" >> ${HOME}/BAP-backup-log.txt
echo -e "$(git branch)\n" >> ${HOME}/BAP-backup-log.txt

# Print start status message.
echo -e "\nBacking up $backup_files to $BACKUP_PATH/$archive_file \n\n"
date

# Backup the files using tar.
tar czf $BACKUP_PATH/$archive_file $backup_files

echo -e "\nBackup finished\n"
# Long listing of files in $BACKUP_PATH to check file sizes.
ls -lh $BACKUP_PATH/$archive_file

#handle archive or off pi copy

#check if mount point exists
if [ ! -d “MOUNT_POINT” ] ; then 
	echo -e "\nUSB not found cant copy file off SD-CARD"
    echo -e "\nOptional edit backup-bap script to scp off"
    exit 1
    #scp $BACKUP_PATH/$archive_file username@to_host:/remote/directory/
else
    echo -e "\nUSB found"
    cp $BACKUP_PATH/$archive_file $MOUNT_POINT
    
fi

exit 0

