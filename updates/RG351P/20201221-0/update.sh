#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12212020" ]; then

	printf "\nReadd PPSSPPSDL and keep original PPSSPPGO\nAdd glide64mk2 plugin for mupen64plus\nUpdate lzdoom.ini to support Heretic, Hexen, Strife, and Chex Quest...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12212020/arkosupdate12212020.zip -O /home/ark/arkosupdate12212020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12212020.zip" ]; then
		cp -r -f -v /opt/ppsspp /opt/ppssppgo | tee -a "$LOG_FILE"
		cp -f -v /roms/psp/ppsspp/PSP/SYSTEM/ppsspp.ini /roms/psp/ppsspp/PSP/SYSTEM/ppsspp.ini.go
		touch /home/ark/.config/.update12212020
		sudo unzip -X -o /home/ark/arkosupdate12212020.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12212020.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12212020" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
fi
