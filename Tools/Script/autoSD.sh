#!/bin/bash

#script to auto make fdisk partition

#check the input parameters
#if [$# -ne 1]; then
#   echo "Usage: $0 <devide>"
#   exit 1
#fi

#if [ $# -eq 0 ]; then
#    echo "input is NULL"
#    MODE=-t
#    OPT=100
#else
#    echo "input is not NULL"
#    MODE="$1"
#    OPT="$2"
#fi 

DISK=/dev/mmcblk0
PART_START=2000000
PART_SIZE=1G

#now we use fdisk to manage our sd card, this need root access
#DEVICE=$1

#step
# n -> p -> default -> 2000000 -> +1G ->w -> mkfs.ext4 /dev/mmcblk0p3

#create new parition for the sd card
{
    echo n #new a partition
    echo p #primary partition
    echo   #primary partition
    echo $PART_START #start position (default the lasgt position)
    echo +$PART_SIZE #end position (default size is 1G)
    echo w #write into sd card
} | fdisk $DISK

#acquire the sd card name, usually the last position
PARTITION=$(ls $(DISK)* | tail -1)

echo "partition is $PARTITION"

#format the partition to ext4 file system
mkfs.ext4 $PARTITION

#create a folder for the mount directory
mkdir -p /mnt/data

#add auto boot for mount this partition
echo "$PARTITION    /mnt/data   ext4    rw,sync 1   0" >> /etc/fstab

#list the content
cat /etc/fstab

#mount the partition
mount -a

#fot test
touch /mnt/data/testfile

#echo hello test to test the mnt partition
echo "hello test" > /mnt/data/testfile

#success
echo "completed script and save the change"

#add permissions for script
#chmod +x autoSD.sh