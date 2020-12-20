#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12182020" ]; then

	printf "\nAdd support for RetroArch text-to-speech accessibility feature...\n" | tee -a "$LOG_FILE"
	sudo apt update -y && sudo apt -y install espeak espeak-data | tee -a "$LOG_FILE"
	
	printf "\nAdd Tic-80 to the ES system menu\nAdd VVVVVV port" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12182020/arkosupdate12182020.zip -O /home/ark/arkosupdate12182020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12182020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12182020.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12182020.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	if [ -f "/home/ark/.config/.update12182020" ]; then
		printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
fi
