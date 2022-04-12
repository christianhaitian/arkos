#!/bin/bash
clear

UPDATE_DATE="04122022"
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

LOCATION="http://gitcdn.link/cdn/christianhaitian/arkos/main"
ISITCHINA="$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | grep -Po '"country":.*?[^\\]"')"

if [ "$ISITCHINA" = "\"country\":\"China\"" ]; then
  printf "\n\nSwitching to China server for updates.\n\n" | tee -a "$LOG_FILE"
  LOCATION="https://raw.sevencdn.com/christianhaitian/arkos/main"
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

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nAdd Dreamcast widescreen mode for retrorun and retrorun32\nFix gzdoom crashing\nAdd pcsx_rearmed_peops as a selectable core for psx\nFix China repo setting for future ArkOS updates\nRemove China repo settings for retroarch core updates\nFix osk screen size\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04122022/arkosupdate04122022.zip -O /home/ark/arkosupdate04122022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04122022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04122022.zip" ]; then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04122022.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate04122022.zip -d / | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/ | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /home/ark/.config/gzdoom/ | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /etc/emulationstation/ | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04122022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix retroarch core repo if in china\n" | tee -a "$LOG_FILE"
	repo=$(grep "139.196.213.206" ~/.config/retroarch/retroarch.cfg | tr -d '\0')
	if [ ! -z "$repo" ]; then
	  sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg
	  sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg
	  sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg.bak
	  sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg.bak
	  printf "\nRetroarch core repos have been changed to github\n" | tee -a "$LOG_FILE"
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
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187
fi