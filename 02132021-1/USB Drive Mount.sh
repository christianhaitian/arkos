#!/bin/bash
if [ ! -d "/mnt/usbdrive/" ]; then
	sudo mkdir /mnt/usbdrive
fi

sudo mount -t vfat /dev/sda1 /mnt/usbdrive -o uid=1000
status=$?

if test $status -eq 0
then
	printf "\n\n\e[32mFat/Fat32 USB drive is mounted to /mnt/usbdrive...\n"
	printf "\033[0m"
	sleep 3
else
	sudo mount -t exfat /dev/sda1 /mnt/usbdrive -o uid=1000
	status=$?
	if test $status -eq 0
	then
		printf "\n\n\e[32mExfat USB drive is mounted to /mnt/usbdrive...\n"
		printf "\033[0m"
		sleep 3
	else
		sudo mount -t ntfs-3g /dev/sda1 /mnt/usbdrive -o uid=1000
		status=$?
		if test $status -eq 0
		then
			printf "\n\n\e[32mExfat USB drive is mounted to /mnt/usbdrive...\n"
			printf "\033[0m"
			sleep 3
		else
			printf "\n\n\e[91mCould not find a Fat, Fat32, Exfat, or NTFS based USB drive to mount...\n"
			printf "\033[0m"
			sleep 3
		fi
	fi
fi