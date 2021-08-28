#!/bin/bash
clear

UPDATE_DATE="08272021"
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

if [ ! -f "/home/ark/.config/.update07162021" ]; then

	printf "\nFix wifi toggle hotkey\nFix Atari 800,5200, and XEGS\nAdd Hotkeys Manual to Options section\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07162021/chi/arkosupdate07162021.zip -O /home/ark/arkosupdate07162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07162021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07162021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07162021.zip -d / | tee -a "$LOG_FILE"
		sudo chown ark:ark /etc/emulationstation/es_systems.cfg
		sudo rm -f -v /home/ark/arkosupdate07162021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.1" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07162021"
fi

if [ ! -f "/home/ark/.config/.update07162021-1" ]; then

	printf "\nFix wifi toggle hotkey for real this time\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07162021-1/chi/arkosupdate07162021-1.zip -O /home/ark/arkosupdate07162021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07162021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07162021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07162021-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/arkosupdate07162021-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.1.1" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07162021-1"
fi

if [ ! -f "/home/ark/.config/.update07312021" ]; then

	printf "\nFix Timezone issues\nAdd ECWolf standalone\nAdd Wolfenstein system to ES\nAdd plaidman doom loader\nAdd scanning and other changes for EasyRPG\nFix resolution for SuperTux\nFix amiberry controls\nBetter lzdoom controls\nFix Daphne and hypseus-singe\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07312021/chi/arkosupdate07312021.zip -O /home/ark/arkosupdate07312021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07312021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07312021.zip" ]; then
		mkdir -v /roms/wolf | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate07312021.zip -d / | tee -a "$LOG_FILE"
		cp -f -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07312021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<theme>doom<\/theme>/{r /home/ark/add_wolf.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i '/.ldb .LDB/s//.easyrpg .EASYRPG/' /etc/emulationstation/es_systems.cfg
		sed -i '/.wad .WAD .sh .SH/s//.wad .WAD .sh .SH .doom .DOOM/' /etc/emulationstation/es_systems.cfg
		sed -i '/supported_extensions \= /c\supported_extensions \= \"ldb|easyrpg|zip\"' /home/ark/.config/retroarch/cores/easyrpg_libretro.info
		sed -i '/\/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/easyrpg_libretro.so/s//\/usr\/local\/bin\/easyrpg.sh/' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/window_width/c\    (window_width 640)' /roms/ports/supertux/config
		sudo sed -i '/window_height/c\    (window_height 480)' /roms/ports/supertux/config
		sudo rm -f -v /home/ark/arkosupdate07312021.zip | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/add_wolf.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nChange mednafen_vb options cpu emulation to fast\n" | tee -a "$LOG_FILE"
	if [[ ! -z $(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep vb_cpu_emulation) ]]; then
	  sed -i '/vb_cpu_emulation \= /c\vb_cpu_emulation \= \"fast\"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	else
	  printf '\nvb_cpu_emulation = "fast"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	fi
	printf '\nvb_cpu_emulation = "fast"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak

	printf "\nStop symlinks from changing for aarch64 and arm32 when installing software from ubuntu repo\n" | tee -a "$LOG_FILE"
	sudo printf 'path-exclude=/usr/lib/arm-linux-gnueabihf' | sudo tee -a /etc/dpkg/dpkg.cfg.d/excludes
	sudo printf '\npath-exclude=/usr/lib/aarch64-linux-gnu' | sudo tee -a /etc/dpkg/dpkg.cfg.d/excludes

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.2" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07312021"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate Retroarch to 1.9.8\nAdd genesis_plus_gx_wide 64bit\nFix options wifi menu\nAdd PortMaster to Options/Tool section\nAdd support for online updating from China\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08272021/chi/arkosupdate08272021.zip -O /home/ark/arkosupdate08272021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08272021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08272021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.196.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.196.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate08272021.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08272021.bak | tee -a "$LOG_FILE"
		sed -i "/<core>genesis_plus_gx<\/core>/c\ \t\t\t  <core>genesis_plus_gx<\/core>\n\t\t\t  <core>genesis_plus_gx_wide<\/core>" /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/arkosupdate08272021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix scraping for Wolfenstein\n" | tee -a "$LOG_FILE"
	sed -i '/platform>wolf/c\\t\t<platform>pc<\/platform>' /etc/emulationstation/es_systems.cfg

	printf "\nFix sound volume does not restore previous saved state so it can self recover after a reboot\n" | tee -a "$LOG_FILE"
	sudo sed -i '/ConditionPathExists\=\/var\/lib\/alsa\/asound.state/c\\#ConditionPathExists\=\/var\/lib\/alsa\/asound.state' /lib/systemd/system/alsa-restore.service
	sudo systemctl daemon-reload

	printf "\nInstall fonts-noto-cjk to fix Retroarch Korean language and add dialog for wifi menu\n" | tee -a "$LOG_FILE"
	sudo apt -y update | tee -a "$LOG_FILE"
	sudo apt -y install fonts-noto-cjk dialog | tee -a "$LOG_FILE"

	printf "\nRemove old cache and backup folder files from var folder\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	
	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.3" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187	
fi