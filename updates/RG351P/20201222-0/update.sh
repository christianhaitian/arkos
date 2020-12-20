#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ -f "/home/ark/.config/.update12222020" ]; then
	printf "\nAdd support for half-life\nAdd battery life indicator\nAdd PoP port\nAdd dosbox-pure\nFix solarus exit daemon\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12222020/arkosupdate12222020.zip -O /home/ark/arkosupdate12222020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12222020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12222020.zip -d / | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		sudo systemctl enable batt_led.service
		sudo systemctl start batt_led.service
		sudo rm -v /home/ark/arkosupdate12222020.zip | tee -a "$LOG_FILE"
		sudo wget https://github.com/christianhaitian/arkos/raw/main/12222020/XASH3D_LICENSE -O /roms/ports/Half-Life/XASH3D_LICENSE -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12222020" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	touch "/home/ark/.config/.update12222020"
fi
