#!/bin/bash

bkp_name=$1
bkp_mount_point=/mnt/backup
bkp_archive_dir=${bkp_mount_point}/archive

PATH=${HOME}/bin:${PATH}
horcrux_bin=${HOME}/bin/horcrux
umount_on_exit=0

if [ -z "$bkp_name" ]; then
	echo "Missing parameter <backup-name>"
	exit 1
fi

# Check that the NAS share is mounted
grep -q '$bkp_mount_point' /proc/mounts
mounted=$?

# Try to mount it
if [[ "$mounted" != "0" ]]; then
	sudo /bin/mount $bkp_mount_point
	mounted=$?
	if [[ "$mounted" != "0" ]]; then
		echo "Could not mount $bkp_mount_point, exiting"
		exit 2
	else
		umount_on_exit=1
	fi
fi

# Check that we have the "archive" directory
if [ -d "$bkp_archive_dir" ]; then
    if [ -x "$horcrux_bin" ]; then
        horcrux auto $bkp_name
	else
		echo "Missing horcrux binary in $horcrux_bin, exiting"
		exit 4
    fi
else
	echo "Missing archive directory in $bkp_archive_dir, bailing out"
	exit 3
fi

# Umount the NAS share
if [[ "$umount_on_exit" == "1" ]]; then
	sudo /bin/umount $bkp_mount_point
fi
