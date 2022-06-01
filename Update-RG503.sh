#!/bin/bash
clear
UPDATE_DATE="06012022"
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

c_brightness="$(cat /sys/class/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/class/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nAdd Bluetooth Manager\nBluetooth fixes\nFix Neo Geo Pocket and Neo Geo Pocket Color not launching\nAdd Bluetooth identification to Emulationstation start menu\nAdd Bluetooth trigger to F button at bottom of device\nFix exfat permissions issue\nFix .ecwolf files not recognized for Wolfenstein\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06012022/arkosupdate06012022.zip -O /home/ark/arkosupdate06012022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06012022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06012022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06012022.zip -d / | tee -a "$LOG_FILE"
		sudo mv /etc/systemd/system/bluetooth.service /etc/systemd/system/enable_bluetooth.service
		sudo systemctl daemon-reload
		sudo systemctl restart enable_bluetooth
		sudo systemctl enable enable_bluetooth
		sudo apt update -y | tee -a "$LOG_FILE"
		sudo apt remove -y bluez | tee -a "$LOG_FILE"
		sudo apt install -y bluez | tee -a "$LOG_FILE"
		sudo systemctl restart bluetooth
		sudo systemctl enable bluetooth
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06012022.bak | tee -a "$LOG_FILE"
		if test ! -z "$(grep "mednafen_ngp_libretro.so" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		then
			cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06012022.bak | tee -a "$LOG_FILE"
			sed -i 's/<core>mednafen_ngp_libretro.so<\/core>/<core>mednafen_ngp<\/core>/' /etc/emulationstation/es_systems.cfg
		fi
		sed -i '/<extension>.wolf .WOLF/s//<extension>.wolf .WOLF .ecwolf .ECWOLF/' /etc/emulationstation/es_systems.cfg
		sudo sed -i 's/exfat defaults,auto,umask=000,noatime 0 0/exfat defaults,auto,umask=000,uid=1002,gid=1002,noatime 0 0/' /etc/fstab
		sudo sed -i 's/exfat umask=0000,iocharset=utf8,noatime 0 0/exfat umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /etc/fstab
		sudo sed -i 's/umask=0000,iocharset=utf8,noatime 0 0/umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		sudo sed -i 's/umask=0000,iocharset=utf8,noatime 0 0/umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		sudo rm -v /home/ark/arkosupdate06012022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
	  LD_LIBRARY_PATH=/usr/local/bin msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	else
	  msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	fi
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187
fi