#!/bin/bash

# Make an EBS volume available

#
# find disk connected
#

echo "Check connected disks"

# lsblk
# NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# xvda    202:0    0   20G  0 disk
# └─xvda1 202:1    0   20G  0 part /
# xvdh    202:112  0  120G  0 disk

# DISK_NAME=xvdh
DISK_NAME=$(lsblk | tail -n1 | awk '{print $1}')
DISK_PATH="/dev/$DISK_NAME"

echo "Found disk $DISK_PATH"

echo "Check whether $DISK_PATH has FS created"

#
# check do we need to create FS on the disk
#

# sudo file -s /dev/$DISK_NAME
# /dev/xvdh: data

DISK_INFO=$(sudo file -s $DISK_PATH | awk '{print $2}')

if [ "$DISK_INFO" == "data" ]; then
	echo "Need to create FS on the disk"
	echo "Please, wait"
	sudo mkfs -t ext4 $DISK_PATH

	echo "Ensure disk info"
	sudo file -s $DISK_PATH
else
	echo "No need to create FS, ready to mount"
fi

MOUNT_POINT="/mnt/data"

echo "Ensure mount point $MOUNT_POINT exists"
sudo mkdir -p "$MOUNT_POINT"

echo "Mount $DISK_PATH to $MOUNT_POINT"
sudo mount $DISK_PATH "$MOUNT_POINT"

echo "Make $DISK_PATH mounted on each boot"


echo "Check already mounted"
FSTAB_ENTRY=$(cat /etc/fstab | grep "$MOUNT_POINT" | wc -l)

if [ $FSTAB_ENTRY == "0" ]; then
	echo "No mount point detected"
	echo "Backup fstab as /etc/fstab.orig.YEAR-MONTH-DAY-HOUR-MINUTE-SECOND"
	sudo cp /etc/fstab /etc/fstab.orig.$(date +%Y-%m-%d-%H-%M-%S)

	sudo bash -c "echo \"$DISK_PATH	$MOUNT_POINT	ext4	defaults,nofail	0	2\" >> /etc/fstab"
else
	echo "Mount point detected - ready to use"
fi



