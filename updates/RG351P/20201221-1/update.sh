#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12212020-1" ]; then

	printf "\nFix Emulationstation menu for last update\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12212020-1/arkosupdate12212020-1.zip -O /home/ark/arkosupdate12212020-1.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12212020-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12212020-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12212020-1.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12212020-1" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
fi
