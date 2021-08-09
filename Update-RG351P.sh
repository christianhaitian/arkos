#!/bin/bash
clear

UPDATE_DATE="07152021-1"
LOG_FILE="/home/ark/update$UPDATE_DATE.log"
UPDATE_DONE="/home/ark/.config/.update$UPDATE_DATE"

if [ -f "$UPDATE_DONE" ] && [ -f "/home/ark/.config/.kernelupdate02032021" ]; then
	msgbox "No more updates available.  Check back later."
	rm -- "$0"
	exit 187
fi

if [ -f "$LOG_FILE" ]; then
	sudo rm "$LOG_FILE"
fi

c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/devices/platform/backlight/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &



if [ ! -f "/home/ark/.config/.update07152021" ]; then

	printf "\nRetroArch 1.9.6 and add GX4000\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate https://github.com/wummle/arkos/raw/main/07152021/rg351p/arkosupdate07152021.zip -O /home/ark/arkosupdate07152021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07152021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07152021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07152021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate05012021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect final current version of ArkOS for the 351 P/M \n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 351P/M wummle" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07152021"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect final current version of ArkOS for the 351 P/M \n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 351P/M wummle gaming" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187	
fi