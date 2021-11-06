#!/bin/bash
clear

UPDATE_DATE="11052021"
LOG_FILE="/home/ark/update$UPDATE_DATE.log"
UPDATE_DONE="/home/ark/.config/.update$UPDATE_DATE"

if [ -f "$UPDATE_DONE" ]; then
	LD_LIBRARY_PATH=/usr/local/bin msgbox "No more updates available.  Check back later."
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

sudo LD_LIBRARY_PATH=/usr/local/bin msgbox "ONCE YOU PROCEED WITH THIS UPDATE SCRIPT, DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT IN A STATE OF UNUSABILITY.  Make sure you've created a backup of this sd card as a precaution in case something goes very wrong with this process.  You've been warned!  Type OK in the next screen to proceed."
my_var=`LD_LIBRARY_PATH=/usr/local/bin osk "Enter OK here to proceed." | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

if [ "$my_var" != "OK" ] && [ "$my_var" != "ok" ]; then
  sudo LD_LIBRARY_PATH=/usr/local/binmsgbox "You didn't type OK.  This script will exit now and no changes have been made from this process."
  printf "You didn't type OK.  This script will exit now and no changes have been made from this process." | tee -a "$LOG_FILE"
  exit 187
fi

c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/devices/platform/backlight/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update04112021" ]; then

	printf "\nChange kernel and dtb\nUpdate ogage\nUpdate perfmax to not remove .asoundrc\nUpdate dreamcast.sh atomiswave.sh naomi.sh openborkeydemon.py ppssppkeydemon.py solarushotkeydemon.py pico8keydemon.py ti99keydemon.py\nUpdated Switch to SD2 for Roms.sh and Switch to main SD for Roms.sh\nRemove rg351_gpio.sh from crontab" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04112021/rg351v/arkosupdate04112021.zip -O /home/ark/arkosupdate04112021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04112021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04112021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04112021.zip -d / | tee -a "$LOG_FILE"
		sudo depmod 4.4.189
		sudo rm -v /home/ark/arkosupdate04112021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.1)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04112021"
fi

if [ ! -f "/home/ark/.config/.update04132021" ]; then

	printf "\nUpdate wifi.sh network info.sh change password.sh to fix no controls from last kernel change\nFix potential Daphne, TI99, and SCUMMVM not launching issue\nFixed PPSSPP reversed analog menu controls\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04132021/rg351v/arkosupdate04132021.zip -O /home/ark/arkosupdate04132021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04132021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04132021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04132021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04132021.zip | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.2)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04132021"
fi

if [ ! -f "/home/ark/.config/.update04152021" ]; then

	printf "\nUpdate scummvm to fix AGS not loading\nUpdate perfmax and perfnorm scripts to fix screen flashing issue on loading and returning from games.\nUpdate Emulationstation to not use Batocera's scraping ID\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04152021/rg351v/arkosupdate04152021.zip -O /home/ark/arkosupdate04152021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04152021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04152021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04152021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04152021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.3)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04152021"
fi

if [ ! -f "/home/ark/.config/.update04162021" ]; then

	printf "\nUpdate to add support for launching retrorun Dreamcast in 640 mode by holding A\nFix no controls for retrorun saturn\nUpdated libgo2.so libs\nUpdate Enable Remote Services script to show assigned IP and 5s pause\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04162021/rg351v/arkosupdate04162021.zip -O /home/ark/arkosupdate04162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04162021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04162021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04162021.zip -d / | tee -a "$LOG_FILE"
        if [ ! -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
           sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/dreamcast.sh
		fi
		sudo rm -v /home/ark/arkosupdate04162021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.4)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04162021"
fi

if [ ! -f "/home/ark/.config/.update04172021" ]; then

	printf "\nFix issue with being able to consistently launch dreamcast in 640x480\n" | tee -a "$LOG_FILE"
	sudo sed -i '/#!\/bin\/bash/s//#!\/bin\/bash\n\nsudo chmod 666 \/dev\/tty1/' /usr/local/bin/dreamcast.sh
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.5)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04172021"
fi

if [ ! -f "/home/ark/.config/.update04172021-1" ]; then

	printf "\nUpdate to add brightness control using F+Vol Up+Dn buttons for better gradual control\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04172021-1/rg351v/arkosupdate04172021-1.zip -O /home/ark/arkosupdate04172021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04172021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04172021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04172021-1.zip -d / | tee -a "$LOG_FILE"
		sudo systemctl enable oga_events
		sudo systemctl restart oga_events
		sudo rm -v /home/ark/arkosupdate04172021-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.5.1)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04172021-1"
fi

if [ ! -f "/home/ark/.config/.update04182021" ]; then

	printf "\nUpdate to add missing dreamcast.sh script\nAdd Video Player\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04182021/rg351v/arkosupdate04182021.zip -O /home/ark/arkosupdate04182021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04182021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04182021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04182021.zip -d / | tee -a "$LOG_FILE"
		sudo apt update -y && sudo apt -y install ffmpeg | tee -a "$LOG_FILE"
		if [ ! -d "/roms/videos/" ]; then
			sudo mkdir -v /roms/videos | tee -a "$LOG_FILE"
		fi
		if [ "$(ls -A /roms2)" ]; then
			sudo mkdir -v /roms2/videos | tee -a "$LOG_FILE"
		fi
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04182021.bak | tee -a "$LOG_FILE"
		sudo sed -i -e '/<theme>uzebox<\/theme>/{r /home/ark/add_videos.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sed -i '/<path>\/roms\//s//<path>\/roms2\//' /etc/emulationstation/es_systems.cfg
		fi
		sudo rm -v /home/ark/add_videos.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04182021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.6)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04182021"
fi

if [ ! -f "/home/ark/.config/.update04222021" ]; then

	printf "\nAdd UAE4arm for Amiga and Amiga32\nAdd potator core for Watara Supervision\nAdd Megadrive MSU\nFixed switch to main and switch to sd2 scripts\nFix Daphne not loading from SD2\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04222021/rg351v/arkosupdate04222021.zip -O /home/ark/arkosupdate04222021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04222021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04222021.zip" ]; then
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04182021.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate04222021.zip -d / | tee -a "$LOG_FILE"
		if [ ! -d "/roms/supervision/" ]; then
			sudo mkdir -v /roms/supervision | tee -a "$LOG_FILE"
		fi
		if [ "$(ls -A /roms2)" ]; then
			sudo mkdir -v /roms2/supervision | tee -a "$LOG_FILE"
		fi
		if [ ! -d "/roms/msumd/" ]; then
			sudo mkdir -v /roms/msumd | tee -a "$LOG_FILE"
		fi
		if [ "$(ls -A /roms2)" ]; then
			sudo mkdir -v /roms2/msumd | tee -a "$LOG_FILE"
		fi
	    if [ ! -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sed -i '/<path>\/roms2\//s//<path>\/roms\//' /etc/emulationstation/es_systems.cfg
		fi
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate04222021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.7)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04222021"
fi

if [ ! -f "/home/ark/.config/.update04232021" ]; then

	printf "\nAdded ppsspp-stock emulator as default\nAdded ability to restore retroarch and retroarch32 default settings\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04232021/rg351v/arkosupdate04232021.zip -O /home/ark/arkosupdate04232021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04232021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04232021.zip" ]; then
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04232021.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate04232021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04232021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.8)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04232021"
fi

if [ ! -f "/home/ark/.config/.update04242021" ]; then

	printf "\nForgot to include a check of whether someone is using a second sd card or not and adjust es_systems.cfg accordingly\n" | tee -a "$LOG_FILE"
	if [ ! -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
	  sed -i '/<path>\/roms2\//s//<path>\/roms\//' /etc/emulationstation/es_systems.cfg
	fi
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.8.1)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04242021"
fi

if [ ! -f "/home/ark/.config/.update04242021-1" ]; then

	printf "\nAdd ability to toggle wifi via F+L3\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04242021-1/rg351v/arkosupdate04242021-1.zip -O /home/ark/arkosupdate04242021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04242021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04242021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04242021-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04242021-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS OaD (Test Release 1.8.2)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04242021-1"
fi

if [ ! -f "/home/ark/.config/.update04282021" ]; then

	printf "\nImprove stability of global hotkeys\nAdd Fix Global Hotkeys script to /opt/Advanced menu\nRemove some unneeded 32bit sdl2 libraries that cause linker issues\nUpdate retrorun and retrorun32 to hopefully minimize a potential memory leak issue\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04282021/rg351v/arkosupdate04282021.zip -O /home/ark/arkosupdate04282021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04282021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04282021.zip" ]; then
		sudo systemctl disable oga_events
		sudo unzip -X -o /home/ark/arkosupdate04282021.zip -d / | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		sudo systemctl restart oga_events
		sudo systemctl enable oga_events
		sudo rm /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.12.0
		sudo rm /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.14.1
		sudo rm -v /home/ark/arkosupdate04282021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 1.9)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04282021"
fi

if [ ! -f "/home/ark/.config/.update04302021" ]; then

	printf "\nAdd Change LED color script to Options menu\nUpdate global hotkey app to use absolute path for brightness control\nFix filebrowser to point to right roms folder depending on primary sd in use for roms\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04302021/rg351v/arkosupdate04302021.zip -O /home/ark/arkosupdate04302021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04302021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04302021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04302021.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo pkill -e filebrowser | tee -a "$LOG_FILE"
		  filebrowser -d /home/ark/.config/filebrowser.db users update ark --scope "/roms2"
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo systemctl restart oga_events
		sudo rm -v /home/ark/arkosupdate04302021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 1.9.1)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04302021"
fi

if [ ! -f "/home/ark/.config/.update05012021" ]; then

	printf "\nAdd support for Sonic 1, 2, and CD ports\nAdd 2 second sleep to oga_events service to finally stabilize global brightness hotkeys\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05012021/rg351v/arkosupdate05012021.zip -O /home/ark/arkosupdate05012021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05012021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05012021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05012021.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -v /roms/ports/Sonic\ * /roms2/ports/. | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/sonic* /roms2/ports/ | tee -a "$LOG_FILE"
		  sudo sed -i '/roms\//s//roms2/' /roms2/ports/"Sonic 1.sh"
		  sudo sed -i '/roms\//s//roms2/' /roms2/ports/"Sonic 2.sh"
		  sudo sed -i '/roms\//s//roms2/' /roms2/ports/"Sonic CD.sh"
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo systemctl daemon-reload
		sudo systemctl restart oga_events
		sudo rm -v /home/ark/arkosupdate05012021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 2.0)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05012021"
fi

if [ ! -f "/home/ark/.config/.update05012021-1" ]; then

	printf "\nFix ports failing to load from SD2\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05012021-1/rg351v/arkosupdate05012021-1.zip -O /home/ark/arkosupdate05012021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05012021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05012021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05012021-1.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -r -v /roms/ports/Cannonball.sh /roms2/ports/Cannonball.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/OpenTyrian.sh /roms2/ports/OpenTyrian.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Quake 2.sh" /roms2/ports/"Quake 2.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/Quake.sh /roms2/ports/Quake.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Rick Dangerous.sh" /roms2/ports/"Rick Dangerous.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/SDLPoP.sh /roms2/ports/SDLPoP.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Wolfenstein 3D.sh" /roms2/ports/"Wolfenstein 3D.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -v /roms/ports/Sonic\ * /roms2/ports/. | tee -a "$LOG_FILE"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/Cannonball.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Cave Story.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/OpenTyrian.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Quake 2.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/Quake.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Rick Dangerous.sh"
		  sudo sed -i '/roms\//s//roms2\//g' /roms2/ports/SDLPoP.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Wolfenstein 3D.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Sonic 1.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Sonic 2.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Sonic CD.sh"
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate05012021-1.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 2.1)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05012021-1"

fi

if [ ! -f "/home/ark/.config/.update05032021" ]; then

	printf "\nAdd SuperTux\nAdd Mr. Boom\nAdd Dinothawr\nAdd Super Mario War\nAdd CDogs\nFix background music to load from SD2 in ES\nFix roms2 not showing in Samba when using SD2\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05032021/rg351v/arkosupdate05032021.zip -O /home/ark/arkosupdate05032021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05032021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05032021/rg351v/arkosupdate05032021.z01 -O /home/ark/arkosupdate05032021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05032021.z01 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05032021/rg351v/arkosupdate05032021.z02 -O /home/ark/arkosupdate05032021.z02 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05032021.z02 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05032021/rg351v/smwconfig.zip -O /home/ark/smwconfig.zip -a "$LOG_FILE" || rm -f /home/ark/smwconfig.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05032021.zip" ] && [ -f "/home/ark/arkosupdate05032021.z01" ] && [ -f "/home/ark/arkosupdate05032021.z02" ] && [ -f "/home/ark/smwconfig.zip" ]; then
		cd /home/ark/
		sudo apt update -y && sudo apt install -y zip | tee -a "$LOG_FILE"
		sudo zip -F arkosupdate05032021.zip --out arkosupdate.zip | tee -a "$LOG_FILE"
		sudo rm -fv arkosupdate05032021.z* | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/smwconfig.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -r -v /roms/ports/Cannonball.sh /roms2/ports/Cannonball.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/OpenTyrian.sh /roms2/ports/OpenTyrian.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Quake 2.sh" /roms2/ports/"Quake 2.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/Quake.sh /roms2/ports/Quake.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Rick Dangerous.sh" /roms2/ports/"Rick Dangerous.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/SDLPoP.sh /roms2/ports/SDLPoP.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/C-Dogs.sh /roms2/ports/C-Dogs.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/dinothawr/ /roms2/ports/ | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/Dinothawr.sh /roms2/ports/Dinothawr.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Mr. Boom.sh" /roms2/ports/"Mr. Boom.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Super Mario War.sh" /roms2/ports/"Super Mario War.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/supertux/ /roms2/ports/ | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/SuperTux.sh /roms2/ports/SuperTux.sh | tee -a "$LOG_FILE"
		  sudo cp -f -r -v /roms/ports/"Wolfenstein 3D.sh" /roms2/ports/"Wolfenstein 3D.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -v /roms/ports/Sonic\ * /roms2/ports/. | tee -a "$LOG_FILE"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/Cannonball.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Cave Story.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/OpenTyrian.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Quake 2.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/Quake.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Rick Dangerous.sh"
		  sudo sed -i '/roms\//s//roms2\//g' /roms2/ports/SDLPoP.sh
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Wolfenstein 3D.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Sonic 1.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Sonic 2.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Sonic CD.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"SuperTux.sh"
		  sudo sed -i '/roms\//s//roms2\//' /roms2/ports/"Dinothawr.sh"
		  sudo cp -f /etc/samba/smb.conf.sd2 /etc/samba/smb.conf
		  sudo pkill filebrowser
		  filebrowser -d /home/ark/.config/filebrowser.db users update ark --scope "/roms2"
		  unlink /home/ark/.emulationstation/music
		  ln -sfv /roms2/bgmusic/ /home/ark/.emulationstation/music
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/smwconfig.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "Due to the size of this update, synchronizing the data on disk with memory to be sure the update is done right." | tee -a "$LOG_FILE"
	sync
	
	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 2.2)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05032021"
fi

if [ ! -f "/home/ark/.config/.update05042021" ]; then

	printf "\nFix Atari800, 5200, and XE loading\nAdd support for EXT4 format for SD2\nIncrease default audio gain for retroarch and retroarch32\nFix default configs for Doom\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05042021/rg351v/arkosupdate05042021.zip -O /home/ark/arkosupdate05042021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05042021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05042021.zip" ]; then
		cp -f -v /home/ark/.config/lzdoom/lzdoom.ini /home/ark/.config/lzdoom/lzdoom.ini.update05042021.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate05042021.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sed -i '/roms2/s//roms/g'  /home/ark/.atari800.cfg
		  sed -i '/roms2/s//roms/g'  /home/ark/.config/retroarch/config/Atari800/retroarch_5200.cfg
		  sed -i '/roms2/s//roms/g'  /home/ark/.config/retroarch/config/Atari800/retroarch_A800.cfg
		  sed -i '/roms2/s//roms/g'  /home/ark/.config/retroarch/config/Atari800/retroarch_XEGS.cfg
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sed -i '/audio_volume \= \"-4.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch32/retroarch.cfg
		sed -i '/audio_volume \= \"0.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch/retroarch.cfg
		sed -i '/audio_volume \= \"-4.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
		sed -i '/audio_volume \= \"0.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch/retroarch.cfg.bak
		sudo rm -v /home/ark/arkosupdate05042021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 2.3)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05042021"
fi

if [ ! -f "/home/ark/.config/.update05052021" ]; then

	printf "\nUpdate Retroarch to version 1.9.2\nUpdate Dingux Commander for better screen visibility\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05052021/rg351v/arkosupdate05052021.zip -O /home/ark/arkosupdate05052021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05052021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05052021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.191.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.191.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate05052021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate05052021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 2.4)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05052021"
fi

if [ ! -f "/home/ark/.config/.update05102021" ]; then

	printf "\nAdd Hydra Castle Labyrinth port\nAdd support for Shovel Knight Treasure Trove\nUpdate wifi disable and enable to completely disable the chipset and enable chipset\nUpdate emulationstation for wifi toggle Off state text\nUpdated Switch to SD2 to fix missing text if it can't swap to SD2 and add EXT4 to missing supported SD card type\nDisable the ability for cores to be able to change video modes in retroarches\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05102021/rg351v/arkosupdate05102021.zip -O /home/ark/arkosupdate05102021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05102021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05102021.zip" ]; then
		sudo nmcli r wifi on
		sudo unzip -X -o /home/ark/arkosupdate05102021.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -v /roms/ports/"Hydra Castle Labyrinth.sh" /roms2/ports/"Hydra Castle Labyrinth.sh" | tee -a "$LOG_FILE"
		  sudo cp -f -v /roms/ports/"Shovel Knight.sh" /roms2/ports/"Shovel Knight.sh" | tee -a "$LOG_FILE"
		  sudo sed -i '/roms\//s//roms2\//g' /roms2/ports/"Shovel Knight.sh"
		  filesystem=`lsblk -no FSTYPE /dev/mmcblk1p1`
		  if [ "$filesystem" = "ext4" ]; then
		    sudo chown -R ark:ark /roms2/
		  fi
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate05102021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nDisable the ability for cores to be able to change video modes in retroarch and retroarch32\n" | tee -a "$LOG_FILE"
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch32/retroarch.cfg
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch/retroarch.cfg.bak

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS V (Test Release 2.5)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05102021"
fi

if [ ! -f "/home/ark/.config/.update05152021" ]; then

	printf "\nFix for some games not being able to launch after Arkos Please wait jpeg image is displayed\nMade ES gui menus fullscreen\nAdd TheGamesDB back for Emulationstation\nFix NES box help menu for full screen gui menu\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05152021/rg351v/arkosupdate05152021.zip -O /home/ark/arkosupdate05152021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05152021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05152021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05152021.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Switch Launchimage to ascii.sh" ]; then
		  sudo cp -f -v /usr/local/bin/perfmax.pic /usr/local/bin/perfmax | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate05152021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05152021"
fi

if [ ! -f "/home/ark/.config/.update05202021" ]; then

	printf "\nAdd ability to generate and delete m3u files for PS1\nAdd ability to show only m3u files for PS1\nFix ES wake from sleep to screensaver issue\nBlank screen when entering sleep and restore to previous brightness on wake\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05202021/rg351v/arkosupdate05202021.zip -O /home/ark/arkosupdate05202021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05202021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05202021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05202021.zip -d / | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo sed -i '/roms\//s//roms2\//g' /opt/system/PS1\ -\ Generate\ m3u\ files.sh
		  sudo sed -i '/roms\//s//roms2\//g' /opt/system/PS1\ -\ Delete\ m3u\ files.sh
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sudo sed -i '/roms2\//s//roms\//g' /opt/system/PS1\ -\ Generate\ m3u\ files.sh
		  sudo sed -i '/roms2\//s//roms\//g' /opt/system/PS1\ -\ Delete\ m3u\ files.sh
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate05202021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05202021"
fi

if [ ! -f "/home/ark/.config/.update06042021" ]; then

	printf "\nAdd Clear last played collection script\nUpdate Switch to SD2 to account for mmcblk1\nAdd ability for 640x480 for Atomiswave and Naomi\nFix Scraping for c16 and c128\nFix .bs snes hacks not loading\nUpdate Retroarches to 1.9.4\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06042021/rg351v/arkosupdate06042021.zip -O /home/ark/arkosupdate06042021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06042021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06042021.zip" ]; then
		# The following 2 cp lines backup the existing standalone mupen64plus core and audio plugin to restore later in this update process
		# as there was a planned update of those but through further late testing revealed worse performance after the update package was 
		# already created with them included.
		cp -f -v /opt/mupen64plus/libmupen64plus.so.2.0.0 /opt/mupen64plus/libmupen64plus.so.2.0.0.bak | tee -a "$LOG_FILE"
		cp -f -v /opt/mupen64plus/mupen64plus-audio-sdl.so /opt/mupen64plus/mupen64plus-audio-sdl.so.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.192.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.192.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate06042021.zip -d / | tee -a "$LOG_FILE"
		# The following 2 cp lines restore the existing standalone mupen64plus core and audio plugin.
		cp -f -v /opt/mupen64plus/libmupen64plus.so.2.0.0.bak /opt/mupen64plus/libmupen64plus.so.2.0.0 | tee -a "$LOG_FILE"
		cp -f -v /opt/mupen64plus/mupen64plus-audio-sdl.so.bak /opt/mupen64plus/mupen64plus-audio-sdl.so | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06042021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<command>sudo perfmax \%EMULATOR\% \%CORE\%\; nice \-n \-19 \/usr\/local\/bin\/retroarch \-L \/home\/ark\/.config\/retroarch\/cores\/snes9x2010_libretro.so \%ROM\%\; sudo perfnorm<\/command>/{r /home/ark/fix_sneshacks.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i '/Nintendo - Super Famicom 2010/s//Nintendo - Super NES Hacks/' /etc/emulationstation/es_systems.cfg
	    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -f -v /home/ark/fix_sneshacks.txt | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/arkosupdate06042021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix Rick Dangerous for Retroarch 1.9.4 update\n" | tee -a "$LOG_FILE"
    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
	  cd /roms2/ports/xrick
	  unzip -X -o data.zip
	  rm -f -v data.zip
	  sed -i '/xrick\/data.zip/s//xrick\//' /roms2/ports/"Rick Dangerous.sh"
	fi
	cd /roms/ports/xrick
	unzip -X -o data.zip
	rm -f -v data.zip
	sed -i '/xrick\/data.zip/s//xrick\//' /roms/ports/"Rick Dangerous.sh"
	cd ~

	printf "\nChange wifi driver in retroarch to nmcli\n" | tee -a "$LOG_FILE"
	sed -i '/wifi_driver \= \"null\"/c\wifi_driver \= \"nmcli\"' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/wifi_driver \= \"null\"/c\wifi_driver \= \"nmcli\"' /home/ark/.config/retroarch/retroarch.cfg.bak

	printf "\nMake mounting of usb drives read/write not read only\n" | tee -a "$LOG_FILE"
	sed -i '/uid\=1000/s//uid\=1002/g' /opt/system/USB\ Drive\ Mount.sh

	printf "\nDisable RGA Scaling if it's on\n" | tee -a "$LOG_FILE"
	sed -i '/video_ctx_scaling \= \"true\"/c\video_ctx_scaling \= \"false\"' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/video_ctx_scaling \= \"true\"/c\video_ctx_scaling \= \"false\"' /home/ark/.config/retroarch/retroarch.cfg.bak
	sed -i '/video_ctx_scaling \= \"true\"/c\video_ctx_scaling \= \"false\"' /home/ark/.config/retroarch32/retroarch.cfg
	sed -i '/video_ctx_scaling \= \"true\"/c\video_ctx_scaling \= \"false\"' /home/ark/.config/retroarch32/retroarch.cfg.bak

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06042021"
fi

if [ ! -f "/home/ark/.config/.update07022021" ]; then

	printf "\nAdd supafaust snes core\nUpdate Switch to main SD for Roms.sh and Switch to SD2 for Roms.sh\nAdd support for American Laser Games\nAdd support for scraping of American Laser Games\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07022021/rg351v/arkosupdate07022021.zip -O /home/ark/arkosupdate07022021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07022021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07022021.zip" ]; then
		if [ ! -d "/roms/alg/" ]; then
			sudo mkdir -v /roms/alg | tee -a "$LOG_FILE"
		fi
		if [ "$(ls -A /roms2)" ]; then
			sudo mkdir -v /roms2/alg | tee -a "$LOG_FILE"
		fi
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.194.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.194.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate07022021.zip -d / | tee -a "$LOG_FILE"
		sudo chown ark:ark /etc/emulationstation/es_systems.cfg
		cp -f -v /opt/hypseus/hypinput.ini /opt/hypseus-singe/hypinput.ini | tee -a "$LOG_FILE"
		cp -f -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07022021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<theme>daphne<\/theme>/{r /home/ark/add_alg.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sed -i '/<path>\/roms\/alg\//s//<path>\/roms2\/alg\//' /etc/emulationstation/es_systems.cfg
		  sudo rm -rf /opt/hypseus-singe/singe | tee -a "$LOG_FILE"
		  ln -sfv /roms2/alg/ /opt/hypseus-singe/singe | tee -a "$LOG_FILE"
		  sudo sed -i '/roms\//s//roms2\//g' /usr/local/bin/singe.sh
		  sudo cp -f -v "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sed -i '/<path>\/roms2\/alg\//s//<path>\/roms\/alg\//' /etc/emulationstation/es_systems.cfg
		  sudo rm -rf /opt/hypseus-singe/singe | tee -a "$LOG_FILE"
		  ln -sfv /roms/alg/ /opt/hypseus-singe/singe | tee -a "$LOG_FILE"
		  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/singe.sh
		  sudo cp -f -v "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		sed -i "/<core>snes9x2010<\/core>/c\ \t\t\t  <core>snes9x2010<\/core>\n\t\t\t  <core>mednafen_supafaust<\/core>" /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/arkosupdate07022021.zip | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/add_alg.txt | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07022021"
fi

if [ ! -f "/home/ark/.config/.update07282021" ]; then

	printf "\nUpdate Switch to SD2 for Roms.sh to fix American Laser Games scanning and launching\nFix Restore Default Retroarch Settings.sh,Restore Default Retroarch32 Settings.sh,Restore Default Retroarch Core Settings.sh,Restore Default Retroarch32 Core Settings.sh\nFix OpenBOR not copying master.cfg correctly\nStop symlinks from changing for aarch64 and arm32\nChange mednafen_vb options cpu emulation to fast\nAdd retroarch info file for mgba_rumble, flycast_rumble, flycast32_rumble and pcsx_rearmed_rumble\nAdd 351Files\nDisable performance mode changes in ogage\nAdd scanning and other changes for EasyRPG\nAdd plaidman doom loader\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07282021/rg351v/arkosupdate07282021.zip -O /home/ark/arkosupdate07282021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07282021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07282021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07282021.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07282021.bak | tee -a "$LOG_FILE"
		sed -i '/.ldb .LDB/s//.easyrpg .EASYRPG/' /etc/emulationstation/es_systems.cfg
		sed -i '/.wad .WAD .sh .SH/s//.wad .WAD .sh .SH .doom .DOOM/' /etc/emulationstation/es_systems.cfg
		sed -i '/supported_extensions \= /c\supported_extensions \= \"ldb|easyrpg|zip\"' /home/ark/.config/retroarch/cores/easyrpg_libretro.info
		sudo chmod 777 /roms/easyrpg/Scan_for_new_games.easyrpg | tee -a "$LOG_FILE"
		sed -i '/\/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/easyrpg_libretro.so/s//\/usr\/local\/bin\/easyrpg.sh/' /etc/emulationstation/es_systems.cfg
	    if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
		  sudo cp -f -v /usr/local/bin/"Switch to SD2 for Roms.sh" /opt/system/Advanced/"Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sudo cp -f -v /usr/local/bin/"Switch to main SD for Roms.sh" /opt/system/Advanced/"Switch to main SD for Roms.sh"
		  cp -f -v /roms/easyrpg/Scan_for_new_games.easyrpg /roms2/easyrpg/Scan_for_new_games.easyrpg | tee -a "$LOG_FILE"
		  sudo chmod 777 /roms2/easyrpg/Scan_for_new_games.easyrpg | tee -a "$LOG_FILE"
		  sudo sed -i '/\/roms\//s//\/roms2\//g' /usr/local/bin/easyrpg.sh
		  sed -i '/\/roms\//s//\/roms2\//' /roms2/easyrpg/Scan_for_new_games.easyrpg
		  sed -i '/.\/351Files 2/s//.\/351Files-sd2 2/g' /opt/system/351Files.sh
		fi
		sudo rm -v /home/ark/arkosupdate07282021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix OpenBOR not copying master.cfg default config correctly\n" | tee -a "$LOG_FILE"
	sed -i '/basefile\=$(basename -- $file)/c\basefile\=$(basename -- \"$file\")' /opt/OpenBor/OpenBor.sh
	
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

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07282021"
fi

if [ ! -f "/home/ark/.config/.update08272021" ]; then

	printf "\nUpdate Retroarch to 1.9.8\nFix Timezone issue for Hong_Kong and others in Emulationstation\nAdd ecwolf standalone\nUpdate Switch to SD2 and Switch to main SD scripts for ecwolf\nAdd genesis_plus_gx_wide 64bit\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08272021/rg351v/arkosupdate08272021.zip -O /home/ark/arkosupdate08272021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08272021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08272021.zip" ]; then
		mkdir -v /roms/wolf | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.196.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.196.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate08272021.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08272021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<theme>doom<\/theme>/{r /home/ark/add_wolf.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i "/<core>genesis_plus_gx<\/core>/c\ \t\t\t  <core>genesis_plus_gx<\/core>\n\t\t\t  <core>genesis_plus_gx_wide<\/core>" /etc/emulationstation/es_systems.cfg
	    if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
		  sudo cp -f -v /usr/local/bin/"Switch to SD2 for Roms.sh" /opt/system/Advanced/"Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  mkdir -v /roms2/wolf | tee -a "$LOG_FILE"
		  sudo cp -f -v /usr/local/bin/"Switch to main SD for Roms.sh" /opt/system/Advanced/"Switch to main SD for Roms.sh"
		  cp -f -v /roms/wolf/Scan_for_new_games.wolf /roms2/wolf/Scan_for_new_games.wolf | tee -a "$LOG_FILE"
		  sudo chmod 777 /roms2/wolf/Scan_for_new_games.wolf | tee -a "$LOG_FILE"
		  sudo sed -i '/\/roms\//s//\/roms2\//g' /usr/local/bin/ecwolf.sh
		  sed -i '/\/roms\//s//\/roms2\//g' /roms2/wolf/Scan_for_new_games.wolf
		  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
		fi
		sudo rm -v /home/ark/arkosupdate08272021.zip | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/add_wolf.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix sound volume does not restore previous saved state so it can self recover after a reboot\n" | tee -a "$LOG_FILE"
	sudo sed -i '/ConditionPathExists\=\/var\/lib\/alsa\/asound.state/c\\#ConditionPathExists\=\/var\/lib\/alsa\/asound.state' /lib/systemd/system/alsa-restore.service
	sudo systemctl daemon-reload

	printf "\nInstall fonts-noto-cjk to fix Retroarch Korean language\n" | tee -a "$LOG_FILE"
	sudo apt -y update | tee -a "$LOG_FILE"
	sudo apt -y install fonts-noto-cjk | tee -a "$LOG_FILE"

	printf "\nRemove old cache and backup folder files from var folder\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	
	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08272021"
fi

if [ ! -f "/home/ark/.config/.update08292021" ]; then

	printf "\nUpdate Retroarch 1.9.8 to fix overlay with dpad input issue\nUpdate PPSSPPSDL to 1.11.3\nUpdate PortMaster to 1.52\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08292021/arkosupdate08292021.zip -O /home/ark/arkosupdate08292021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08292021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08292021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate08292021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate08292021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08292021"
fi

if [ ! -f "/home/ark/.config/.update09212021" ]; then

	printf "\nAdd quicknes as a supported core for NES and Famicom Disk System\nAdd video filters for retroarch and retroarch32\nAdd BaRT (Boot and Recovery Tool)\nAdd Astrocade and Channel F emulators\nAdd scraping support for Astrocade for Emulationstation\nAdd ability to switch A/B button in Emulationstation\nUpdate NesBox Theme\nAdd 32bit gpsp core\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/rg351v/arkosupdate09212021.zip -O /home/ark/arkosupdate09212021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/rg351v/arkosupdate09212021.z01 -O /home/ark/arkosupdate09212021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.z01 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/rg351v/arkosupdate09212021.z02 -O /home/ark/arkosupdate09212021.z02 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.z02 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate09212021.zip" ] && [ -f "/home/ark/arkosupdate09212021.z01" ] && [ -f "/home/ark/arkosupdate09212021.z02" ]; then
		sudo rm -rf /roms/themes/es-theme-nes-box/ | tee -a "$LOG_FILE"
		zip -FF /home/ark/arkosupdate09212021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate09212021.z* | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		mkdir -v /roms/channelf | tee -a "$LOG_FILE"
		sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09212021.bak | tee -a "$LOG_FILE"
		sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch\/filters\/video\"" /home/ark/.config/retroarch/retroarch.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch\/filters\/video\"" /home/ark/.config/retroarch/retroarch.cfg.bak && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch32/retroarch.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch32/retroarch.cfg.bak
		sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch/config/Atari800/retroarch_5200.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch/config/Atari800/retroarch_A800.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch/config/Atari800/retroarch_XEGS.cfg
		sed -i "/<core>fceumm<\/core>/c\ \t\t\t  <core>fceumm<\/core>\n\t\t\t  <core>quicknes<\/core>" /etc/emulationstation/es_systems.cfg
		sed -i '/<core>gpsp<\/core>/s//<core>gpsp<\/core>\n\t\t\t<\/cores>\n\t\t\t<\/emulator>\n\t\t\t  <emulator name\="retroarch32">\n\t\t\t<cores>\n\t\t\t  <core>gpsp<\/core>/'  /etc/emulationstation/es_systems.cfg
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep astrocade)"
		then
		  sed -i -e '/<theme>arcade<\/theme>/{r /home/ark/add_astrocade.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep channelf)"
		then
		  sed -i -e '/<theme>astrocade<\/theme>/{r /home/ark/add_channelf.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  cp -R -f -v /roms/astrocde/ /roms2/ | tee -a "$LOG_FILE"
		  sudo chmod -R 777 /roms2/astrocde/ | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
		  mkdir -v /roms2/channelf | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/add_astrocade.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_channelf.txt | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the theme configuration has been updated for nes box\n" | tee -a "$LOG_FILE"
	if test -z "$(cat ~/.emulationstation/es_settings.cfg | grep 'value="4:3"')"
	then
	   sed -i '$a<string name\=\"subset.Emulationstation Screen\" value\=\"4:3\" \/>' /home/ark/.emulationstation/es_settings.cfg
	fi
	sed -i '/<string name\=\"subset.fullscreenfix\" value\=\"351V\" \/>/d' /home/ark/.emulationstation/es_settings.cfg

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09212021"
fi

if [ ! -f "/home/ark/.config/.update10162021" ]; then

	printf "\nUpdate Emulationstation\nUpdate controls for Solarus\nFix OpenBOR configuration loading and saving\nAdd Satellaview\nUpdate ScummVM to 2.5\nUpdate Retroarch to 1.9.11\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021/chirg351v/arkosupdate10162021.zip -O /home/ark/arkosupdate10162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021/chirg351v/arkosupdate10162021.z01 -O /home/ark/arkosupdate10162021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021.z01 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10162021.zip" ] && [ -f "/home/ark/arkosupdate10162021.z01" ]; then
		zip -FF /home/ark/arkosupdate10162021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate10162021.z* | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.198.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.198.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		mkdir -v /roms/satellaview | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update10162021.bak | tee -a "$LOG_FILE"
		inputtest=$(cat /etc/emulationstation/es_input.cfg | grep "gameforce_gamepad")
		if [ -z "$inputtest" ]; then
		  sed -i "/<\/inputConfig>/c\ \t\t<input name=\"system_hk\" type=\"button\" id=\"9\" value=\"1\" />\n        <\/inputConfig>" /etc/emulationstation/es_input.cfg
		else
		  sed -i "/<\/inputConfig>/c\ \t\t<input name=\"system_hk\" type=\"button\" id=\"16\" value=\"1\" />\n        <\/inputConfig>" /etc/emulationstation/es_input.cfg		
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep satellaview)"
		then
		  sed -i -e '/<theme>arcade<\/theme>/{r /home/ark/add_satellaview.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		cp -r -v .solarus/ /roms/solarus/ | tee -a "$LOG_FILE"
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
		  mkdir -v /roms2/satellaview | tee -a "$LOG_FILE"
		  cp -r -v .solarus/ /roms2/solarus/ | tee -a "$LOG_FILE"
		fi
		if [ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]; then
		  sudo rm -v /boot/rk3326-rg351v-linux.dtb.* | tee -a "$LOG_FILE"
		  sudo rm -v /opt/system/Advanced/Screen\ -\ Switch\ to\ * | tee -a "$LOG_FILE"
		  sudo rm -v /usr/local/bin/Screen\ -\ Switch\ to\ * | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/add_satellaview.txt | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10162021"
fi

if [ ! -f "/home/ark/.config/.update10162021-1" ]; then

	printf "\nFix arcade theme label gaff from previous update\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021-1/arkosupdate10162021-1.zip -O /home/ark/arkosupdate10162021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10162021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate10162021-1.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg.update10162021.bak /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep satellaview)"
		then
		  sed -i -e '/<theme>sufami<\/theme>/{r /home/ark/add_satellaview.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		sudo rm -v /home/ark/add_satellaview.txt | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate10162021-1.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10162021-1"
fi

if [ ! -f "/home/ark/.config/.update10172021" ]; then

	printf "\nUpdate Retroarches 1.9.11 to newer commit with ozone missing assets fix\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10172021/arkosupdate10172021.zip -O /home/ark/arkosupdate10172021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10172021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10172021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate10172021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate10172021.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10172021"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate to Retroarch 1.9.12\nAdd MegaDuck\nUpdate standalone PPSSPP to 1.12.3\nUpdate liblcf for EasyRPG 0.7.0 future update\nUpdate Emulationstation for megaduck scraping and fix mixv2 scraping\nAdd .7z support for various systems\nAdd .zip support for Amiga\nAdd .vsf support for c64\nAdd ability to hide .zip for DOS games\nAdd missing ppsspp backup folder\nUpdate nes-box theme for megaduck\nFix Space key for non English ES\nIgnore options and retroarch for auto collections\nUpdate update script\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11052021/arkosupdate11052021.zip -O /home/ark/arkosupdate11052021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11052021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11052021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1911.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1911.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate11052021.zip -d / | tee -a "$LOG_FILE"
		sudo rm /home/ark/.config/retroarch/cores/*.lck
		sudo rm /home/ark/.config/retroarch32/cores/*.lck
		mkdir -v /roms/megaduck | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11052021.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep megaduck)"
		then
		  sed -i -e '/<theme>cps3<\/theme>/{r /home/ark/add_megaduck.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  mkdir -v /roms2/megaduck | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
		  cp -v /roms/bios/mame/hash/megaduck.xml /roms2/bios/mame/hash/megaduck.xml | tee -a "$LOG_FILE"
		fi
		sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
		sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
		sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/backupforromsfolder.zip | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_megaduck.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11052021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	#Sed some additional supported extensions for various systems
	#Amiga
	sed -i '/<extension>.lha .LHA .hdf .HDF .adf .ADF .m3u .M3U/s//<extension>.lha .LHA .hdf .HDF .adf .ADF .m3u .M3U .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	#Amstrad
	sed -i '/<extension>.cpc .CPC .dsk .DSK .zip .ZIP/s//<extension>.cpc .CPC .dsk .DSK .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Commodore 64
	sed -i '/<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT/s//<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .vsf .VSF/' /etc/emulationstation/es_systems.cfg
	#Atari 2600
	sed -i '/<extension>.a26 .A26 .bin .BIN .zip .ZIP/s//<extension>.a26 .A26 .bin .BIN .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Atari 5200
	sed -i '/<extension>.a52 .A52 .zip .ZIP/s//<extension>.a52 .A52 .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Atari 800
	sed -i '/<extension>.atr .ATR .rom .ROM .zip .ZIP/s//<extension>.atr .ATR .rom .ROM .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Atari Lynx
	sed -i '/<extension>.lnx .LNX .zip .ZIP/s//<extension>.lnx .LNX .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#PC Engine/Turbografx 16
	sed -i '/<extension>.pce .PCE .bin .BIN .zip .ZIP/s//<extension>.pce .PCE .bin .BIN .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.pce .PCE .chd .CHD .zip .ZIP/s//<extension>.pce .PCE .chd .CHD .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#NES
	sed -i '/<extension>.nes .NES .zip .ZIP/s//<extension>.nes .NES .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Virtual Boy
	sed -i '/<extension>.vb .VB .vboy .VBOY .zip .zip/s//<extension>.vb .VB .vboy .VBOY .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#NGP/NGPC
	sed -i '/<extension>.ngp .NGP .ngc .NGC .zip .ZIP/s//<extension>.ngp .NGP .ngc .NGC .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Colecovision
	sed -i '/<extension>.rom .ROM .ri .RI .mx1 .MX1 .mx2 .MX2 .col .COL .dsk .DSK .cas .CAS .sg .SG .sc .SC .m3u .M3U .zip .ZIP/s//<extension>.rom .ROM .ri .RI .mx1 .MX1 .mx2 .MX2 .col .COL .dsk .DSK .cas .CAS .sg .SG .sc .SC .m3u .M3U .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Vectrex
	sed -i '/<extension>.vec .VEC .zip .ZIP/s//<extension>.vec .VEC .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#MSX/MSX2
	sed -i '/<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .ZIP .m3u .M3U/s//<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .ZIP .m3u .M3U .7z .7Z/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .Zip .m3u .M3U/s//<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .ZIP .m3u .M3U .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Supervision
	sed -i '/<extension>.bin .BIN .zip .ZIP/s//<extension>.bin .BIN .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	
	#Ignore Options and Retroarch for auto collections
	sed -i '/<platform>cmds</s//<platform>ignore</' /etc/emulationstation/es_systems.cfg
	sed -i '/<platform>retroarch</s//<platform>ignore</' /etc/emulationstation/es_systems.cfg

	printf "\nAdd ability to recreate sdl_controllers.txt for pico-8\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /usr/local/bin/pico8.sh | grep sdl_controllers)"
	then
	  sudo sed -i '/bash/s//bash\n\nif [[ ! -f \"\/roms\/pico-8\/sdl_controllers.txt\" ]]\; then\necho \"19000000030000000300000002030000\,gameforce_gamepad\,leftstick:b14\,rightx:a3\,leftshoulder:b4\,start:b9\,lefty:a0\,dpup:b10\,righty:a2\,a:b1\,b:b0\,guide:b16\,dpdown:b11\,rightshoulder:b5\,righttrigger:b7\,rightstick:b15\,dpright:b13\,x:b2\,back:b8\,leftx:a1\,y:b3\,dpleft:b12\,lefttrigger:b6\,platform:Linux\,\n190000004b4800000010000000010000\,GO-Advance Gamepad\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:b7\,dpleft:b8\,dpright:b9\,dpup:b6\,leftx:a0\,lefty:a1\,guide:b10\,leftstick:b12\,lefttrigger:b11\,rightstick:b13\,righttrigger:b14\,start:b15\,platform:Linux\,\n190000004b4800000010000001010000\,GO-Advance Gamepad (rev 1.1)\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:b9\,dpleft:b10\,dpright:b11\,dpup:b8\,leftx:a0\,lefty:a1\,guide:b12\,leftstick:b14\,lefttrigger:b13\,rightstick:b15\,righttrigger:b16\,start:b17\,platform:Linux\,\n190000004b4800000011000000010000\,GO-Super Gamepad\,x:b2\,a:b1\,b:b0\,y:b3\,back:b12\,start:b13\,dpleft:b10\,dpdown:b9\,dpright:b11\,dpup:b8\,leftshoulder:b4\,lefttrigger:b6\,rightshoulder:b5\,righttrigger:b7\,leftstick:b14\,rightstick:b15\,leftx:a0\,lefty:a1\,rightx:a2\,righty:a3\,platform:Linux\,\n03000000091200000031000011010000\,OpenSimHardware OSH PB Controller\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:h0.4\,dpleft:h0.8\,dpright:h0.2\,dpup:h0.1\,guide:b7\,leftstick:b14\,lefttrigger:b13\,rightstick:b15\,righttrigger:b16\,leftx:a0~\,lefty:a1~\,start:b6\,platform:Linux\,\" \> \/roms\/pico-8\/sdl_controllers.txt\nfi/' /usr/local/bin/pico8.sh
	  if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
	    sudo sed -i '/roms\/pico-8/s//roms2\/pico-8/g' /usr/local/bin/pico8.sh
	  fi
	fi

	printf "\nRemove old logs, cache and backup folder files from var folder\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	sudo journalctl --vacuum-time=1s | tee -a "$LOG_FILE"

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	LD_LIBRARY_PATH=/usr/local/bin msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187
fi