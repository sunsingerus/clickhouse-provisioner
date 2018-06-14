#!/bin/bash

# Make an EBS volume available

#
# find disk connected
#

# lsblk
# NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
# xvda    202:0    0   20G  0 disk
# └─xvda1 202:1    0   20G  0 part /
# xvdh    202:112  0  120G  0 disk

# DISK_NAME=xvdh
DISK_NAME=$(lsblk | tail -n1 | awk '{print $1}')

echo "Found disk /dev/$DISK_NAME"

echo "Check whether /dev/$DISK_NAME has FS created"

#
# check do we need to create FS on the disk
#

# sudo file -s /dev/$DISK_NAME
# /dev/xvdh: data

DISK_INFO=$(sudo file -s /dev/$DISK_NAME | awk '{print $2}')

if [ "$DISK_INFO" == "data" ]; then
	echo "Need to create FS on the disk"
	echo "Please, wait"
	sudo mkfs -t ext4 /dev/$DISK_NAME

	echo "Ensure disk info"
	sudo file -s /dev/$DISK_NAME
else
	echo "No need to create FS, ready to mount"
fi

MOUNT_POINT="/mnt/data"

echo "Ensure mount point $MOUNT_POINT exists"
sudo mkdir -p "$MOUNT_POINT"

echo "Mount /dev/$DISK_NAME to $MOUNT_POINT"
sudo mount /dev/$DISK_NAME "$MOUNT_POINT"

