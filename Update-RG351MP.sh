#!/bin/bash
clear
UPDATE_DATE="10012021"
LOG_FILE="/home/ark/update$UPDATE_DATE.log"
UPDATE_DONE="/home/ark/.config/.update$UPDATE_DATE"

if [ -f "$UPDATE_DONE" ]; then
	msgbox "No more updates available.  Check back later."
	rm -- "$0"
	exit 187
fi

if [ -f "$LOG_FILE" ]; then
	sudo rm "$LOG_FILE"
fi

LOCATION="http://gitcdn.link/cdn/christianhaitian/arkos/main"
ISITCHINA="$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | grep -Po '"country":.*?[^\\]"')"

if [ "$ISITCHINA" = "\"country\":\"China\"" ]; then
  printf "\n\nSwitching to China server for updates.\n\n" | tee -a "$LOG_FILE"
  LOCATION="http://139.196.213.206/arkos"
fi

sudo msgbox "ONCE YOU PROCEED WITH THIS UPDATE SCRIPT, DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT IN A STATE OF UNUSABILITY.  Make sure you've created a backup of this sd card as a precaution in case something goes very wrong with this process.  You've been warned!  Type OK in the next screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

if [ "$my_var" != "OK" ] && [ "$my_var" != "ok" ]; then
  sudo msgbox "You didn't type OK.  This script will exit now and no changes have been made from this process."
  printf "You didn't type OK.  This script will exit now and no changes have been made from this process." | tee -a "$LOG_FILE"
  exit 187
fi

c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/devices/platform/backlight/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update09302021" ]; then

	printf "\nAdd ability to switch between Tony screen timings and original screen timings\nFixed Brightness reading\nFix update osk\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09302021/arkosupdate09302021.zip -O /home/ark/arkosupdate09302021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09302021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate09302021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate09302021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate09302021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 Test Release 1.1" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09302021"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate mgba_rumble core, pcsx-rearmed, and parallel-n64 cores and unlock them for future updating\nFix savestate loading and saving for standalone mupen64plus\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10012021/arkosupdate10012021.zip -O /home/ark/arkosupdate10012021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10012021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10012021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate10012021.zip -d / | tee -a "$LOG_FILE"
		sudo rm /home/ark/.config/retroarch/cores/*.lck
		sudo rm /home/ark/.config/retroarch32/cores/*.lck
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sed -i '/roms22/s//roms2/g' /home/ark/.config/mupen64plus/mupen64plus.cfg
		else
		  sed -i '/roms2/s//roms/g' /home/ark/.config/mupen64plus/mupen64plus.cfg
		fi
		sudo rm -v /home/ark/arkosupdate10012021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 Test Release 1.2" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A or B button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187
fi