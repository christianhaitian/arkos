#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12192020" ]; then

	printf "\nUpdate lzdoom to swap OK and Cancel buttons\nUpdated PPSSPPSDL to version 1.10.3 version with batocera speedup\nCenter Solarus" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12192020/arkosupdate12192020.zip -O /home/ark/arkosupdate12192020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12192020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12192020.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12192020.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	sudo rm -v /opt/solarus/libsolarus.so.1 | tee -a "$LOG_FILE"
	sudo rm -v /opt/solarus/libsolarus.so | tee -a "$LOG_FILE"
	sudo ln -sfv /opt/solarus/libsolarus.so.1.7.0 /opt/solarus/libsolarus.so.1 | tee -a "$LOG_FILE"
	sudo ln -sfv /opt/solarus/libsolarus.so.1.7.0 /opt/solarus/libsolarus.so | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/solarus/libsolarus* | tee -a "$LOG_FILE"
	sudo chown ark:ark -v /opt/solarus/libsolarus* | tee -a "$LOG_FILE"

	if [ -f "/home/ark/.config/.update12192020" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
fi
