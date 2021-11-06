#!/bin/bash
clear

UPDATE_DATE="11052021"
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

if [ ! -f "/home/ark/.config/.update12262020" ]; then

	printf "\nAdd File Manger to Options section\nAdd updated dtb to address possible occassional freezes for RG351P\nAdd updated blacklist to stabilize rtl8xxx wifi chipsets" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/12262020/arkosupdate12262020.zip -O /home/ark/arkosupdate12262020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12262020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12262020.zip -d / | tee -a "$LOG_FILE"
		sudo dpkg -i libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb
		sudo rm -v /home/ark/arkosupdate12262020.zip | tee -a "$LOG_FILE"
		sudo rm -v /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb | tee -a "$LOG_FILE"
		sudo rm -v /boot/rk3326-rg351p-linux.dtb.13 | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMove themes folder to roms folder for easy management\n" | tee -a "$LOG_FILE"
	reqSpace=1000000
	availSpace=$(df "/roms" | awk 'NR==2 { print $4 }')
	if (( availSpace < reqSpace )); then
		echo "not enough Space" >&2
	else 
		sudo mkdir -v /roms/themes | tee -a "$LOG_FILE"
		sudo mv -v /etc/emulationstation/themes/* /roms/themes | tee -a "$LOG_FILE"
		sudo rm -rf -v /etc/emulationstation/themes/ | tee -a "$LOG_FILE"
		sudo ln -sfv /roms/themes/ /etc/emulationstation/themes | tee -a "$LOG_FILE"
	fi
	
	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	if [ -f "/home/ark/.config/.update12262020" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	touch "/home/ark/.config/.update12262020"
fi

if [ ! -f "/home/ark/.config/.update12262020-1" ]; then

	printf "\nFix File Manager from last update\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/12262020-1/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb -O /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb -a "$LOG_FILE"
	sudo dpkg -i /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb
	sudo rm -v /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb | tee -a "$LOG_FILE"

	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update12262020-1"
fi

if [ ! -f "/home/ark/.config/.update12272020" ]; then

	printf "\nUpdated es_systems.cfg to support .m3u for cd systems and .sh for doom mods\nAdd updated blacklist for realtek chipset fixes.\n"
	sudo wget --no-check-certificate "$LOCATION"/12272020/rgb10-rk2020/arkosupdate12272020.zip -O /home/ark/arkosupdate12272020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12272020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12272020.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12272020.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12272020" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.update12272020"
fi

if [ ! -f "/home/ark/.config/.update12272020-1" ]; then

	printf "\nUpdate doom execution script to support running mod files using .sh extension\n"
	sudo wget --no-check-certificate "$LOCATION"/12272020-1/arkosupdate12272020-1.zip -O /home/ark/arkosupdate12272020-1.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12272020-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12272020-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12272020-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12272020-1" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.update12272020-1"
fi

if [ ! -f "/home/ark/.config/.update01022021" ]; then

	printf "\nUpdate spanish translation for emulationstation\nUpdate emulationstation\nAdd support for Pokemon Mini\nAdd support for Atari Jaguar\nAdd support for 3DO\nFix Atari 800, 5200 and XEGS rom loading\n"
	sudo wget --no-check-certificate "$LOCATION"/01022021/rk2020/arkosupdate01022021.zip -O /home/ark/arkosupdate01022021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01022021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01022021.zip" ]; then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update$UPDATE_DATE.bak
		sudo unzip -X -o /home/ark/arkosupdate01022021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01022021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update01022021" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.update01022021"
fi

if [ ! -f "/home/ark/.config/.update01032021" ]; then

	printf "\nFix platform and theme for Atari Jaguar\n" | tee -a "$LOG_FILE"
	cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update$UPDATE_DATE.bak
	sed -i '0,/<platform>pokemonmini/!{0,/<platform>pokemonmini/s//<platform>atarijaguar/}' /etc/emulationstation/es_systems.cfg
	sed -i '0,/<theme>pokemonmini/!{0,/<theme>pokemonmini/s//<theme>atarijaguar/}' /etc/emulationstation/es_systems.cfg

	printf "\nAdd support for .lha for Amiga CD32\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.cue .CUE .ccd .CCD .nrg .NRG .mds .MDS/s//<extension>.cue .CUE .ccd .CCD .lha .LHA .nrg .NRG .mds .MDS/' /etc/emulationstation/es_systems.cfg

	printf "\nAdd support for .zip for Pokemon Mini\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.min .MIN/s//<extension>.min .MIN .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01032021"
fi

if [ ! -f "/home/ark/.config/.update01042021" ]; then

	printf "\nAdd support for .zip for AmstradCPC\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.cpc .CPC .dsk .DSK/s//<extension>.cpc .CPC .dsk .DSK .zip .ZIP/' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update01042021"
fi

if [ ! -f "/home/ark/.config/.update01052021" ]; then

	printf "\nIncrease audio period and buffer sizes in .asoundrc\nAdded updated retroarch with netplay fix\n"
		sudo wget --no-check-certificate "$LOCATION"/01052021/rgb10rk2020/arkosupdate01052021.zip -O /home/ark/arkosupdate01052021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01052021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01052021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01052021.zip -d / | tee -a "$LOG_FILE"
		cp -v /home/ark/.asoundrc /home/ark/.asoundrcbak | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
		sudo sed -i '/<command>sudo perfmax; cd \/; cd \/opt\/drastic\; \.\/drastic/s//<command>sudo perfmax\; \/usr\/local\/bin\/drastic\.sh/' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/#!\/bin\/sh/s//#!\/bin\/sh\n\ncp \/home\/ark\/\.asoundrcbak \/home\/ark\/\.asoundrc/' /usr/bin/emulationstation/emulationstation.sh
		sudo rm -v /home/ark/arkosupdate01052021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update01052021" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.update01052021"
fi

if [ ! -f "/home/ark/.config/.update01092021" ]; then

	printf "\nFix scraping for NeoGeo CD\n" | tee -a "$LOG_FILE"
	sudo sed -i '0,/<platform>console/!{0,/platform>console/s//platform>neogeocd/}' /etc/emulationstation/es_systems.cfg

	printf "\nAdd support for .dim for x68000\n" | tee -a "$LOG_FILE"
	sudo sed -i '/<extension>.zip .ZIP .2hd .2HD .d88 .D88 .88d .88D .hdm .HDM .hdf .HDF .xdf .XDF .dup .DUP .cmd .CMD .m3u .M3U .img .IMG/s//<extension>.dim .DIM .zip .ZIP .2hd .2HD .d88 .D88 .88d .88D .hdm .HDM .hdf .HDF .xdf .XDF .dup .DUP .cmd .CMD .m3u .M3U .img .IMG/' /etc/emulationstation/es_systems.cfg

	printf "\nAdd roms folder and background image to nes-box theme for vmu\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01092021/arkosupdate01092021.zip -O /home/ark/arkosupdate01092021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01092021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01092021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01092021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01092021.zip | tee -a "$LOG_FILE"
		if [ ! -d "/roms/vmu/" ]; then
			sudo mkdir -v /roms/vmu | tee -a "$LOG_FILE"
		fi	
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01092021"
fi

if [ ! -f "/home/ark/.config/.update01092021-1" ]; then

	printf "\nFix scraping for Pokemon Mini\n" | tee -a "$LOG_FILE"
	sudo sed -i '/platform>pokemonmini/c\\t\t<platform>pokemini<\/platform>' /etc/emulationstation/es_systems.cfg

	touch "/home/ark/.config/.update01092021-1"
fi

if [ ! -f "/home/ark/.config/.update01102021" ]; then

	printf "\nAdd Daphne(Hypseus) standalone emulator\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01102021/rk2020/arkosupdate01102021.zip -O /home/ark/arkosupdate01102021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01102021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01102021.zip" ]; then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate01102021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01102021.zip | tee -a "$LOG_FILE"
		if [ ! -d "/roms/daphne/" ]; then
			sudo mkdir -v /roms/daphne | tee -a "$LOG_FILE"
			sudo mkdir -v /roms/daphne/roms | tee -a "$LOG_FILE"
		fi	
		ln -sfv /roms/daphne/roms/ /opt/hypseus/roms | tee -a "$LOG_FILE"
		sudo sed -i '/cps3<\/theme>/r add_daphne.txt' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_daphne.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01102021"
fi

if [ ! -f "/home/ark/.config/.update01112021" ]; then

	printf "\nAdd 32bit opentyrian port to address performance\n" | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /home/ark/.config/opentyrian/ | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01112021/rgb10rk2020/arkosupdate01112021.zip -O /home/ark/arkosupdate01112021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01112021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01112021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01112021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01112021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix screenshot crashes in retroarch\n" | tee -a "$LOG_FILE"
	sudo sed -i '/notification_show_screenshot \= \"true\"/s//notification_show_screenshot \= \"false\"/' /home/ark/.config/retroarch/retroarch.cfg
	sudo sed -i '/notification_show_screenshot \= \"true\"/s//notification_show_screenshot \= \"false\"/' /home/ark/.config/retroarch32/retroarch.cfg

	printf "\nFix retroarch shaders not autoloading when saved as override\n" | tee -a "$LOG_FILE"
	sudo sed -i '/video_shader_delay \= \"0\"/s//video_shader_delay \= \"3\"/' /home/ark/.config/retroarch/retroarch.cfg
	sudo sed -i '/video_shader_delay \= \"0\"/s//video_shader_delay \= \"3\"/' /home/ark/.config/retroarch32/retroarch.cfg

	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01112021"
fi

if [ ! -f "/home/ark/.config/.update01162021" ]; then

	printf "\nAdd lr-Uzebox emulator\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01162021/arkosupdate01162021.zip -O /home/ark/arkosupdate01162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01162021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01162021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01162021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01162021.zip | tee -a "$LOG_FILE"
		sudo sed -i -e '/<name>retropie<\/name>/{r /home/ark/add_uzebox.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_uzebox.txt | tee -a "$LOG_FILE"
		if [ ! -d "/roms/uzebox/" ]; then
			sudo mkdir -v /roms/uzebox | tee -a "$LOG_FILE"
		fi
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01162021"
fi

if [ ! -f "/home/ark/.config/.update01172021" ]; then

	printf "\nUpdate 64 bit libSDL2 to updated 64bit libSDL2 2.0.14.1 compiled by kreal\nImprove audio for N64\nImprove audio for PSP\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01172021/arkosupdate01172021.zip -O /home/ark/arkosupdate01172021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01172021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01172021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01172021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01172021.zip | tee -a "$LOG_FILE"
		sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nLet's finally ensure that Drastic's performance has not been negatively impacted by these updates and future updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo rm -v /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.12.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01172021"
fi

if [ ! -f "/home/ark/.config/.update01182021" ]; then

	printf "\nFix retroarch N64 no sound issue from last update\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01182021/arkosupdate01182021.zip -O /home/ark/arkosupdate01182021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01182021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01182021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01182021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01182021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01182021"
fi

if [ ! -f "/home/ark/.config/.update01212021" ]; then

	printf "\nAdjust sound settings in ArkOS so future updates should not impact emulators and ports needing direct access to set sound\nAdd fixed controls for the standalone Amiga emulator (Amiberry)\nUpdate kyra.dat for standalone scummvm\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01212021/rk2020/arkosupdate01212021.zip -O /home/ark/arkosupdate01212021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01212021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01212021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01212021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01212021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01212021"
fi

if [ ! -f "/home/ark/.config/.update01212021-1" ]; then

	printf "\nFix deadzone for lzdoom\n" | tee -a "$LOG_FILE"
	sudo sed -i '/Axis1deadzone=0.100001/c\Axis1deadzone=0.100001\nAxis2deadzone=0.100001\nAxis3deadzone=0.100001' /home/ark/.config/lzdoom/lzdoom.ini

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01212021-1"
fi

if [ ! -f "/home/ark/.config/.update01242021" ]; then

	printf "\nUpdated ES to fix scraping for daphne, neogeo cd, and xegs\nAdd tic-80 and sharp x1 scraping\nFix audio for ppsspp-standalone\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01242021/arkosupdate01242021.zip -O /home/ark/arkosupdate01242021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01242021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01242021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01242021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01242021.zip | tee -a "$LOG_FILE"
		sudo sed -i '/platform>tic-80/c\\t\t<platform>tic80<\/platform>' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/platform>atarixegs/c\\t\t<platform>atarixe<\/platform>' /etc/emulationstation/es_systems.cfg
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "\nFix scraping for Sega Saturn\n" | tee -a "$LOG_FILE"
	sudo sed -i '/platform>console/c\\t\t<platform>saturn<\/platform>' /etc/emulationstation/es_systems.cfg

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01242021"
fi

if [ ! -f "/home/ark/.config/.update01282021" ]; then

	printf "\nAdd Crocods (Amstrad CPC) emulator and make it the default emulator for this system\nUpdate Drastic to newer 64 bit build\nAdd gpsp as a selectable gba core\nAdd 2048 retroarch port\nAdd scan script for scummvm\nUpdate dosbox_pure core to version 0.10\nAdd Openbor system\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01282021/rk2020/arkosupdate01282021.zip -O /home/ark/arkosupdate01282021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01282021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01282021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01282021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01282021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01282021.bak | tee -a "$LOG_FILE"
		sudo sed -i '/<core>vba_next<\/core>/c\\t\t\t  <core>vba_next<\/core>\n\t\t\t  <core>gpsp<\/core>' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<command>sudo perfmax; \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/cap32_libretro.so %ROM%; sudo perfnorm<\/command>/{r /home/ark/add_crocods.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>c64<\/name>/{r /home/ark/add_c16.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<theme>c64<\/theme>/{r /home/ark/add_c128.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<theme>ngpc<\/theme>/{r /home/ark/add_openbor.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/<command>sudo perfmax; \/usr\/local\/bin\/scummvm\.sh %EMULATOR% %CORE% %ROM%; sudo perfnorm<\/command>/{n;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<command>sudo perfmax; \/usr\/local\/bin\/scummvm\.sh %EMULATOR% %CORE% %ROM%; sudo perfnorm<\/command>/{r /home/ark/chg_def_scummvm.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_c16.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_c128.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_crocods.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_openbor.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/chg_def_scummvm.txt | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		if [ ! -d "/roms/c16/" ]; then
			sudo mkdir -v /roms/c16 | tee -a "$LOG_FILE"
		fi
		if [ ! -d "/roms/c128/" ]; then
			sudo mkdir -v /roms/c128 | tee -a "$LOG_FILE"
		fi
		if [ ! -d "/roms/openbor/" ]; then
			sudo mkdir -v /roms/openbor | tee -a "$LOG_FILE"
		fi
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nDisable dsp in flycast core options to improve performance\n" | tee -a "$LOG_FILE"
	sudo sed -i "/reicast_enable_dsp \= \"enabled\"/c\reicast_enable_dsp \= \"disabled\"" /home/ark/.config/retroarch/retroarch-core-options.cfg
	sudo sed -i "/reicast_enable_dsp \= \"enabled\"/c\reicast_enable_dsp \= \"disabled\"" /home/ark/.config/retroarch32/retroarch-core-options.cfg

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01282021"
fi

if [ ! -f "/home/ark/.config/.update01292021" ]; then

	printf "\nAdd platform name for scummvm\nFix scummvm scan games script to allow for spaces in directory name\nFix loading of scummvm games in retroarch\nUpdate dosbox_pure 0.10 for performance\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/01292021/rgb10rk2020/arkosupdate01292021.zip -O /home/ark/arkosupdate01292021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01292021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01292021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01292021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01292021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01292021.bak | tee -a "$LOG_FILE"
		sudo sed -i '/<name>scummvm<\/name>/{n;N;N;N;N;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>scummvm<\/name>/{r /home/ark/fix_plat_scummvm.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/fix_plat_scummvm.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01292021"
fi

if [ ! -f "/home/ark/.config/.update02032021" ]; then

	printf "\nAdd TI99 emulator\nAdd retroarch core options reset to default\nUpdate ES to support ti99 scraping\nAdd ti99 image to nes-box theme\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/02032021/rk2020/arkosupdate02032021.zip -O /home/ark/arkosupdate02032021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02032021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate02032021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate02032021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate02032021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02032021.bak | tee -a "$LOG_FILE"
		sudo sed -i -e '/<theme>msdos<\/theme>/{r /home/ark/add_ti99.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_ti99.txt | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		if [ ! -d "/roms/ti99/" ]; then
			sudo mkdir -v /roms/ti99 | tee -a "$LOG_FILE"
		fi
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nAdd support for .hdf for Amiga\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.lha .LHA .adf .ADF .m3u .M3U/s//<extension>.lha .LHA .hdf .HDF .adf .ADF .m3u .M3U/' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02032021"
fi

if [ ! -f "/home/ark/.config/.update02132021" ]; then

	printf "\nAdd flycast32 rumble enabled core as selectable core\nRecompiled scummvm standalone to allow the use of virtual keyboards\nFix ability to load .adf for Amiberry (Amiga)\nUpdate 32bit and 64bit libgo2 libraries\nAdd tools folder into roms partition\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/02132021/arkosupdate02132021.zip -O /home/ark/arkosupdate02132021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02132021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate02132021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate02132021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate02132021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02132021.bak | tee -a "$LOG_FILE"
		sudo sed -i '/<core>flycast_xtreme<\/core>/c\\t\t\t  <core>flycast32_rumble<\/core>\n\t\t\t  <core>flycast_xtreme<\/core>' /etc/emulationstation/es_systems.cfg
		if [ ! -d "/roms/tools/" ]; then
			sudo mkdir -v /roms/tools | tee -a "$LOG_FILE"
		fi
		if [ ! -d "/opt/system/tools/" ]; then
			mkdir -v /opt/system/tools | tee -a "$LOG_FILE"
		fi
		sudo sed -i '/\/dev\/mmcblk0p3/c\\/dev\/mmcblk0p3 \/roms exfat defaults,auto,umask=000,noatime 0 0\n/roms/tools /opt/system/Tools none bind' /etc/fstab
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nReduce cpu usage of global events hotkey daemon\n" | tee -a "$LOG_FILE"
	sudo sed -i '/if event.code != 0/c\        time.sleep(0.001)' /usr/local/bin/oga_events.py
	sudo sed -i '/print(event.code, event.value)/c\' /usr/local/bin/oga_events.py
	sudo sed -i '/print(keys)/c\            #print(keys)' /usr/local/bin/oga_events.py

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02132021"
fi

if [ ! -f "/home/ark/.config/.update02132021-1" ]; then

	printf "\nAdd USB drive mount and unmount to options menu\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/02132021-1/USB%20Drive%20Mount.sh -O "/opt/system/USB Drive Mount.sh" -a "$LOG_FILE" || rm -f "/opt/system/USB Drive Mount.sh" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/02132021-1/USB%20Drive%20Unmount.sh -O "/opt/system/USB Drive Unmount.sh" -a "$LOG_FILE" || rm -f "/opt/system/USB Drive Unmount.sh" | tee -a "$LOG_FILE"
	if [ -f "/opt/system/USB Drive Mount.sh" ] && [ -f "/opt/system/USB Drive Unmount.sh" ]; then
		sudo chmod 777 "/opt/system/USB Drive Mount.sh" | tee -a "$LOG_FILE"
		sudo chmod 777 "/opt/system/USB Drive Unmount.sh" | tee -a "$LOG_FILE"
		sudo chown ark:ark "/opt/system/USB Drive Mount.sh" | tee -a "$LOG_FILE"
		sudo chown ark:ark "/opt/system/USB Drive Unmount.sh" | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02132021-1"
fi

if [ ! -f "/home/ark/.config/.update02132021-2" ]; then

	printf "\nFix global hotkeys not working after 02132021 update\n" | tee -a "$LOG_FILE"
	sudo sed -i '/print(device.name, event)/c\' /usr/local/bin/oga_events.py

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02132021-2"
fi

if [ ! -f "/home/ark/.config/.update02192021" ]; then

	printf "\nAdd ZX81 lr emulator\nClean up USB mount script\nAdd pico-8 as system\nUpdate NES box theme to include pico-8\nUpdate Emulationstation to support scraping pico-8\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/02192021/arkosupdate02192021.zip -O /home/ark/arkosupdate02192021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02192021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate02192021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate02192021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate02192021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02192021.bak | tee -a "$LOG_FILE"
		sudo sed -i -e '/<theme>doom<\/theme>/{r /home/ark/add_pico8.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<theme>msx2<\/theme>/{r /home/ark/add_zx81.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_pico8.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_zx81.txt | tee -a "$LOG_FILE"
		if [ ! -d "/roms/pico-8/" ]; then
			sudo mkdir -v /roms/pico-8 | tee -a "$LOG_FILE"
			sudo mkdir -v /roms/pico-8/carts | tee -a "$LOG_FILE"
			sudo cp -v /roms/bios/pico-8/sdl_controllers.txt /roms/pico-8/sdl_controllers.txt | tee -a "$LOG_FILE"
		fi
		if [ ! -d "/roms/zx81/" ]; then
			sudo mkdir -v /roms/zx81 | tee -a "$LOG_FILE"
		fi
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update02192021"
fi

if [ ! -f "/home/ark/.config/.update02202021" ]; then

	printf "\nAllow splore and different aspect ratios for Pico-8\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/02202021/arkosupdate02202021.zip -O /home/ark/arkosupdate02202021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02202021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate02202021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate02202021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate02202021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02202021.bak | tee -a "$LOG_FILE"
		sudo sed -i '/<extension>.png .PNG .p8 .P8<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<extension>.png .PNG .p8 .P8<\/extension>/{r /home/ark/fix_pico8.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/fix_pico8.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update02202021"
fi

if [ ! -f "/home/ark/.config/.update02272021" ]; then

	printf "\nAdd Retrorun for Dreamcast, Atomiswave, Naomi, and Saturn\nAdd LowRes NX emulator\nAdd Genesis Plus GX Wide core\nUpdate NESBOX theme\nAdd support for Fullscreen emulationstation\nUpdate Dosbox-pure to 0.11\nAdd .dosz extension for dos games\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/02272021/rk2020/arkosupdate02272021.zip -O /home/ark/arkosupdate02272021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02272021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate02272021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate02272021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate02272021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02272021.bak | tee -a "$LOG_FILE"
		sudo sed -i '/<name>Sega Atomiswave<\/name>/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>Sega Atomiswave<\/name>/{r /home/ark/new_atomiswave.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/<name>Sega Naomi<\/name>/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>Sega Naomi<\/name>/{r /home/ark/new_naomi.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/<name>dreamcast<\/name>/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>dreamcast<\/name>/{r /home/ark/new_dreamcast.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/<name>Sega Saturn<\/name>/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>Sega Saturn<\/name>/{r /home/ark/new_saturn.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<theme>pico-8<\/theme>/{r /home/ark/add_lowresnx.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/<name>genesis<\/name>/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>genesis<\/name>/{r /home/ark/new_genesis.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/<name>megadrive<\/name>/{n;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;N;d}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<name>megadrive<\/name>/{r /home/ark/new_megadrive.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i '/<extension>.exe .EXE .com .COM .bat .BAT .conf .CONF .cue .CUE .iso .ISO .zip .ZIP .m3u .M3U/s//<extension>.exe .EXE .com .COM .bat .BAT .conf .CONF .cue .CUE .iso .ISO .zip .ZIP .m3u .M3U .dosz .DOSZ/' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/new_atomiswave.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/new_naomi.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/new_dreamcast.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/new_saturn.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_lowresnx.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/new_genesis.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/new_megadrive.txt | tee -a "$LOG_FILE"
		if [ ! -d "/roms/lowresnx/" ]; then
			sudo mkdir -v /roms/lowresnx | tee -a "$LOG_FILE"
		fi
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nFix ES scraping for Super Gameboy\n" | tee -a "$LOG_FILE"	
	sudo cp -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	
	touch "/home/ark/.config/.update02272021"
fi

if [ ! -f "/home/ark/.config/.update03082021" ]; then

	#msgbox "This update includes a new kernel, video drivers, and has significant changes that may leave your ArkOS distribution in an inoperable state if not successfully completed.  It is HIGHLY RECOMMENDED YOU HAVE A BACK UP OF YOUR SD CARD BERORE PROCEEDING! You've been warned!  Type OK in the next screen to proceed."
	#var=`osk "Again, enter OK here to proceed." | tail -n 1`

	#echo "$var" | tee -a "$LOG_FILE"

	#if [[ $var = OK ]] || [[ $var = ok ]] ; then
		#printf "Proceeding with updates." | tee -a "$LOG_FILE"
	#else
		#sudo msgbox "You didn't type OK.  This update will not proceed and no changes have been made from this process."
		#printf "You didn't type OK.  This update will not proceed and no changes have been made from this process." | tee -a "$LOG_FILE"
		#exit 1
	#fi

	printf "\nUpdate retroarch and retroarch32 core_updater_buildbot_cores_url\nUpdate retroarch and retroarch32 to support OGS resolution\nAdd easyrpg as ES system with scraping support\nAdd option for ascii art loading screen\nUpdate nes-box theme for easyrpg\nFix dpad for ti99\nRevert lr-mgba to older faster core\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/03082021/rk2020/arkosupdate03082021.zip -O /home/ark/arkosupdate03082021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate03082021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate03082021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate03082021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate03082021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02272021.bak | tee -a "$LOG_FILE"
		sudo sed -i -e '/<theme>doom<\/theme>/{r /home/ark/add_easyrpg.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<command>sudo perfmax; \/usr\/local\/bin\/ti99.sh %ROM%; sudo perfnorm<\/command>/{r /home/ark/new_ti99.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_easyrpg.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/new_ti99.txt | tee -a "$LOG_FILE"
		sed -i '/core_updater_buildbot_cores_url/c\core_updater_buildbot_cores_url \= "https://raw.githubusercontent.com/christianhaitian/retroarch-cores/master/aarch64/"' /home/ark/.config/retroarch/retroarch.cfg
		sed -i '/core_updater_buildbot_cores_url/c\core_updater_buildbot_cores_url \= "https://raw.githubusercontent.com/christianhaitian/retroarch-cores/master/arm7hf/"' /home/ark/.config/retroarch32/retroarch.cfg
		sed -i '/core_updater_buildbot_cores_url/c\core_updater_buildbot_cores_url \= "https://raw.githubusercontent.com/christianhaitian/retroarch-cores/master/aarch64/"' /home/ark/.config/retroarch/config/Atari800/retroarch_5200.cfg
		sed -i '/core_updater_buildbot_cores_url/c\core_updater_buildbot_cores_url \= "https://raw.githubusercontent.com/christianhaitian/retroarch-cores/master/aarch64/"' /home/ark/.config/retroarch/config/Atari800/retroarch_A800.cfg
		sed -i '/core_updater_buildbot_cores_url/c\core_updater_buildbot_cores_url \= "https://raw.githubusercontent.com/christianhaitian/retroarch-cores/master/aarch64/"' /home/ark/.config/retroarch/config/Atari800/retroarch_XEGS.cfg
		if [ ! -d "/roms/easyrpg/" ]; then
			sudo mkdir -v /roms/easyrpg | tee -a "$LOG_FILE"
			touch /roms/easyrpg/menu.ldb
		fi
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix retroarch folder ownership\n" | tee -a "$LOG_FILE"
	sudo chown -v -R ark:ark ~/.config/retroarch | tee -a "$LOG_FILE"

	printf "\nFix samba name and path for ark folder\n" | tee -a "$LOG_FILE"
	sudo sed -i "/\[odroid\]/c\\[ark\]" /etc/samba/smb.conf
	sudo sed -i "/comment \= ODROID/c\   comment \= ark" /etc/samba/smb.conf
	sudo sed -i "/path \= \/home\/odroid/c\   path \= \/home\/ark" /etc/samba/smb.conf

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nCopy correct updated ES for easyrpg scraping fix\n" | tee -a "$LOG_FILE"	
	test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	if [[ $test == "3150376" ]]; then
		sudo cp -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi
	
	touch "/home/ark/.config/.update03082021"
fi

if [ ! -f "/home/ark/.config/.kernelupdate02032021" ]; then

	printf "\nInstall updated kernel, dtb, and modules\n"
	sudo wget --no-check-certificate "$LOCATION"/03082021/rgb10/newkernelnmodndtb02032021-rgb10.zip -O /home/ark/newkernelnmodndtb02032021-rgb10.zip -a "$LOG_FILE" || rm -f /home/ark/newkernelnmodndtb02032021-rgb10.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/newkernelnmodndtb02032021-rgb10.zip" ]; then
		sudo unzip -X -o /home/ark/newkernelnmodndtb02032021-rgb10.zip -d / | tee -a "$LOG_FILE"
		sudo depmod 4.4.189
		sudo rm -v /home/ark/newkernelnmodndtb02032021-rgb10.zip | tee -a "$LOG_FILE"
		sudo rm -rfv /lib/modules/4.4.189-139502-g380eeff98d35/ | tee -a "$LOG_FILE"
		sed -i '/<inputConfig type="joystick" deviceName="odroidgo2_joypad"/c\\t<inputConfig type="joystick" deviceName="GO-Advance Gamepad" deviceGUID="190000004b4800000010000000010000">' /etc/emulationstation/es_input.cfg
		cp /home/ark/.config/retroarch/autoconfig/udev/odroidgo2_joypad.cfg /home/ark/.config/retroarch/autoconfig/udev/"GO-Advance Gamepad.cfg"
		sed -i '/input_device = "odroidgo2_joypad"/c\input_device = "GO-Advance Gamepad"' /home/ark/.config/retroarch/autoconfig/udev/"GO-Advance Gamepad.cfg"
		cp /home/ark/.config/retroarch32/autoconfig/udev/odroidgo2_joypad.cfg /home/ark/.config/retroarch32/autoconfig/udev/"GO-Advance Gamepad.cfg"
		sed -i '/input_device = "odroidgo2_joypad"/c\input_device = "GO-Advance Gamepad"' /home/ark/.config/retroarch32/autoconfig/udev/"GO-Advance Gamepad.cfg"
		cp /opt/amiberry/conf/odroidgo2_joypad.cfg /opt/amiberry/conf/"GO-Advance Gamepad.cfg"
		sed -i '/input_device = "odroidgo2_joypad"/c\input_device = "GO-Advance Gamepad"' /opt/amiberry/conf/"GO-Advance Gamepad.cfg"
		sed -i '/\[odroidgo2_joypad\]/c\\[GO-Advance Gamepad\]' /opt/mupen64plus/InputAutoCfg.ini
		sed -i '/name = "odroidgo2_joypad"/c\name = "GO-Advance Gamepad"' /home/ark/.config/mupen64plus/mupen64plus.cfg
		sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,guide:b10,leftstick:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,' /roms/pico-8/sdl_controllers.txt
		sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /roms/pico-8/sdl_controllers.txt
		if [ -f "/roms/bios/pico-8/sdl_controllers.txt" ]; then
			sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,guide:b10,leftstick:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,' /roms/bios/pico-8/sdl_controllers.txt
			sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /roms/bios/pico-8/sdl_controllers.txt
		fi
		sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,leftstick:b10,guide:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,' /opt/ppsspp/assets/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /opt/ppsspp/assets/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,leftstick:b10,guide:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,' /opt/ppssppgo/assets/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /opt/ppssppgo/assets/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /opt/scummvm/extra/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /opt/scummvm/extra/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,guide:b10,leftstick:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,' /roms/ports/devilution/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /roms/ports/devilution/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,guide:b10,leftstick:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,' /roms/ports/sdlpop/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /roms/ports/sdlpop/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad,/c\190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,guide:b10,leftstick:b12,lefttrigger:b11,rightstick:b13,righttrigger:b14,start:b15,platform:Linux,' /roms/ports/VVVVVV/gamecontrollerdb.txt
		sed -i '/odroidgo2_joypad_v11",/c\190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,guide:b12,leftstick:b14,lefttrigger:b13,rightstick:b15,righttrigger:b16,start:b17,platform:Linux,' /roms/ports/VVVVVV/gamecontrollerdb.txt
		sed -i "/section 'joystick' 'odroidgo2_joypad'/c\section 'joystick' 'GO-Advance Gamepad'" /home/ark/.config/opentyrian/opentyrian.cfg
		sudo sed -i '/"odroidgo2_joypad"/c\        elif device.name == "GO-Advance Gamepad":' /usr/local/bin/oga_events.py
		sudo sed -i '/"odroidgo2_joypad"/c\        if device.name == "GO-Advance Gamepad":' /usr/local/bin/openborkeydemon.py
		sudo sed -i '/"odroidgo2_joypad"/c\        if device.name == "GO-Advance Gamepad":' /usr/local/bin/pico8keydemon.py
		sudo sed -i '/"odroidgo2_joypad"/c\        if device.name == "GO-Advance Gamepad":' /usr/local/bin/ppssppkeydemon.py
		sudo sed -i '/"odroidgo2_joypad"/c\        if device.name == "GO-Advance Gamepad":' /usr/local/bin/solarushotkeydemon.py
		sudo sed -i '/"odroidgo2_joypad"/c\        if device.name == "GO-Advance Gamepad":' /usr/local/bin/ti99keydemon.py
	else
		printf "\nThe update of your kernel couldn't complete because the kernel package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.kernelupdate02032021"
fi

if [ ! -f "/home/ark/.config/.update03182021" ]; then

	printf "\nUpdate oga_events service to use ogage instead\nUpdate retrorun and retrorun32\nUpdate saturn.sh to fix retrorun triggers\nUpdate rtl8812au wifi adapter\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/03182021/rk2020/arkosupdate03182021.zip -O /home/ark/arkosupdate03182021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate03182021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate03182021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate03182021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate03182021.zip | tee -a "$LOG_FILE"
		sudo apt update -y && sudo apt -y install brightnessctl uboot bootini
		sudo sed -i '/ExecStart/c\ExecStart\=\/usr\/local\/bin\/ogage' /etc/systemd/system/oga_events.service
		sudo systemctl daemon-reload
		sudo depmod 4.4.189
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update03182021"
fi

if [ ! -f "/home/ark/.config/.update03182021-1" ]; then

	printf "\nAdd battery indicator service\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/03182021-1/rgb10rk2020/arkosupdate03182021-1.zip -O /home/ark/arkosupdate03182021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate03182021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate03182021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate03182021-1.zip -d / | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		sudo systemctl enable batt_led.service
		sudo systemctl start batt_led.service
		sudo rm -v /home/ark/arkosupdate03182021-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update03182021-1"
fi

if [ ! -f "/home/ark/.config/.update03202021" ]; then

	printf "\nUpdate hotkey for retrorun and retrorun32 to L2 to fix coin\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/03202021/rk2020/arkosupdate03202021.zip -O /home/ark/arkosupdate03202021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate03202021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate03202021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate03202021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate03202021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update03202021"
fi

if [ ! -f "/home/ark/.config/.update04032021" ]; then

	printf "\nFix battery indicator service\nUpdate to Retroarch 1.9.1\nUpdated ogage\nUpdate perfmax script for better battery life\nReplace glupen64 with mupen64plus core\nIncrease emulation process priority\nUpdate Hypseus to 1.3.0\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/04032021/rk2020/arkosupdate04032021.zip -O /home/ark/arkosupdate04032021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04032021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04032021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04032021.zip -d / | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		sudo systemctl restart batt_led.service
		sed -i '/<core>glupen64/s//<core>mupen64plus/' /etc/emulationstation/es_systems.cfg
		sed -i '/perfmax/s//perfmax %EMULATOR% %CORE%/' /etc/emulationstation/es_systems.cfg
		sed -i '/%CORE%;/s//%CORE%; nice -n -19/' /etc/emulationstation/es_systems.cfg
		sed -i '/\/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/hatari_libretro.so/s//nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/hatari_libretro.so/' /etc/emulationstation/es_systems.cfg
		sed -i '/nice -n -19 sudo systemctl start/s//sudo systemctl start/' /etc/emulationstation/es_systems.cfg
		sed -i '/\/usr\/local\/bin\/pico8.sh/s//nice -n -19 \/usr\/local\/bin\/pico8.sh/' /etc/emulationstation/es_systems.cfg
		sudo chmod -v +s /usr/bin/nice | tee -a "$LOG_FILE"
		sudo rm -v /opt/system/Switch\ Launchimage\ to\ jpg.sh | tee -a "$LOG_FILE"
		sudo cp -n -v /usr/local/bin/Switch\ Launchimage\ to\ ascii.sh /opt/system/. | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04032021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04032021"
fi

if [ ! -f "/home/ark/.config/.update04162021" ]; then

	printf "\nUpdate Enable Remote Services script to show assigned IP and 5s pause\nUpdate perfmax and perfnorm for image blinking fix\nUpdate emulationstaton fullscreen and header to not use Batocera's scraping ID\nUpdate ScummVM with AGS support\nUpdate video shader delay settings\nAdd ability to disable battery warning\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/04162021/rgb10rk2020/arkosupdate04162021.zip -O /home/ark/arkosupdate04162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04162021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04162021.zip" ]; then
		if [ $(wc -c < /usr/bin/emulationstation/emulationstation) -ne $(wc -c < /usr/bin/emulationstation/emulationstation.fullscreen) ]; then
		  header=1
		else
		  header=0
		fi
		sudo unzip -X -o /home/ark/arkosupdate04162021.zip -d / | tee -a "$LOG_FILE"
		cp -f -v /usr/local/bin/"disable low battery warning.sh" /opt/system/Advanced/.
		if [ $header -eq 1 ]; then
		  sudo cp /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation
		else
		  sudo cp /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation
		fi
		if [ -f "/opt/system/Switch Launchimage to ascii.sh" ]; then
		  sudo cp -f -v /usr/local/bin/perfmax.pic /usr/local/bin/perfmax | tee -a "$LOG_FILE"
		  sudo cp -f -v /usr/local/bin/perfnorm.pic /usr/local/bin/perfnorm | tee -a "$LOG_FILE"
		else
		  sudo cp -f -v /usr/local/bin/perfmax.asc /usr/local/bin/perfmax | tee -a "$LOG_FILE"
		  sudo cp -f -v /usr/local/bin/perfnorm.asc /usr/local/bin/perfnorm | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate04162021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix retroarch shaders not autoloading when saved as override\n" | tee -a "$LOG_FILE"
	sudo sed -i '/video_shader_delay \= \"3\"/s//video_shader_delay \= \"0\"/' /home/ark/.config/retroarch/retroarch.cfg
	sudo sed -i '/video_shader_delay \= \"3\"/s//video_shader_delay \= \"0\"/' /home/ark/.config/retroarch32/retroarch.cfg	

	printf "\nEnsure 64bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04162021"
fi

if [ ! -f "/home/ark/.config/.update04222021" ]; then

	printf "\nAdd Video Player\nAdd ability to restore default retroarch.cfg\nAdd UAE4arm_libretro.so for retroarch32\nAdd potatore core for Watara\nAdd section for MD MSU\nUpdate Emulationstation to support Waratar Supervision scraping\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/04222021/rk2020/arkosupdate04222021.zip -O /home/ark/arkosupdate04222021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04222021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04222021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04222021.zip -d / | tee -a "$LOG_FILE"
		sudo apt update -y && sudo apt -y install ffmpeg | tee -a "$LOG_FILE"
		if [ ! -d "/roms/videos/" ]; then
			sudo mkdir -v /roms/videos | tee -a "$LOG_FILE"
		fi
		if [ ! -d "/roms/supervision/" ]; then
			sudo mkdir -v /roms/supervision | tee -a "$LOG_FILE"
		fi
		if [ ! -d "/roms/msumd/" ]; then
			sudo mkdir -v /roms/msumd | tee -a "$LOG_FILE"
		fi
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04222021.bak | tee -a "$LOG_FILE"
		sudo sed -i -e '/<theme>uzebox<\/theme>/{r /home/ark/add_videos.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<theme>uzebox<\/theme>/{r /home/ark/add_supervision.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<theme>megadrive<\/theme>/{r /home/ark/add_msumd.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '/<core>puae<\/core>/{r /home/ark/add_uae4arm.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo sed -i -e '\/puae_libretro.so/{r /home/ark/add_uae4armcd.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_uae4arm.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_uae4armcd.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_msumd.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_supervision.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_videos.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04222021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct updated ES for supervision scraping fix\n" | tee -a "$LOG_FILE"	
	test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	if [[ $test == "3835024" ]]; then
		sudo cp -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi
	
	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04222021"
fi

if [ ! -f "/home/ark/.config/.update05012021" ]; then

	printf "\nAdd Support for Sonic 1, 2, and 3 Ports\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate "$LOCATION"/05012021/rk2020/arkosupdate05012021.zip -O /home/ark/arkosupdate05012021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05012021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05012021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05012021.zip -d / | tee -a "$LOG_FILE"
		sudo sed -i '/ScreenWidth\=320/s//ScreenWidth\=360/' /roms/ports/sonic1/settings.ini
		sudo sed -i '/ScreenWidth\=320/s//ScreenWidth\=360/' /roms/ports/sonic2/settings.ini
		sudo sed -i '/ScreenWidth\=320/s//ScreenWidth\=360/' /roms/ports/soniccd/settings.ini
		sudo systemctl daemon-reload
		sudo rm -v /home/ark/arkosupdate05012021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nRename Run Command to Retroarch\nRename System to Options\n" | tee -a "$LOG_FILE"
	sed -i '/<fullname>Run command/s//<fullname>Retroarch/' /etc/emulationstation/es_systems.cfg
	sed -i '/<fullname>System/s//<fullname>Options/' /etc/emulationstation/es_systems.cfg
	sed -i '/<name>retropie/s//<name>Options/' /etc/emulationstation/es_systems.cfg

	printf "\nRename some Advanced options to better fit the screen\n" | tee -a "$LOG_FILE"
	sudo mv -f -v /opt/system/Advanced/disable\ low\ battery\ warning.sh /opt/system/Advanced/Disable\ Low\ Battery\ Warning.sh | tee -a "$LOG_FILE"
	sudo mv -f -v /opt/system/Advanced/Backup\ Settings.sh /opt/system/Advanced/Backup\ ArkOS\ Settings.sh | tee -a "$LOG_FILE"
	sudo mv -f -v /opt/system/Advanced/Restore\ Settings.sh /opt/system/Advanced/Restore\ ArkOS\ Settings.sh | tee -a "$LOG_FILE"
	sudo mv -f -v /opt/system/Advanced/Restore\ Default\ Retroarch\ Settings.sh /opt/system/Advanced/"Reset Retroarch Settings.sh" | tee -a "$LOG_FILE"
	sudo mv -f -v /opt/system/Advanced/Restore\ Default\ Retroarch32\ Settings.sh /opt/system/Advanced/"Reset Retroarch32 Settings.sh" | tee -a "$LOG_FILE"
	sudo mv -f -v /opt/system/Advanced/Restore\ Default\ Retroarch\ Core\ Settings.sh /opt/system/Advanced/"Reset Retroarch Core Settings.sh" | tee -a "$LOG_FILE"
	sudo mv -f -v /opt/system/Advanced/Restore\ Default\ Retroarch32\ Core\ Settings.sh /opt/system/Advanced/"Reset Retroarch32 Core Settings.sh" | tee -a "$LOG_FILE"
	sudo chown -R ark:ark /opt/system/Advanced/

	printf "\nDisable low battery warning by default\n" | tee -a "$LOG_FILE"
	sudo systemctl disable batt_led
	sudo systemctl stop batt_led
	sudo cp -f -v /usr/local/bin/enable\ low\ battery\ warning.sh /opt/system/Advanced/.
	sudo rm -f -v /opt/system/Advanced/disable\ low\ battery\ warning.sh

	printf "\nSet Screenshot directory to _screenshot in roms folder for retroarch and retroarch32\n" | tee -a "$LOG_FILE"
	if [ ! -d "/roms/_screenshots/" ]; then
		sudo mkdir -v /roms/_screenshots | tee -a "$LOG_FILE"
	fi
	sed -i '/screenshot_directory \= \"default\"/s//screenshot_directory \= \"\/roms\/_screenshots\"/' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/screenshot_directory \= \"default\"/s//screenshot_directory \= \"\/roms\/_screenshots\"/' /home/ark/.config/retroarch32/retroarch.cfg
	sudo chown ark:ark /home/ark/.config/retroarch/retroarch.cfg
	sudo chown ark:ark /home/ark/.config/retroarch32/retroarch.cfg
	
	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.6 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05012021"
fi

if [ ! -f "/home/ark/.config/.update05112021" ]; then

	printf "\033c" > /dev/tty1
	printf "\nPreparing to enter The Matrix" > /dev/tty1
	sleep 1.5 && printf "."  > /dev/tty1 && sleep 1.5 && printf "." > /dev/tty1 && sleep 1.5 && printf ".\n" > /dev/tty1
	printf "\033[32m" > /dev/tty1
	
	printf "\nUpdate Retroarch and Retroarch32 to 1.9.2\nAdd SuperTux\nAdd Mr. Boom\nAdd Dinothawr\nAdd Super Mario War\nAdd CDogs\nFix exit hotkey for Sonic CD\nAdd Hydra Castle Labyrinth\nAdd support for Shovel Knight Treasure Trove\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05112021/rk2020/arkosupdate05112021.zip -O /home/ark/arkosupdate05112021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05112021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05112021/rk2020/arkosupdate05112021.z01 -O /home/ark/arkosupdate05112021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05112021.z01 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05112021/rk2020/arkosupdate05112021.z02 -O /home/ark/arkosupdate05112021.z02 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05112021.z02 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05112021/rk2020/arkosupdate05112021.z03 -O /home/ark/arkosupdate05112021.z03 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05112021.z03 | tee -a "$LOG_FILE"
	if  [ -f "/home/ark/arkosupdate05112021.zip" ] && [ -f "/home/ark/arkosupdate05112021.z01" ] && [ -f "/home/ark/arkosupdate05112021.z02" ] && [ -f "/home/ark/arkosupdate05112021.z03" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.191.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.191.bak | tee -a "$LOG_FILE"
		cd /home/ark/
		sudo apt update -y && sudo apt install -y zip | tee -a "$LOG_FILE"
		sudo zip -F arkosupdate05112021.zip --out arkosupdate.zip | tee -a "$LOG_FILE"
		sudo rm -fv arkosupdate05112021.z* | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "Due to the size of this update, synchronizing the data on disk with memory to be sure the update is done right." | tee -a "$LOG_FILE"
	sync

	printf "\nIncrease default audio gain for retroarch and retroarch32\n" | tee -a "$LOG_FILE"
	sed -i '/audio_volume \= \"-4.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch32/retroarch.cfg
	sed -i '/audio_volume \= \"-4.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/audio_volume \= \"-4.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	sed -i '/audio_volume \= \"-4.500000\"/c\audio_volume \= \"6.0\"' /home/ark/.config/retroarch/retroarch.cfg.bak

	printf "\nUpdate screenshot default directory for backup retroarch configs\n" | tee -a "$LOG_FILE"
	sed -i '/screenshot_directory \= \"default\"/s//screenshot_directory \= \"\/roms\/_screenshots\"/' /home/ark/.config/retroarch/retroarch.cfg.bak
	sed -i '/screenshot_directory \= \"default\"/s//screenshot_directory \= \"\/roms\/_screenshots\"/' /home/ark/.config/retroarch32/retroarch.cfg.bak

	printf "\nDisable the ability for cores to be able to change video modes in retroarch and retroarch32\n" | tee -a "$LOG_FILE"
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch32/retroarch.cfg
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/driver_switch_enable \= \"true\"/c\driver_switch_enable \= \"false\"' /home/ark/.config/retroarch/retroarch.cfg.bak
	
	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nThe Matrix now has you" > /dev/tty1
	sleep 1.5 && printf "." > /dev/tty1 && sleep 1.5 && printf "." > /dev/tty1 && sleep 1.5 && printf ".\n" > /dev/tty1

	touch "/home/ark/.config/.update05112021"
fi

if [ ! -f "/home/ark/.config/.update05192021" ]; then

	printf "\033c" > /dev/tty1
	printf "\nPreparing to enter The Matrix" > /dev/tty1
	sleep 1.5 && printf "."  > /dev/tty1 && sleep 1.5 && printf "." > /dev/tty1 && sleep 1.5 && printf ".\n" > /dev/tty1
	printf "\033[32m" > /dev/tty1

	printf "\nAdd Maldita Castilla, Spelunky, Undertale support, AM2R,\n scripts to generate m4u files for ps1, show only m3u ps1, \nand blank screen to simulatte quick sleep\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05192021/rk2020/arkosupdate05192021.zip -O /home/ark/arkosupdate05192021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05192021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05192021/rk2020/arkosupdate05192021.z01 -O /home/ark/arkosupdate05192021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05192021.z01 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05192021/rk2020/arkosupdate05192021.z02 -O /home/ark/arkosupdate05192021.z02 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05192021.z02 | tee -a "$LOG_FILE"
	if  [ -f "/home/ark/arkosupdate05192021.zip" ] && [ -f "/home/ark/arkosupdate05192021.z01" ] && [ -f "/home/ark/arkosupdate05192021.z02" ]; then
		cd /home/ark/
		printf "\033[32m" > /dev/tty1
		sudo zip -F arkosupdate05192021.zip --out arkosupdate.zip | tee -a "$LOG_FILE"
		sudo rm -fv arkosupdate05192021.z* | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "Due to the size of this update, synchronizing the data on disk with memory to be sure the update is done right." | tee -a "$LOG_FILE"
	sync

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\n\n\n\n\n\nThe Matrix now has you\n\n\n\n\n\n" > /dev/tty1
	sleep 1.5 && printf "." > /dev/tty1 && sleep 1.5 && printf "." > /dev/tty1 && sleep 1.5 && printf ".\n" > /dev/tty1

	touch "/home/ark/.config/.update05192021"
fi

if [ ! -f "/home/ark/.config/.update05192021-1" ]; then

	printf "\nFix AM2R\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05192021/rk2020/arkosupdate05192021-1.zip -O /home/ark/arkosupdate05192021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05192021-1.zip | tee -a "$LOG_FILE"
	if  [ -f "/home/ark/arkosupdate05192021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05192021-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate05192021-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05192021-1"
fi

if [ ! -f "/home/ark/.config/.update06042021" ]; then

	printf "\nAdd Clear last played collection script\nFix Scraping for c16 and c128\nFix .bs snes hacks not loading\nUpdate Retroarches to 1.9.4\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06042021/rgb10rk2020/arkosupdate06042021.zip -O /home/ark/arkosupdate06042021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06042021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06042021.zip" ]; then
		# The following 2 cp lines backup the existing standalone mupen64plus core and audio plugin to restore later in this update process
		# as there was a planned update of those but through further late testing revealed worse performance after the update package was 
		# already created with them included.
		cp -v /opt/mupen64plus/libmupen64plus.so.2.0.0 /opt/mupen64plus/libmupen64plus.so.2.0.0.bak | tee -a "$LOG_FILE"
		cp -v /opt/mupen64plus/mupen64plus-audio-sdl.so /opt/mupen64plus/mupen64plus-audio-sdl.so.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.192.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.192.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate06042021.zip -d / | tee -a "$LOG_FILE"
		# The following 2 cp lines restore the existing standalone mupen64plus core and audio plugin.
		cp -f -v /opt/mupen64plus/libmupen64plus.so.2.0.0.bak /opt/mupen64plus/libmupen64plus.so.2.0.0 | tee -a "$LOG_FILE"
		cp -f -v /opt/mupen64plus/mupen64plus-audio-sdl.so.bak /opt/mupen64plus/mupen64plus-audio-sdl.so | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06042021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<command>sudo perfmax \%EMULATOR\% \%CORE\%\; nice \-n \-19 \/usr\/local\/bin\/retroarch \-L \/home\/ark\/.config\/retroarch\/cores\/snes9x2010_libretro.so \%ROM\%\; sudo perfnorm<\/command>/{r /home/ark/fix_sneshacks.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i '/Nintendo - Super Famicom 2010/s//Nintendo - Super NES Hacks/' /etc/emulationstation/es_systems.cfg
		sudo rm -f -v /home/ark/fix_sneshacks.txt | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/arkosupdate06042021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix Rick Dangerous for Retroarch 1.9.4 update\n" | tee -a "$LOG_FILE"
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

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nCopy correct updated ES for supervision scraping fix\n" | tee -a "$LOG_FILE"	
	test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	if [[ $test == "3224160" ]]; then
		sudo cp -f -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -f -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi

	touch "/home/ark/.config/.update06042021"
fi

if [ ! -f "/home/ark/.config/.update07022021" ]; then

	printf "\nFix c16, c128, and supervision scraping for ES Fullscreen\nAdd support for American Laser Games\nAdd supafaust snes core\nAdd support for scraping of American Laser Games\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07022021/rk2020/arkosupdate07022021.zip -O /home/ark/arkosupdate07022021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07022021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07022021.zip" ]; then
		if [ ! -d "/roms/alg/" ]; then
			sudo mkdir -v /roms/alg | tee -a "$LOG_FILE"
		fi
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.194.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.194.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate07022021.zip -d / | tee -a "$LOG_FILE"
		sudo chown ark:ark /etc/emulationstation/es_systems.cfg
		cp -f -v /opt/hypseus/hypinput.ini /opt/hypseus-singe/hypinput.ini | tee -a "$LOG_FILE"
		cp -f -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07022021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<theme>daphne<\/theme>/{r /home/ark/add_alg.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i "/<core>snes9x2010<\/core>/c\ \t\t\t  <core>snes9x2010<\/core>\n\t\t\t  <core>mednafen_supafaust<\/core>" /etc/emulationstation/es_systems.cfg
		sudo rm -rf /opt/hypseus-singe/singe | tee -a "$LOG_FILE"
		ln -sfv /roms/alg/ /opt/hypseus-singe/singe | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/arkosupdate07022021.zip | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/add_alg.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nCopy correct updated ES for supervision scraping fix\n" | tee -a "$LOG_FILE"	
	test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	if [[ $test == "3228256" ]]; then
		sudo cp -f -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -f -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi

	touch "/home/ark/.config/.update07022021"
fi

if [ ! -f "/home/ark/.config/.update07282021" ]; then

	printf "\nFix OpenBOR not copying master.cfg correctly\nStop symlinks from changing for aarch64 and arm32\nChange mednafen_vb options cpu emulation to fast\nAdd retroarch info file for flycast32_rumble\nAdd 351Files\nAdd scanning and other changes for EasyRPG\nAdd plaidman doom loader\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07282021/rk2020/arkosupdate07282021.zip -O /home/ark/arkosupdate07282021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07282021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07282021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07282021.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07282021.bak | tee -a "$LOG_FILE"
		sed -i '/.ldb .LDB/s//.easyrpg .EASYRPG/' /etc/emulationstation/es_systems.cfg
		sed -i '/.wad .WAD .sh .SH/s//.wad .WAD .sh .SH .doom .DOOM/' /etc/emulationstation/es_systems.cfg
		sed -i '/supported_extensions \= /c\supported_extensions \= \"ldb|easyrpg|zip\"' /home/ark/.config/retroarch/cores/easyrpg_libretro.info
		sed -i '/\/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/easyrpg_libretro.so/s//\/usr\/local\/bin\/easyrpg.sh/' /etc/emulationstation/es_systems.cfg
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
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07282021"
fi

if [ ! -f "/home/ark/.config/.update08272021" ]; then

	printf "\nUpdate Retroarch to 1.9.8\nFix Timezone issue for Hong_Kong and others in Emulationstation\nAdd Wolfenstein3d as system\nAdd genesis_plus_gx_wide 64bit\nAdd PortMaster to Options/Tool section\nAdd support for online updating from China\nDisable Performance mode changes using hotkeys\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08272021/rk2020/arkosupdate08272021.zip -O /home/ark/arkosupdate08272021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08272021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08272021.zip" ]; then
		mkdir -v /roms/wolf | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.196.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.196.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate08272021.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08272021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<theme>doom<\/theme>/{r /home/ark/add_wolf.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i "/<core>genesis_plus_gx<\/core>/c\ \t\t\t  <core>genesis_plus_gx<\/core>\n\t\t\t  <core>genesis_plus_gx_wide<\/core>" /etc/emulationstation/es_systems.cfg
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
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
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
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08292021"
fi

if [ ! -f "/home/ark/.config/.update09212021" ]; then

	printf "\nAdd quicknes as a supported core for NES and Famicom Disk System\nAdd video filters for retroarch and retroarch32\nAdd BaRT (Boot and Recovery Tool)\nAdd Astrocade and Channel F emulators\nAdd scraping support for Astrocade for Emulationstation\nAdd ability to switch A/B button in Emulationstation\nUpdate NesBox Theme\nAdd 32bit gpsp core\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/rgb10rk2020/arkosupdate09212021.zip -O /home/ark/arkosupdate09212021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/rgb10rk2020/arkosupdate09212021.z01 -O /home/ark/arkosupdate09212021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.z01 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/rgb10rk2020/arkosupdate09212021.z02 -O /home/ark/arkosupdate09212021.z02 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.z02 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate09212021.zip" ] && [ -f "/home/ark/arkosupdate09212021.z01" ] && [ -f "/home/ark/arkosupdate09212021.z02" ]; then
		sudo rm -rf /roms/themes/es-theme-nes-box/ | tee -a "$LOG_FILE"
		zip -FF /home/ark/arkosupdate09212021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate09212021.z* | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		mkdir -v /roms/channelf | tee -a "$LOG_FILE"
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
		sudo rm -v /home/ark/add_astrocade.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_channelf.txt | tee -a "$LOG_FILE"
		sudo rm -fv arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct updated ES for astrocade scraping\n" | tee -a "$LOG_FILE"	
	test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	if [ $test = "3228256" ]; then
		sudo cp -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09212021"
fi

if [ ! -f "/home/ark/.config/.update10162021" ]; then

	printf "\nUpdate Emulationstation\nUpdate controls for Solarus\nFix OpenBOR configuration loading and saving\nAdd Satellaview\nUpdate ScummVM to 2.5\nUpdate Retroarch to 1.9.11\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021/rgb10rk2020/arkosupdate10162021.zip -O /home/ark/arkosupdate10162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021/rgb10rk2020/arkosupdate10162021.z01 -O /home/ark/arkosupdate10162021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021.z01 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10162021.zip" ] && [ -f "/home/ark/arkosupdate10162021.z01" ]; then
		zip -FF /home/ark/arkosupdate10162021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate10162021.z* | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.198.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.198.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		mkdir -v /roms/satellaview | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update10162021.bak | tee -a "$LOG_FILE"
		inputtest=$(cat /etc/emulationstation/es_input.cfg | grep "rev 1.1")
		if [ -z "$inputtest" ]; then
		  echo "doing nothing here"
		  #sed -i "/<\/inputConfig>/c\ \t\t<input name=\"system_hk\" type=\"button\" id=\"15\" value=\"1\" />\n        <\/inputConfig>" /etc/emulationstation/es_input.cfg
		else
		  sed -i "/<\/inputConfig>/c\ \t\t<input name=\"system_hk\" type=\"button\" id=\"16\" value=\"1\" />\n        <\/inputConfig>" /etc/emulationstation/es_input.cfg
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep satellaview)"
		then
		  sed -i -e '/<theme>arcade<\/theme>/{r /home/ark/add_satellaview.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
		  cd /home/ark/sd_fuse
		  sudo dd if=idbloader.img of=/dev/mmcblk0 conv=notrunc bs=512 seek=64 | tee -a "$LOG_FILE"
		  sudo dd if=uboot.img of=/dev/mmcblk0 conv=notrunc bs=512 seek=16384 | tee -a "$LOG_FILE"
		  sudo dd if=trust.img of=/dev/mmcblk0 conv=notrunc bs=512 seek=24576 | tee -a "$LOG_FILE"
		  sync
		  cd /home/ark
		fi
		cp -r -v .solarus/ /roms/solarus/ | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_satellaview.txt | tee -a "$LOG_FILE"
		sudo rm -rf -v /home/ark/sd_fuse | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct updated ES\n" | tee -a "$LOG_FILE"	
	test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	if [ $test = "3232392" ]; then
		sudo cp -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
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
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
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
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10172021"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate to Retroarch 1.9.12\nAdd MegaDuck\nUpdate standalone PPSSPP to 1.12.3\nUpdate liblcf for EasyRPG 0.7.0 future update\nUpdate Emulationstation for megaduck scraping and fix mixv2 scraping\nAdd .7z support for various systems\nAdd .zip support for Amiga\nAdd .vsf support for c64\nAdd ability to hide .zip for DOS games\nUpdate nes-box theme for megaduck\nFix Space key for non English ES\nIgnore options and retroarch for auto collections\nUpdate update script\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11052021/arkosupdate11052021.zip -O /home/ark/arkosupdate11052021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11052021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11052021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1911.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1911.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate11052021.zip -x /opt/ppsspp/backupforromsfolder/* -d / | tee -a "$LOG_FILE"
		sudo rm /home/ark/.config/retroarch/cores/*.lck
		sudo rm /home/ark/.config/retroarch32/cores/*.lck
		mkdir -v /roms/megaduck | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11052021.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep megaduck)"
		then
		  sed -i -e '/<theme>cps3<\/theme>/{r /home/ark/add_megaduck.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
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

	printf "\nCopy correct updated ES\n" | tee -a "$LOG_FILE"	
    sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	if [ $test = "3240584" ]; then
		sudo cp -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi

	printf "\nAdd ability to recreate sdl_controllers.txt for pico-8\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /usr/local/bin/pico8.sh | grep sdl_controllers)"
	then
	  sudo sed -i '/bash/s//bash\n\nif [[ ! -f \"\/roms\/pico-8\/sdl_controllers.txt\" ]]\; then\necho \"19000000030000000300000002030000\,gameforce_gamepad\,leftstick:b14\,rightx:a3\,leftshoulder:b4\,start:b9\,lefty:a0\,dpup:b10\,righty:a2\,a:b1\,b:b0\,guide:b16\,dpdown:b11\,rightshoulder:b5\,righttrigger:b7\,rightstick:b15\,dpright:b13\,x:b2\,back:b8\,leftx:a1\,y:b3\,dpleft:b12\,lefttrigger:b6\,platform:Linux\,\n190000004b4800000010000000010000\,GO-Advance Gamepad\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:b7\,dpleft:b8\,dpright:b9\,dpup:b6\,leftx:a0\,lefty:a1\,guide:b10\,leftstick:b12\,lefttrigger:b11\,rightstick:b13\,righttrigger:b14\,start:b15\,platform:Linux\,\n190000004b4800000010000001010000\,GO-Advance Gamepad (rev 1.1)\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:b9\,dpleft:b10\,dpright:b11\,dpup:b8\,leftx:a0\,lefty:a1\,guide:b12\,leftstick:b14\,lefttrigger:b13\,rightstick:b15\,righttrigger:b16\,start:b17\,platform:Linux\,\n190000004b4800000011000000010000\,GO-Super Gamepad\,x:b2\,a:b1\,b:b0\,y:b3\,back:b12\,start:b13\,dpleft:b10\,dpdown:b9\,dpright:b11\,dpup:b8\,leftshoulder:b4\,lefttrigger:b6\,rightshoulder:b5\,righttrigger:b7\,leftstick:b14\,rightstick:b15\,leftx:a0\,lefty:a1\,rightx:a2\,righty:a3\,platform:Linux\,\n03000000091200000031000011010000\,OpenSimHardware OSH PB Controller\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:h0.4\,dpleft:h0.8\,dpright:h0.2\,dpup:h0.1\,guide:b7\,leftstick:b14\,lefttrigger:b13\,rightstick:b15\,righttrigger:b16\,leftx:a0~\,lefty:a1~\,start:b6\,platform:Linux\,\" \> \/roms\/pico-8\/sdl_controllers.txt\nfi/' /usr/local/bin/pico8.sh
	fi

	printf "\nDisable restart of global hotkey daemon\n" | tee -a "$LOG_FILE"
	sudo sed -i '/sudo systemctl restart oga_events/s//\# sudo systemctl restart oga_events/' /usr/lib/systemd/system-sleep/sleep

	printf "\nRemove old logs, cache and backup folder files from var folder\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	sudo journalctl --vacuum-time=1s | tee -a "$LOG_FILE"

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187
fi