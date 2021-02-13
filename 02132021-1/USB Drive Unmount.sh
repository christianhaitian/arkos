#!/bin/bash
sudo umount /mnt/usbdrive
status=$?
if test $status -eq 0
then
	printf "\n\n\e[32mUSB drive has been safely unmounted from /mnt/usbdrive...\n"
	printf "\033[0m"
	sleep 3
else
	printf "\n\n\e[91mThere was no USB drive available to unmount from /mnt/usbdrive...\n"
	printf "\033[0m"
	sleep 3
fi