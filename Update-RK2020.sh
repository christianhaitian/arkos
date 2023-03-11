#!/bin/bash
clear

UPDATE_DATE="03112023"
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
		sudo depmod -a
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
		sudo depmod -a
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

if [ ! -f "/home/ark/.config/.update11052021" ]; then

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

	touch "/home/ark/.config/.update11052021"
fi

if [ ! -f "/home/ark/.config/.update11092021" ]; then

	printf "\nUpdate to Retroarch 1.9.13\nUpdate PPSSPP to newer commit of 1.12.3 to address glitches\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11092021/arkosupdate11092021.zip -O /home/ark/arkosupdate11092021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11092021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11092021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1912.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1912.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate11092021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11092021.zip | tee -a "$LOG_FILE"
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

	touch "/home/ark/.config/.update11092021"
fi

if [ ! -f "/home/ark/.config/.update12222021" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.9.14\nUpdate ScummVM\nReplace Solarus 1.7.0 with 1.6.5 with control patch\nFix retrorun and retrorun32 emus with 1 sd card\nUpdate easyrpg scan script\nAdd script to switch L2/R2 for OGA1.1\nAdd Mame (Current) to Arcade system\nAdd support for mods for ecwolf\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12222021/arkosupdate12222021.zip -O /home/ark/arkosupdate12222021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12222021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12222021/arkosupdate12222021.z01 -O /home/ark/arkosupdate12222021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12222021.z01 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12222021.zip" ] && [ -f "/home/ark/arkosupdate12222021.z01" ]; then
		zip -FF /home/ark/arkosupdate12222021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate12222021.z* | tee -a "$LOG_FILE"
		sudo rm -f -v /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
		sudo rm -f -v /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1913.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1913.bak | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12222021.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		if [ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]; then
		  cp -f -v /opt/solarus/pads.ini.351v /opt/solarus/pads.ini | tee -a "$LOG_FILE"
		elif [ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]; then
			if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000")" ]; then
		      cp -f -v /opt/solarus/pads.ini.rgb10 /opt/solarus/pads.ini | tee -a "$LOG_FILE"
			else
		      cp -f -v /opt/solarus/pads.ini.rk2020 /opt/solarus/pads.ini | tee -a "$LOG_FILE"
			fi
		elif [ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]; then
		  cp -f -v /opt/solarus/pads.ini.351mp /opt/solarus/pads.ini | tee -a "$LOG_FILE"
		else
		  cp -f -v /opt/solarus/pads.ini.chi /opt/solarus/pads.ini | tee -a "$LOG_FILE"
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  cp -f -v /roms/easyrpg/Scan_for_new_games.easyrpg /roms2/easyrpg/Scan_for_new_games.easyrpg | tee -a "$LOG_FILE"
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep openmsx)"
		then
		  sed -i '/<core>fmsx<\/core>/c\\t\t \t  <core>fmsx<\/core>\n\t\t \t<\/cores>\n\t\t      <\/emulator>\n\t\t      <emulator name\=\"openmsx\">' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/openmsx/{n;d}' /etc/emulationstation/es_systems.cfg
		fi
		sudo apt -y update && sudo apt -y install psmisc | tee -a "$LOG_FILE"
		if [ -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000")" ]; then
		  sudo rm -f -v /boot/rk3326-odroidgo2-linux-v11.dtb.* | tee -a "$LOG_FILE"
		  sudo rm -f -v /usr/local/bin/"Triggers -- Enable RGB10 Version.sh" | tee -a "$LOG_FILE"
		  sudo rm -f -v /usr/local/bin/"Triggers -- Enable OGA 1.1 Version.sh" | tee -a "$LOG_FILE"
		  sudo rm -f -v /opt/system/Advanced/"Triggers -- Enable OGA 1.1 Version.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -f -v /opt/solarus/pads.ini.* | tee -a "$LOG_FILE"
		sed -i '/back:12/s//back:b12/' /opt/openmsx/gamecontrollerdb.txt
		sudo rm -v /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nAdd prg support for C64\n" | tee -a "$LOG_FILE"
	  sed -i '/<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT/s//<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .prg .PRG/' /etc/emulationstation/es_systems.cfg
	
	printf "\nAdd zip support for EasyRPG\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '.EASYRPG .ZIP')"
	then
	  sed -i '/<extension>.easyrpg .EASYRPG/s//<extension>.easyrpg .EASYRPG .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd sgd support for Genesis and MD\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '.sgd .68k')"
	then
	  sed -i '/<extension>.mdx .MDX .md .MD .smd .SMD .gen .GEN .bin .BIN .cue .CUE .iso .ISO .sms .SMS .gg .GG .sg .SG/s//<extension>.mdx .MDX .md .MD .smd .SMD .gen .GEN .bin .BIN .cue .CUE .iso .ISO .sms .SMS .gg .GG .sg .SG .sgd .SGD/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd .ecwolf support for Wolfenstein system\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '.ecwolf')"
	then
	  sed -i '/<extension>.wolf .WOLF/s//<extension>.ecwolf .ECWOLF .wolf .WOLF/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd support for mame current to Arcade system\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '<core>mame</core>')"
	then
	  sed -i -e '/Arcade - Various Platform/,/arcade</s/fbalpha2012/fbalpha2012<\/core>\n\t\t \t  <core>mame/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd support for fceumm to Famicom system\n" | tee -a "$LOG_FILE"
	sed -i '/\/home\/ark\/.config\/retroarch\/cores\/nestopia_libretro.so %ROM%; sudo perfnorm<\/command>/s//\/home\/ark\/.config\/%EMULATOR%\/cores\/%CORE%_libretro.so %ROM%; sudo perfnorm<\/command>\n                  <emulators>\n                      <emulator name="retroarch">\n                        <cores>\n                          <core>nestopia<\/core>\n                          <core>fceumm<\/core>\n                        <\/cores>\n                      <\/emulator>\n                   <\/emulators>/g' /etc/emulationstation/es_systems.cfg

	printf "\nFix atomiswave, dreamcast, and naomi not working with 1 sd card for 351v and 351mp\n" | tee -a "$LOG_FILE"
	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/atomiswave.sh
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/dreamcast.sh
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/naomi.sh
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/saturn.sh
	fi

	printf "\nForce the use of older SDL2 for hypseus due to audio sync issue\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /usr/local/bin/daphne.sh | grep -i 'libSDL2-2.0.so.0.1')"
	then
	   if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	     sudo sed -i '/\.\/hypseus/s//LD_PRELOAD=\/usr\/lib\/aarch64-linux-gnu\/libSDL2-2.0.so.0.10.0 .\/hypseus/' /usr/local/bin/daphne.sh
	   else
	     sudo sed -i '/\.\/hypseus/s//LD_PRELOAD=\/usr\/lib\/aarch64-linux-gnu\/libSDL2-2.0.so.0.14.1 .\/hypseus/' /usr/local/bin/daphne.sh
	   fi
	fi

	printf "\nCopy correct updated ES for RGB10, RK2020 and OGAs\n" | tee -a "$LOG_FILE"	
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ]; then
      sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ $test = "3240584" ] || [ $test = "3232392" ]; then
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  fi
	else
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	fi
	
	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.16.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.16.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 /usr/lib/arm-linux-gnueabihf/libSDL2.so
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.16.0.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.16.0.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 /usr/lib/arm-linux-gnueabihf/libSDL2.so
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12222021"
fi

if [ ! -f "/home/ark/.config/.update12232021" ]; then

	printf "\nFix Scraping for Emulationstation\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12232021/arkosupdate12232021.zip -O /home/ark/arkosupdate12232021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12232021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12232021.zip" ]; then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12232021.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate12232021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12232021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct updated ES for RGB10, RK2020 and OGAs\n" | tee -a "$LOG_FILE"	
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ]; then
      sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ $test = "3244680" ]; then
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  fi
	else
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	fi

	printf "\nAdd nib and tap support for C64\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .prg .PRG .nib .NIB .tap .TAP')"
	then
	  sed -i '/<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .prg .PRG/s//<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .prg .PRG .nib .NIB .tap .TAP/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12232021"
fi

if [ ! -f "/home/ark/.config/.update01212022" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.9.14\nAdd Nekop2-kai as additional PC98 emulator core\nFix scraping for PC98\nAdd yabasanshiro standalone emulator\nAdd show battery status icon in UI settings for Emulationstation fullscreen\nAdd ability to update retroarch cores in China\nAdd missing mupen64plus-next retroarch core\nUpdate Hypseus-singe\nAdd support for 64 bit pico-8 executable\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01212022/arkosupdate01212022.zip -O /home/ark/arkosupdate01212022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01212022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01212022.zip" ]; then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01212022.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1914.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1914.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate01212022.zip -d / | tee -a "$LOG_FILE"
		sudo chown -R ark:ark /opt/ | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep np2kai |  tr -d '\0')"
		then
		  sed -i -e '/<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/nekop2_libretro.so %ROM%; sudo perfnorm<\/command>/{r /home/ark/add_np2kai.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		sed -i -e '/NEC - PC98/,/pc98</s/<platform>pc<\/platform>/<platform>pc98<\/platform>/' /etc/emulationstation/es_systems.cfg
		if test ! -z "$(grep -zoP '<emulator name="standalone">\n\t\t      </emulator>\n\t\t   </emulators>\n\t\t<platform>saturn' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		then
		  sed -i -zE 's/<emulator name="standalone">([^\n]*\n[^\n]*<\/emulator>)([^\n]*\n[^\n]*<\/emulators>)/<\/emulators>/g' /etc/emulationstation/es_systems.cfg
		  sed -i 's/\s\{8,\}<\/emulators>/\t\t   <\/emulators>/g' /etc/emulationstation/es_systems.cfg
		  sed -i 's/\s\{7,\}<\/emulators>/\t\t   <\/emulators>/g' /etc/emulationstation/es_systems.cfg
		  sed -i 's/\s\{5,\}<\/emulators>/\t\t   <\/emulators>/g' /etc/emulationstation/es_systems.cfg
		  sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>saturn<\/platform>)/   <emulator name=\"\standalone-bios\">\n\t\t      <\/emulator>\n\t\t      <emulator name=\"\standalone-nobios\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		  #sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>saturn<\/platform>)/   <emulator name=\"\standalone\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		else
		  #sed -i -e '/\"retrorun\"/,/Sega Saturn/s/<\/emulators>/   <emulator name=\"\standalone\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>/' /etc/emulationstation/es_systems.cfg
		  #sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>saturn<\/platform>)/   <emulator name=\"\standalone\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		  if test -z "$(grep 'standalone-bios' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		  then
		    sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>saturn<\/platform>)/   <emulator name=\"\standalone-bios\">\n\t\t      <\/emulator>\n\t\t      <emulator name=\"\standalone-nobios\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		  else
		    printf "\nIt looks like this install already has the needed standalone entries in es_systems.cfg for Saturn.\n" | tee -a "$LOG_FILE" 
		  fi
		fi
		if test -z "$(grep 'nobios' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ $1 == \"standalone-bios\" \]\] || [[ $1 == \"standalone-nobios\" ]] || \[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/' /usr/local/bin/perfmax
		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ $1 == \"standalone-bios\" \]\] || [[ $1 == \"standalone-nobios\" ]] || \[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/' /usr/local/bin/perfmax.pic
		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ $1 == \"standalone-bios\" \]\] || [[ $1 == \"standalone-nobios\" ]] || \[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/' /usr/local/bin/perfmax.asc
		fi
		if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
		  mv -f /home/ark/hypinput.ini.351v /opt/hypseus-singe/hypinput.ini | tee -a "$LOG_FILE"
		  rm -v /home/ark/hypinput.ini.chi | tee -a "$LOG_FILE"
		elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
		  mv -f /home/ark/hypinput.ini.chi /opt/hypseus-singe/hypinput.ini | tee -a "$LOG_FILE"
		  rm -v /home/ark/hypinput.ini.351v | tee -a "$LOG_FILE"
		else
		  rm -v /home/ark/hypinput.ini.chi | tee -a "$LOG_FILE"
		  rm -v /home/ark/hypinput.ini.351v | tee -a "$LOG_FILE"
		fi
		sudo rm -rf /opt/hypseus-singe/roms | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_np2kai.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01212022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct updated ES for various devices\n" | tee -a "$LOG_FILE"	
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ]; then
      sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ $test = "3248776" ]; then
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
		  if test -z "$(grep 'ShowBatteryIndicator' .emulationstation/es_settings.cfg | tr -d '\0')"
		  then
		    echo '<bool name="ShowBatteryIndicator" value="false" />' >> .emulationstation/es_settings.cfg
		  fi
	  fi
	else
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  if test -z "$(grep 'ShowBatteryIndicator' .emulationstation/es_settings.cfg | tr -d '\0')"
	  then
	    echo '<bool name="ShowBatteryIndicator" value="false" />' >> .emulationstation/es_settings.cfg
	  fi
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	fi

	printf "\nSet correct retroarch-core repo depending on set timezone\n" | tee -a "$LOG_FILE"	
    tzone=$(readlink -f /etc/localtime | sed 's;/usr/share/zoneinfo/;;')
    if [[ $tzone  == *"Shanghai"* ]] || [[ $tzone  == *"Urumqi"* ]] || [[ $tzone  == *"Hong_Kong"* ]] || [[ $tzone  == *"Macau"* ]]; then
        sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"http:\/\/139.196.213.206\/retroarch-cores\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg
        sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"http:\/\/139.196.213.206\/retroarch-cores\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg
        sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"http:\/\/139.196.213.206\/retroarch-cores\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg.bak
        sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"http:\/\/139.196.213.206\/retroarch-cores\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg.bak
        printf "\nRetroarch core repos have been set to the China server\n" | tee -a "$LOG_FILE"
    else
        printf "\nRetroarch core repos remain set to github\n" | tee -a "$LOG_FILE"
    fi

	printf "\nAdd noatime to the ext4 fstab for slight boost to performance and reduce unnecessary writes to the flash card\n" | tee -a "$LOG_FILE"
	if test -z "$(grep 'ext4  defaults,noatime' /etc/fstab | tr -d '\0')"
	then
	  sudo sed -i 's/ext4  defaults/ext4  defaults,noatime/' /etc/fstab
	fi

	printf "\nAdd snex9x2005 as additional 64bit core for snes" | tee -a "$LOG_FILE"
	sed -i '/<core>snes9x<\/core>/c\\t\t\t  <core>snes9x<\/core>\n\t\t\t  <core>snes9x2005<\/core>' /etc/emulationstation/es_systems.cfg

	printf "\nAdd .fdi support for PC98\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '.fdi' | tr -d '\0')"
	then
	  sed -i '/<extension>.d88 .D88 .hdi .HDI .zip .ZIP/s//<extension>.d88 .D88 .fdi .FDI .hdi .HDI .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	fi

	if [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  printf "\nClean up unneeded files form the last update for the Chi specifically\n"
	  sudo rm -fv /boot/rk3326-odroidgo2-linux-v11.dtb.* | tee -a "$LOG_FILE"
	fi

    printf "\nFix options menu name in es_systems.cfg\n" | tee -a "$LOG_FILE"
    sed -i 's/<name>retropie<\/name>/<name>options<\/name>/' /etc/emulationstation/es_systems.cfg
    sed -i 's/<fullname>Retropie<\/fullname>/<fullname>Options<\/fullname>/' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01212022"
fi

if [ ! -f "/home/ark/.config/.update02242022" ]; then

	printf "\nFix Retrorun and Retrorun32 for Sega Saturn\nReplace gitcdn.link with raw.githack.com as a dynamic CDN provider\nAdd pcsx_rearmed_peops as a selectable core for psx\nUpdate ArkOS Browser by filebrowser to version 2.20.1\nFix pico-8 splore for pixel-perfect\nFix quitter\nUpdate Yabasanshiro standalone to remove about menu\nAdd gzdoom\nAdd tool to remove ._ Mac files\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02242022/arkosupdate02242022.zip -O /home/ark/arkosupdate02242022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02242022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate02242022.zip" ]; then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02242022.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate02242022.zip -d / | tee -a "$LOG_FILE"
		sudo chown -R ark:ark /opt/ | tee -a "$LOG_FILE"
		sudo chown -R ark:ark /home/ark/.config/gzdoom/ | tee -a "$LOG_FILE"
		sudo sed -i 's/.\/oga_controls/\/opt\/quitter\/oga_controls/' /usr/local/bin/saturn.sh
		rm -f -v /opt/yabasanshiro/oga_controls | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep peops |  tr -d '\0')"
		then
		  sed -i '/<core>pcsx_rearmed<\/core>/c\\t\t\t  <core>pcsx_rearmed<\/core>\n\t\t\t  <core>pcsx_rearmed_peops<\/core>' /etc/emulationstation/es_systems.cfg
		  if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
		    sed -i '/<core>pcsx_rearmed_rumble<\/core>/c\\t\t\t  <core>pcsx_rearmed_rumble<\/core>\n\t\t\t  <core>pcsx_rearmed_rumble_peops<\/core>' /etc/emulationstation/es_systems.cfg
		  fi
		fi
		if test -z "$(grep 'standalone-gzdoom' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		then
		  sed -i '/doom.sh/!{p;d;};n;a \\t\t      <emulator name=\"\standalone-gzdoom\">\n\t\t   <\/emulator>' /etc/emulationstation/es_systems.cfg
		fi
		if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
		  cp -f -v /home/ark/.config/gzdoom/gzdoom.ini.351v /home/ark/.config/gzdoom/gzdoom.ini | tee -a "$LOG_FILE"
		  cp -f -v /opt/gzdoom/gzdoom.351v /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
		  rm -f -v /home/ark/.config/gzdoom/gzdoom.ini.* | tee -a "$LOG_FILE"
		  rm -f -v /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
		elif [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
		  cp -f -v /home/ark/.config/gzdoom/gzdoom.ini.351mp /home/ark/.config/gzdoom/gzdoom.ini | tee -a "$LOG_FILE"
		  rm -f -v /home/ark/.config/gzdoom/gzdoom.ini.* | tee -a "$LOG_FILE"
		  rm -f -v /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
		elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
		  cp -f -v /home/ark/.config/gzdoom/gzdoom.ini.chi /home/ark/.config/gzdoom/gzdoom.ini | tee -a "$LOG_FILE"
		  cp -f -v /opt/gzdoom/gzdoom.chi /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
		  rm -f -v /home/ark/.config/gzdoom/gzdoom.ini.* | tee -a "$LOG_FILE"
		  rm -f -v /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
		else
		  rm -f -v /home/ark/.config/gzdoom/gzdoom.ini.* | tee -a "$LOG_FILE"
		  rm -f -v /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate02242022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nReplace exfat-fuse with exfat-linux\n" | tee -a "$LOG_FILE"
	sudo umount /opt/system/Tools
	sudo umount /roms
	sudo apt remove -y exfat-fuse | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
	  sudo install -m644 -b -D -v /home/ark/exfat.ko.351 /lib/modules/4.4.189/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo install -m644 -b -D -v /home/ark/exfat.ko.chi /lib/modules/4.4.189/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	else
	  sudo install -m644 -b -D -v /home/ark/exfat.ko.oga /lib/modules/4.4.189/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	fi
	sudo depmod 4.4.189
	sudo depmod -a
	sudo modprobe -v exfat | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/exfat.ko* | tee -a "$LOG_FILE"
	sudo mount -o defaults,auto,umask=000,noatime -t exfat /dev/mmcblk0p3 /roms
	sudo chown root:root /etc/fstab
	sudo chmod 644 /etc/fstab
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
	  sudo sed -i 's/utf8\=1/iocharset\=utf8/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  sudo sed -i 's/utf8\=1/iocharset\=utf8/' /etc/fstab
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    sudo sed -i 's/utf8\=1/iocharset\=utf8/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	  fi
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02242022"
fi

if [ ! -f "/home/ark/.config/.update04232022" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.10.3\nAdd mednafen emulator\nAdd A5200 libretro core as additional core for Atari 5200\nAdd Enable Developer Mode script\nUpdate yabasanshiro standalone\nUpdate GZDoom\nUpdate PPSSPPSDL\nUpdate File Manager\nUpdate Hypseus-Singe\nAdd Arduboy\nUpdate nes-box for arduboy\nUpdate Amiberry\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04232022/arkosupdate04232022.zip -O /home/ark/arkosupdate04232022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04232022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04232022.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1100.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1100.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate04232022.zip -d / | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/yabasanshiro | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /home/ark/.mednafen | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/retroarch | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/mednafen | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/dingux | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/hypseus-singe | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/amiberry | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04232022.bak | tee -a "$LOG_FILE"
		mkdir -v /roms/arduboy | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep arduboy)"
		then
		  sed -i -e '/<theme>wolf<\/theme>/{r /home/ark/add_arduboy.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  mkdir -v /roms2/arduboy | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'name="mednafen"')"
		then
		  sed -i '/<core>quicknes<\/core>/c\\t\t \t  <core>quicknes<\/core>\n\t\t \t<\/cores>\n\t\t      <\/emulator>\n\t\t      <emulator name\=\"mednafen\">\n\t\t \t<cores>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>record-full<\/core>' /etc/emulationstation/es_systems.cfg
		  sed -i '/<core>mednafen_pce<\/core>/c\\t\t \t  <core>mednafen_pce<\/core>\n\t\t \t<\/cores>\n\t\t      <\/emulator>\n\t\t      <emulator name\=\"mednafen\">\n\t\t \t<cores>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>record-full<\/core>' /etc/emulationstation/es_systems.cfg
		  sed -i '/<core>mednafen_lynx<\/core>/c\\t\t \t  <core>mednafen_lynx<\/core>\n\t\t \t<\/cores>\n\t\t      <\/emulator>\n\t\t      <emulator name\=\"mednafen\">\n\t\t \t<cores>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>record-full<\/core>' /etc/emulationstation/es_systems.cfg
		  tac /etc/emulationstation/es_systems.cfg > /home/ark/temp.cfg
		  sed -i -e '/gba<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>gba<\/platform>/c\\t\t<platform>gba<\/platform>\n\t\t   <\/emulators>\n\t\t \t<\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/snes<\/theme>/{n;d}' /home/ark/temp.cfg
		  sed -i -e '/snes<\/theme>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<theme>snes<\/theme>/c\\t\t<theme>snes<\/theme>\n\t\t<platform>snes<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  #sed -i -e '/snes-hacks<\/theme>/{n;d}' /home/ark/temp.cfg
		  #sed -i -e '/snes-hacks<\/theme>/{n;d}' /home/ark/temp.cfg
		  #sed -i '/<theme>snes-hacks<\/theme>/c\\t\t<theme>snes-hacks<\/theme>\n\t\t<platform>snes<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/sfc<\/theme>/{n;d}' /home/ark/temp.cfg
		  sed -i -e '/sfc<\/theme>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<theme>sfc<\/theme>/c\\t\t<theme>sfc<\/theme>\n\t\t<platform>sfc<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/<platform>gb<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>gb<\/platform>/c\\t\t<platform>gb<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/gbc<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>gbc<\/platform>/c\\t\t<platform>gbc<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/megadrive<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>megadrive<\/platform>/c\\t\t<platform>megadrive<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/genesis<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>genesis<\/platform>/c\\t\t<platform>genesis<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/mastersystem<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>mastersystem<\/platform>/c\\t\t<platform>mastersystem<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">' /home/ark/temp.cfg
		  sed -i -e '/gamegear<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>gamegear<\/platform>/c\\t\t<platform>gamegear<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>genesis_plus_gx<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"retroarch\">\n\t\t   <emulators>\n\t\t<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/%EMULATOR% -L \/home\/ark\/.config\/%EMULATOR%\/cores\/%CORE%_libretro.so %ROM%; sudo perfnorm<\/command>' /home/ark/temp.cfg
		  sed -i -e '/wonderswan<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>wonderswan<\/platform>/c\\t\t<platform>wonderswan<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>mednafen_wswan<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"retroarch\">\n\t\t   <emulators>\n\t\t<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/%EMULATOR% -L \/home\/ark\/.config\/%EMULATOR%\/cores\/%CORE%_libretro.so %ROM%; sudo perfnorm<\/command>' /home/ark/temp.cfg
		  sed -i -e '/wonderswancolor<\/platform>/{n;d}' /home/ark/temp.cfg
		  sed -i '/<platform>wonderswancolor<\/platform>/c\\t\t<platform>wonderswancolor<\/platform>\n\t\t   <\/emulators>\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>record-full<\/core>\n\t\t \t  <core>record-aspect<\/core>\n\t\t \t  <core>norecord-full<\/core>\n\t\t \t  <core>norecord-aspect<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"mednafen\">\n\t\t \t  <\/emulator>\n\t\t \t<\/cores>\n\t\t \t  <core>mednafen_wswan<\/core>\n\t\t \t<cores>\n\t\t      <emulator name\=\"retroarch\">\n\t\t   <emulators>\n\t\t<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/%EMULATOR% -L \/home\/ark\/.config\/%EMULATOR%\/cores\/%CORE%_libretro.so %ROM%; sudo perfnorm<\/command>' /home/ark/temp.cfg
		  tac /home/ark/temp.cfg > /etc/emulationstation/es_systems.cfg
		  sed -i -e '/<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/mednafen_vb_libretro.so %ROM%; sudo perfnorm<\/command>/{r /home/ark/add_vbmednafen_standalone.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/mednafen_ngp_libretro.so %ROM%; sudo perfnorm<\/command>/{r /home/ark/add_ngpmednafen_standalone.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/.md .MD<\/extension>/{n;d}' /etc/emulationstation/es_systems.cfg
		  sed -i '/.md .MD<\/extension>/c\\        <extension>.md .MD<\/extension>\n        <command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/genesis_plus_gx_libretro.so %ROM%; sudo perfnorm<\/command>' /etc/emulationstation/es_systems.cfg
		  sudo rm -v /home/ark/temp.cfg | tee -a "$LOG_FILE"
		  sudo rm -v /home/ark/add_vbmednafen_standalone.txt | tee -a "$LOG_FILE"
		  sudo rm -v /home/ark/add_ngpmednafen_standalone.txt | tee -a "$LOG_FILE"
		  sudo rm -v /home/ark/add_arduboy.txt | tee -a "$LOG_FILE"
		fi
		if test -z "$(grep 'a5200' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		then
		  sed -i -e '/<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/retroarch --config \/home\/ark\/.config\/retroarch\/config\/Atari800\/retroarch_5200.cfg -L \/home\/ark\/.config\/retroarch\/cores\/atari800_libretro.so %ROM%; sudo perfnorm<\/command>/{r /home/ark/add_a5200.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(grep 'record' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$2 == "duckstation" \]\]/s//\[\[ $2 == \"duckstation\" \]\] || [[ "$2" == *\"record\"* ]]/' /usr/local/bin/perfmax
		  sudo sed -i '/\[\[ \$2 == "duckstation" \]\]/s//\[\[ $2 == \"duckstation\" \]\] || [[ "$2" == *\"record\"* ]]/' /usr/local/bin/perfmax.pic
		  sudo sed -i '/\[\[ \$2 == "duckstation" \]\]/s//\[\[ $2 == \"duckstation\" \]\] || [[ "$2" == *\"record\"* ]]/' /usr/local/bin/perfmax.asc
		fi
		if [ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]; then
		  cp -f -v /home/ark/.mednafen/mednafen.cfg.351v /home/ark/.mednafen/mednafen.cfg | tee -a "$LOG_FILE"
		  rm -f -v /home/ark/.mednafen/mednafen.cfg.* | tee -a "$LOG_FILE"
		elif [ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]; then
		  cp -f -v /home/ark/.mednafen/mednafen.cfg.chi /home/ark/.mednafen/mednafen.cfg | tee -a "$LOG_FILE"
		  rm -f -v /home/ark/.mednafen/mednafen.cfg.* | tee -a "$LOG_FILE"
		elif [ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]; then
		  if [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
		    cp -f -v /home/ark/.mednafen/mednafen.cfg.rgb10max /home/ark/.mednafen/mednafen.cfg | tee -a "$LOG_FILE"
		    rm -f -v /home/ark/.mednafen/mednafen.cfg.* | tee -a "$LOG_FILE"
		  else
		    cp -f -v /home/ark/.mednafen/mednafen.cfg.351mp /home/ark/.mednafen/mednafen.cfg | tee -a "$LOG_FILE"
		    rm -f -v /home/ark/.mednafen/mednafen.cfg.* | tee -a "$LOG_FILE"
		  fi
		elif [ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]; then
		  if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep '190000004b4800000010000001010000')" ]; then
		    cp -f -v /home/ark/.mednafen/mednafen.cfg.rgb10 /home/ark/.mednafen/mednafen.cfg | tee -a "$LOG_FILE"
		    rm -f -v /home/ark/.mednafen/mednafen.cfg.* | tee -a "$LOG_FILE"
		  else
		    cp -f -v /home/ark/.mednafen/mednafen.cfg.rk2020 /home/ark/.mednafen/mednafen.cfg | tee -a "$LOG_FILE"
		    rm -f -v /home/ark/.mednafen/mednafen.cfg.* | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
		  cp -f -v /opt/gzdoom/gzdoom.351v /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
		  rm -f -v /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
		elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
		  cp -f -v /opt/gzdoom/gzdoom.chi /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
		  rm -f -v /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
		else
		  rm -f -v /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
		fi
		sudo apt update -y | tee -a "$LOG_FILE"
		sudo apt install -y freeglut3 fluidsynth | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_a5200.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate04232022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct yabasanshiro for device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  if [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
	    cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  else
	    cp -fv /opt/yabasanshiro/yabasanshiro.oga /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  fi
	else
	  cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	  rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	fi

	printf "\nAdd .mov extension for video player\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep '.mov')"
	then
	  sed -i '/<extension>.mp4 .avi .mpeg .mkv/s//<extension>.mp4 .MP4 .avi .AVI .mpeg .MPEG .mkv .MKV .mov .MOV/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nInstall and link new SDL 2.0.18.2 (aka SDL 2.0.20)\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.18.2 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.18.2 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.18.2 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.18.2 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.18.2 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.18.2 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.18.2.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.18.2 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.18.2.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.18.2 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.18.2 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.18.2 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	fi

	printf "\nFix loading.ascii for rgb10max only\n" | tee -a "$LOG_FILE"
	if [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
	  cp -fv /roms/launchimages/loading.ascii.rgb10max /roms/launchimages/loading.ascii | tee -a "$LOG_FILE"
	  rm -fv /roms/launchimages/loading.ascii.rgb10max | tee -a "$LOG_FILE"
	else
	  rm -fv /roms/launchimages/loading.ascii.rgb10max | tee -a "$LOG_FILE"
	fi

	printf "\nHide Enable Developer Mode script in options/Advanced\n" | tee -a "$LOG_FILE"
	#if test -z "$(cat /opt/system/gamelist.xml | grep 'Developer' | tr -d '\0')"
	#then
	  sed -i '/<\/gameList>/c\\t<game>\n\t\t<path>.\/Advanced\/Enable Developer Mode.sh<\/path>\n\t\t<name>Enable Developer Mode<\/name>\n\t\t<rating>0<\/rating>\n\t\t<releasedate>19691231T190000<\/releasedate>\n\t\t<hidden>true<\/hidden>\n\t<\/game>\n</gameList>' /opt/system/gamelist.xml
	#fi

	#printf "\nFix wrong libmali 64bit being used\n" | tee -a "$LOG_FILE"
	#sudo cp -fv /usr/local/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so /usr/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-wayland-gbm.so	| tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update04232022"
fi

if [ ! -f "/home/ark/.config/.update06242022" ]; then

	printf "\nUpdated yabasanshiro standalone\nAdjusted poll interval for timesync\nFix .ecwolf files not recognized for Wolfenstein\nFix exfat permission issue\nFix solarus launch script to properly link back to the solarus roms folder\nAdd Italian language support for Emulationstation\nAdd mame2003_plus to arcade, cps1, cps2, and cps3\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06242022/arkosupdate06242022.zip -O /home/ark/arkosupdate06242022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06242022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06242022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06242022.zip -d / | tee -a "$LOG_FILE"
		sudo sed -i 's/oga_controls yabasanshiro/oga_controls yaba/' /usr/local/bin/saturn.sh
		if test -z "$(grep "PollIntervalMinSec=60" /etc/systemd/timesyncd.conf | tr -d '\0')"
		then
		  sudo sed -i '$aPollIntervalMinSec=60' /etc/systemd/timesyncd.conf
		  sudo sed -i '$aPollIntervalMaxSec=3600' /etc/systemd/timesyncd.conf
		fi
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06242022.bak | tee -a "$LOG_FILE"
		sed -i '/<core>fbalpha2012<\/core>/c\\t\t\t  <core>fbalpha2012<\/core>\n\t\t\t  <core>mame2003_plus<\/core>' /etc/emulationstation/es_systems.cfg
		sed -i '/mame2003-plus_skip_disclaimer \=/c\mame2003-plus_skip_disclaimer \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/mame2003-plus_skip_disclaimer \=/c\mame2003-plus_skip_disclaimer \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/mame2003-plus_skip_warnings \=/c\mame2003-plus_skip_warnings \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/mame2003-plus_skip_warnings \=/c\mame2003-plus_skip_warnings \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/<extension>.wolf .WOLF/s//<extension>.wolf .WOLF .ecwolf .ECWOLF/' /etc/emulationstation/es_systems.cfg
		sudo sed -i 's/exfat defaults,auto,umask=000,noatime 0 0/exfat defaults,auto,umask=000,uid=1002,gid=1002,noatime 0 0/' /etc/fstab
		sudo sed -i 's/exfat umask=0000,iocharset=utf8,noatime 0 0/exfat umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /etc/fstab
		sudo sed -i 's/umask=0000,iocharset=utf8,noatime 0 0/umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		sudo sed -i 's/umask=0000,iocharset=utf8,noatime 0 0/umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		sudo rm -v /home/ark/arkosupdate06242022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct yabasanshiro for device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  if [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
	    cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  else
	    cp -fv /opt/yabasanshiro/yabasanshiro.oga /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  fi
	else
	  cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	  rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06242022"
fi

if [ ! -f "/home/ark/.config/.update07012022" ]; then

	printf "\nUpdated scummvm.sh script for scan of new games\nAdd missing shaders folder for some scummvm games\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07012022/arkosupdate07012022.zip -O /home/ark/arkosupdate07012022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07012022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07012022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07012022.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate07012022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07012022"
fi

if [ ! -f "/home/ark/.config/.update07302022" ]; then

	printf "\nUpdate PPSSPPSDL to 1.13.1\nUpdate OpenBOR\nUpdate Hypseus-Singe to 2.8.2c\nUpdate OpenBOR launcher script\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07302022/arkosupdate07302022.zip -O /home/ark/arkosupdate07302022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07302022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07302022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07302022.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate07302022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07302022"
fi

if [ ! -f "/home/ark/.config/.update08222022" ]; then

	printf "\nAdd gliden64 video plugin for mupen64plus standalone\nUpdate yabasanshirosa with low res patch\nAdd Duckstation Standalone\nDefault ports governor to performance\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08222022/arkosupdate08222022.zip -O /home/ark/arkosupdate08222022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08222022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08222022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate08222022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08222022.bak | tee -a "$LOG_FILE"
		sed -i '/sudo perfmax %EMULATOR% %CORE%; nice -n -19 %ROM%; sudo perfnorm/c\\t\t<command>sudo perfmax On; nice -n -19 %ROM%; sudo perfnorm<\/command>' /etc/emulationstation/es_systems.cfg
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep standalone-duckstation)"
		then
		  sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>psx<\/platform>)/   <emulator name=\"\standalone-duckstation\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		fi
		if [ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]; then
		  printf "\ncopy correct duckstation binary per device\n" | tee -a "$LOG_FILE"
		  sudo rm -fv /usr/local/bin/duckstation-nogui.chirgb10 | tee -a "$LOG_FILE"
		  sed -i '/Rotate = 1/d' /home/ark/.config/duckstation/settings.ini
		  if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		    sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /home/ark/.config/duckstation/settings.ini
		    sudo cp -fv "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		  else
		    sudo cp -fv "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		  fi
		elif [ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]; then
			sudo rm -v "/usr/local/bin/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
			sudo rm -v "/usr/local/bin/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
			if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000")" ]; then
			  printf "\ncopy correct duckstation binary per device\n" | tee -a "$LOG_FILE"
			  sudo mv -fv /usr/local/bin/duckstation-nogui.chirgb10 /usr/local/bin/duckstation-nogui | tee -a "$LOG_FILE"
			else
			  printf "\ncopy correct duckstation binary per device\n" | tee -a "$LOG_FILE"
			  sudo rm -fv /usr/local/bin/duckstation-nogui.chirgb10 | tee -a "$LOG_FILE"
			fi
		elif [ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]; then
		  printf "\ncopy correct duckstation binary per device\n" | tee -a "$LOG_FILE"
		  sudo rm -fv /usr/local/bin/duckstation-nogui.chirgb10 | tee -a "$LOG_FILE"
		  if [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
		    sed -i '/Rotate = 1/d' /home/ark/.config/duckstation/settings.ini
		    if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		      sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /home/ark/.config/duckstation/settings.ini
		      sudo cp -fv "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		    else
		      sudo cp -fv "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		    fi
		  else
			sudo rm -v "/usr/local/bin/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
			sudo rm -v "/usr/local/bin/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		  fi
		else
		  printf "\ncopy correct duckstation binary per device\n" | tee -a "$LOG_FILE"
		  sudo mv -fv /usr/local/bin/duckstation-nogui.chirgb10 /usr/local/bin/duckstation-nogui | tee -a "$LOG_FILE"
		  sed -i '/Rotate = 1/d' /home/ark/.config/duckstation/settings.ini
		  sudo rm -v "/usr/local/bin/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		  sudo rm -v "/usr/local/bin/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		fi
		if test -z "$(cat /home/ark/.config/mupen64plus/mupen64plus.cfg | grep Video-GLideN64)"
		then
		  sed -i -e '/Rotate \= 0/{r /home/ark/add_gliden64_to_mupen64plus_cfg.txt' -e 'd}' /home/ark/.config/mupen64plus/mupen64plus.cfg
		fi
		if test -z "$(grep 'GlideN64' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\]/' /usr/local/bin/perfmax
  		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\]/' /usr/local/bin/perfmax.pic
  		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\]/' /usr/local/bin/perfmax.asc
		fi
		sed -i '/<extension>.cue .CUE .ccd .CCD .lha .LHA .nrg .NRG .mds .MDS .iso .ISO .m3u .M3U/s//<extension>.chd .CHD .cue .CUE .ccd .CCD .lha .LHA .nrg .NRG .mds .MDS .iso .ISO .m3u .M3U/' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/arkosupdate08222022.zip | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_gliden64_to_mupen64plus_cfg.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct yabasanshiro for device and add n64 widescreen support where applicable\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  if [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
	    printf "\nAdd widescreen mode support for mupen64plus-glide64mk2\n" | tee -a "$LOG_FILE"
	    if test -z "$(grep '<core>Default_Aspect' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	    then
	      sed -i '/<emulator name="standalone-Glide64mk2">/c\              <emulator name="standalone-Glide64mk2">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>' /etc/emulationstation/es_systems.cfg
	    fi
	    printf "\nAdd support for 4:3 aspect ratio for mupen64plus standalone rice video plugin\n" | tee -a "$LOG_FILE"
	    if test -z "$(grep "ResolutionWidth" /home/ark/.config/mupen64plus/mupen64plus.cfg | tr -d '\0')"
	    then
	      sed -i "/\[Video-Rice\]/c\\[Video-Rice\]\n\n\# Hack to accomodate widescreen devices (Thanks to AmberElec sources for tip)\nResolutionWidth \= 848" /home/ark/.config/mupen64plus/mupen64plus.cfg
	    fi
	    if [ $(grep -c '<core>Default_Aspect' /etc/emulationstation/es_systems.cfg | tr -d '\0') -lt 2 ]; then 
	      sed -i '/<emulator name="standalone-Rice">/c\              <emulator name="standalone-Rice">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>' /etc/emulationstation/es_systems.cfg
	    fi
	    printf "\nAdd GLideN64 plugin for mupen64plus standalone to ES\n" | tee -a "$LOG_FILE"
	    if test -z "$(grep 'standalone-GlideN64' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	    then
	      sed -i '/<emulator name="standalone-Glide64mk2">/c\              <emulator name="standalone-Glide64mk2">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>\n              <\/emulator>\n              <emulator name="standalone-GlideN64">' /etc/emulationstation/es_systems.cfg
	    fi
	    cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  else
	    printf "\nAdd widescreen mode support for mupen64plus-glide64mk2\n" | tee -a "$LOG_FILE"
	    if test -z "$(grep '<core>Default_Aspect' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	    then
	      sed -i '/<emulator name="standalone-Glide64mk2">/c\              <emulator name="standalone-Glide64mk2">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>' /etc/emulationstation/es_systems.cfg
	    fi
	    printf "\nAdd support for 4:3 aspect ratio for mupen64plus standalone rice video plugin\n" | tee -a "$LOG_FILE"
	    if test -z "$(grep "ResolutionWidth" /home/ark/.config/mupen64plus/mupen64plus.cfg | tr -d '\0')"
	    then
	      sed -i "/\[Video-Rice\]/c\\[Video-Rice\]\n\n\# Hack to accomodate widescreen devices (Thanks to AmberElec sources for tip)\nResolutionWidth \= 480" /home/ark/.config/mupen64plus/mupen64plus.cfg
	    fi
		if [ $(grep -c '<core>Default_Aspect' /etc/emulationstation/es_systems.cfg | tr -d '\0') -lt 2 ]; then 
		  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07042022.bak | tee -a "$LOG_FILE"
		  sed -i '/<emulator name="standalone-Rice">/c\              <emulator name="standalone-Rice">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>' /etc/emulationstation/es_systems.cfg
		fi
	    printf "\nAdd GLideN64 plugin for mupen64plus standalone to ES\n" | tee -a "$LOG_FILE"
	    if test -z "$(grep 'standalone-GlideN64' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	    then
	      sed -i '/<emulator name="standalone-Glide64mk2">/c\              <emulator name="standalone-Glide64mk2">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>\n              <\/emulator>\n              <emulator name="standalone-GlideN64">' /etc/emulationstation/es_systems.cfg
	    fi
	    if [ $(grep -c '<core>Default_Aspect' /etc/emulationstation/es_systems.cfg | tr -d '\0') -lt 2 ]; then 
	      sed -i '/<emulator name="standalone-Rice">/c\              <emulator name="standalone-Rice">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>' /etc/emulationstation/es_systems.cfg
	    fi
	    cp -fv /opt/yabasanshiro/yabasanshiro.oga /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  fi
	else
	  printf "\nAdd GLideN64 plugin for mupen64plus standalone to ES\n" | tee -a "$LOG_FILE"
	  if test -z "$(grep 'standalone-GlideN64' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	  then
	    sed -i '/<emulator name="standalone-Glide64mk2">/c\              <emulator name="standalone-Glide64mk2">\n              <\/emulator>\n              <emulator name="standalone-GlideN64">' /etc/emulationstation/es_systems.cfg
	  fi
	  cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	  rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08222022"
fi

if [ ! -f "/home/ark/.config/.update09052022" ]; then

	printf "\nClean Up some system full names in ES\nFixed Switch to SD2 and Switch to main scripts\nUpdated Duckstation to prevent Vulkan setting\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09052022/arkosupdate09052022.zip -O /home/ark/arkosupdate09052022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09052022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate09052022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate09052022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09052022.bak | tee -a "$LOG_FILE"
		sed -i '/<fullname>Turbografx CD<\/fullname>/s//<fullname>NEC - Turbografx CD<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Turbografx 16<\/fullname>/s//<fullname>NEC - Turbografx 16<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Saturn<\/fullname>/s//<fullname>Sega - Saturn<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Naomi<\/fullname>/s//<fullname>Sega - Naomi<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Dreamcast<\/fullname>/s//<fullname>Sega - Dreamcast<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Dreamcast VMU<\/fullname>/s//<fullname>Sega - Dreamcast VMU<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Atomiswave<\/fullname>/s//<fullname>Sega - Atomiswave<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Phillips CDI<\/fullname>/s//<fullname>Phillips - CDI<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Nintendo 64DD<\/fullname>/s//<fullname>Nintendo - 64DD<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Nintendo DS<\/fullname>/s//<fullname>Nintendo - DS<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Mattel Intellivision<\/fullname>/s//<fullname>Mattel - Intellivision<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Microsoft MSX<\/fullname>/s//<fullname>Microsoft - MSX<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Microsoft MSX 2<\/fullname>/s//<fullname>Microsoft - MSX 2<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Fairchild ChannelF<\/fullname>/s//<fullname>Fairchild - ChannelF<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Atari ST<\/fullname>/s//<fullname>Atari - ST<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Atari Jaguar<\/fullname>/s//<fullname>Atari - Jaguar<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Atari 5200<\/fullname>/s//<fullname>Atari - 5200<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Amiga<\/fullname>/s//<fullname>Commodore - Amiga<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/\/3DO\//s//\/3do\//' /etc/emulationstation/es_systems.cfg
		sed -i '/<extension>.n64 .N64 .z64 .Z64<\/extension>/s//<extension>.d64 .D64 .n64dd .N64DD .ndd .NDD .n64 .N64 .z64 .Z64<\/extension>/' /etc/emulationstation/es_systems.cfg
		if test ! -z "$(cat /home/ark/.config/duckstation/settings.ini | grep Vulkan | tr -d '\0')"
		then
		  sed -i '/Vulkan/s//OpenGL/' /home/ark/.config/duckstation/settings.ini
		fi
	    if test -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		then
	      sed -i '/<path>\/roms2\//s//<path>\/roms\//g' /home/ark/.config/duckstation/settings.ini
		  sudo rm -v "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
	      sudo cp -fv "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
	    else
	      sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /home/ark/.config/duckstation/settings.ini
		  sudo rm -v "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
	      sudo cp -fv "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
	    fi
		sudo rm -v /home/ark/arkosupdate09052022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct Duckstation standalone build per device\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /usr/local/bin/standalone-duckstation | grep "/opt/duckstation/" | tr -d '\0')"
	then
	  sudo sed -i '/duckstation-nogui/s//\/opt\/duckstation\/duckstation-nogui/g' /usr/local/bin/standalone-duckstation
	fi
	if [ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]; then
	  if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000")" ]; then
		sudo rm -fv /usr/local/bin/duckstation-nogui | tee -a "$LOG_FILE"
	    sudo mv -fv /opt/duckstation/duckstation-nogui.chirgb10 /opt/duckstation/duckstation-nogui | tee -a "$LOG_FILE"
	  else
	    sudo rm -fv /usr/local/bin/duckstation-nogui* | tee -a "$LOG_FILE"
		sudo rm -fv /opt/duckstation/duckstation-nogui.chirgb10 | tee -a "$LOG_FILE"
	  fi
	elif [ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]; then
	  sudo rm -fv /usr/local/bin/duckstation-nogui* | tee -a "$LOG_FILE"
	  sudo rm -fv /opt/duckstation/duckstation-nogui.chirgb10 | tee -a "$LOG_FILE"
	elif [ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]; then
	  sudo rm -fv /usr/local/bin/duckstation-nogui* | tee -a "$LOG_FILE"
	  sudo mv -fv /opt/duckstation/duckstation-nogui.chirgb10 /opt/duckstation/duckstation-nogui | tee -a "$LOG_FILE"
	else
	  sudo rm -fv /usr/local/bin/duckstation-nogui* | tee -a "$LOG_FILE"
	  sudo rm -fv /opt/duckstation/duckstation-nogui.chirgb10 | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09052022"
fi

if [ ! -f "/home/ark/.config/.update10292022" ]; then

	printf "\nUpdate to Retroarch 1.12.0\nAdd Fake08 emulator\nUpdate Pico-8.sh script\nDisable Network Manager wait online by default\nAdd Love 11.4 engine\nUpdate Enable Developer Mode script\nUpdate timezones script\nEnable Threaded DSP for 3DO\nAdd headphone insertion detection workaround\Add missing gc folder\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10292022/arkosupdate10292022.zip -O /home/ark/arkosupdate10292022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10292022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10292022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate10292022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update10292022.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep '<emulator name="fake08">' | tr -d '\0')"
		then
		  sed -i '/<emulator name="full-screen">/c\              <emulator name="full-screen">\n              <\/emulator>\n              <emulator name="fake08">' /etc/emulationstation/es_systems.cfg
		fi
		sudo systemctl disable NetworkManager-wait-online
		sudo systemctl stop NetworkManager-wait-online
		if test -z "$(cat /opt/system/Enable\ Remote\ Services.sh | grep 'NetworkManager-wait-online' | tr -d '\0')"
		then
		  sed -i "/\#\!\/bin\/bash/c\\#\!\/bin\/bash\nsudo systemctl enable NetworkManager-wait-online\nsudo systemctl start NetworkManager-wait-online" /opt/system/Enable\ Remote\ Services.sh
		fi
		if test -z "$(cat /opt/system/Disable\ Remote\ Services.sh | grep 'NetworkManager-wait-online' | tr -d '\0')"
		then
		  sed -i "/\#\!\/bin\/bash/c\\#\!\/bin\/bash\nsudo systemctl disable NetworkManager-wait-online\nsudo systemctl stop NetworkManager-wait-online" /opt/system/Disable\ Remote\ Services.sh
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'love' | tr -d '\0')"
		then
		  sed -i -e '/<theme>n64dd<\/theme>/{r /home/ark/add_love.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if [ ! -d "/roms/love2d" ]; then
		  mkdir -v /roms/love2d | tee -a "$LOG_FILE"
		  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		  then
		    if [ ! -d "/roms2/love2d" ]; then
		      mkdir -v /roms2/love2d | tee -a "$LOG_FILE"
		      sed -i '/<path>\/roms\/love2d/s//<path>\/roms2\/love2d/g' /etc/emulationstation/es_systems.cfg
			fi
		  fi
		fi
		if [ -f "/opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep love2d | tr -d '\0')"
		  then
		    sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/love2d\/" ]\; then\n      sudo mkdir \/roms2\/love2d\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nLove2d is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep gc | tr -d '\0')"
		  then
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gc\/" ]\; then\n      sudo mkdir \/roms2\/gc\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nGC is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep love2d | tr -d '\0')"
		  then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/love2d\/" ]\; then\n      sudo mkdir \/roms2\/love2d\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nLove2d is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep gc | tr -d '\0')"
		  then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gc\/" ]\; then\n      sudo mkdir \/roms2\/gc\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nGC is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/boot/rk3566.dtb" ]; then
		  if [ ! -d "/roms/gc" ]; then
		    mkdir -v /roms/gc | tee -a "$LOG_FILE"
		    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		    then
			  if [ ! -d "/roms2/gc" ]; then
		        mkdir -v /roms2/gc | tee -a "$LOG_FILE"
		        sed -i '/<path>\/roms\/gc/s//<path>\/roms2\/gc/g' /etc/emulationstation/es_systems.cfg
			  fi
		    fi
		  fi
		fi
		cd /roms/themes/es-theme-nes-box
		git reset --hard origin/master | tee -a "$LOG_FILE"
		git pull | tee -a "$LOG_FILE"
		sudo chown ark:ark /opt/system/Advanced/Enable\ Developer\ Mode.sh
		cd /home/ark
		sudo rm -v /home/ark/add_love.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate10292022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi
	
	printf "\nCopy correct fake08 for device\n" | tee -a "$LOG_FILE"
#	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
#	    cp -fv /opt/fake08/fake08.640 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	elif [ -f "/boot/rk3566.dtb" ]; then
#	    cp -fv /opt/fake08/fake08.960 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	elif [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
#	    cp -fv /opt/fake08/fake08.848 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	else
#	    cp -fv /opt/fake08/fake08.480 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	fi
	if [ -f "/boot/rk3566.dtb" ]; then
      mv -fv /opt/fake08/fake08.rk3566 /opt/fake08/fake08 | tee -a "$LOG_FILE"
      rm -fv /opt/fake08/fake08.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/fake08/fake08.rk3326 /opt/fake08/fake08 | tee -a "$LOG_FILE"
      rm -fv /opt/fake08/fake08.rk3566 | tee -a "$LOG_FILE"
	fi

	printf "\nEnable Threaded DSP for 3DO by default\n" | tee -a "$LOG_FILE"
	if test ! -z "$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep 'opera_dsp_threaded' | tr -d '\0')"
	then
	  sed -i '/opera_dsp_threaded \= "disabled"/c\opera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  sed -i '/mgba_use_bios \= \"ON\"/c\mgba_use_bios \= \"ON\"\nopera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	else
  	  sed -i '/mgba_use_bios \= \"ON\"/c\mgba_use_bios \= \"ON\"\nopera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
  	  sed -i '/mgba_use_bios \= \"ON\"/c\mgba_use_bios \= \"ON\"\nopera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.rgb10max | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.503 | tee -a "$LOG_FILE"
	  cd /usr/lib/aarch64-linux-gnu/
	  sudo ln -sf libMali.so libGLES_CM.so
	  ldconfig
	  cd /home/ark
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ]; then
	  sudo cp -fv /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.rgb10max | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.503 | tee -a "$LOG_FILE"
	  cd /usr/lib/aarch64-linux-gnu/
	  #sudo cp /usr/local/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so /usr/lib/aarch64-linux-gnu/.
	  #sudo rm /usr/lib/aarch64-linux-gnu/libMali.so
	  #sudo ln -sf libmali-bifrost-g31-rxp0-gbm.so libMali.so
	  sudo ln -sf libMali.so libGLES_CM.so
	  ldconfig
	  cd /home/ark
	elif [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  sudo cp -fv /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.503 | tee -a "$LOG_FILE"
	  cd /usr/lib/aarch64-linux-gnu/
	  sudo cp /usr/local/lib/aarch64-linux-gnu/libmali-bifrost-g31-rxp0-gbm.so /usr/lib/aarch64-linux-gnu/.
	  sudo rm /usr/lib/aarch64-linux-gnu/libMali.so
	  sudo ln -sf libmali-bifrost-g31-rxp0-gbm.so libMali.so
	  sudo ln -sf libMali.so libGLES_CM.so
	  ldconfig
	  cd /home/ark
	elif [ -f "/boot/rk3566.dtb" ]; then
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.rgb10max | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	fi

	printf "\nMake sure retroarch core repos are still set to Github if it's been changed and make sure their set to the correct repo\n" | tee -a "$LOG_FILE"
    if [ -f "/boot/rk3566.dtb" ]; then
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg.bak
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg.bak
      echo "Retroarch core repos have been changed to github"
    else
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg.bak
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg.bak
      echo "Retroarch core repos have been changed to github"
    fi

	printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
	  if [ -f "/home/ark/.config/.DEVICE" ]; then
	    if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /boot/Image.353 /boot/Image | tee -a "$LOG_FILE"
		  sudo rm -fv /boot/Image.503 | tee -a "$LOG_FILE"
	    else
	      sudo mv -fv /boot/Image.503 /boot/Image | tee -a "$LOG_FILE"
		  sudo rm -fv /boot/Image.353 | tee -a "$LOG_FILE"
	    fi
	  else
	    sudo mv -fv /boot/Image.503 /boot/Image | tee -a "$LOG_FILE"
		sudo rm -fv /boot/Image.353 | tee -a "$LOG_FILE"
		echo "RG503" > /home/ark/.config/.DEVICE
	  fi
	else
	  sudo rm -fv /boot/Image.503 | tee -a "$LOG_FILE"
	  sudo rm -fv /boot/Image.353 | tee -a "$LOG_FILE"
	fi

	printf "\nAdd Workaround for headphone jack sense on boot\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
	  if test -z "$(sudo crontab -l | grep 'hpwatchdaemon.sh' | tr -d '\0')"
	  then
		sudo crontab -l > temp.cron
		echo "@reboot /usr/local/bin/hpwatchdaemon.sh &" >> temp.cron
		sudo crontab temp.cron
		sudo rm -v temp.cron | tee -a "$LOG_FILE"
		sudo crontab -l | grep 'hpwatchdaemon.sh' | tr -d '\0' | tee -a "$LOG_FILE"
	  else
	    printf "  No need to add this workaround as it already exists.\n" | tee -a "$LOG_FILE"
	  fi
	else
	  printf "  This is not a device that needs this workaround\n" | tee -a "$LOG_FILE"
	  sudo rm -v /usr/local/bin/hpwatchdaemon.sh  | tee -a "$LOG_FILE"
	fi

	printf "\nClean up some old unneeded files in the system\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	sudo journalctl --vacuum-time=1s

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10292022"

fi

if [ ! -f "/home/ark/.config/.update11062022" ]; then

	printf "\nFix Retroarch Ozone menu crashing when called during game session\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11062022/arkosupdate11062022.zip -O /home/ark/arkosupdate11062022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11062022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11062022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate11062022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11062022.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -A4 "fake08" | tr -d '\0' | grep "retroarch" | tr -d '\0')"
		then
		  sed -i '/%CORE%; sudo systemctl start pico8hotkey/s//%ROM%; sudo systemctl start pico8hotkey/' /etc/emulationstation/es_systems.cfg
		  sed -i '/<emulator name="fake08">/c\              <emulator name="fake08">\n              <\/emulator>\n              <emulator name="retroarch">' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(grep 'carts' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$1 == "standalone-GlideN64" \]\]/s//\[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == *"carts"* \]\]/' /usr/local/bin/perfmax
  		  sudo sed -i '/\[\[ \$1 == "standalone-GlideN64" \]\]/s//\[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == *"carts"* \]\]/' /usr/local/bin/perfmax.pic
  		  sudo sed -i '/\[\[ \$1 == "standalone-GlideN64" \]\]/s//\[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == *"carts"* \]\]/' /usr/local/bin/perfmax.asc
		fi
		sudo rm -v /home/ark/arkosupdate11062022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct libretro fake-08 core depending on device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ]; then
	  mv -fv /home/ark/.config/retroarch/cores/fake08_libretro.so.rk3326 /home/ark/.config/retroarch/cores/fake08_libretro.so | tee -a "$LOG_FILE"
	else
	  rm -fv /home/ark/.config/retroarch/cores/fake08_libretro.so.rk3326 | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11062022"

fi

if [ ! -f "/home/ark/.config/.update11182022" ]; then

	printf "\nAdd Amstrad GX4000\nUpdate retroarch-tate script\nUpdate pico8.sh script\nUpdate N64 launch script\nUpdate PS1 M3U Generator script\nDefault external controller as Player 1\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11182022/arkosupdate11182022.zip -O /home/ark/arkosupdate11182022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11182022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11182022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate11182022.zip -d / | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep GX4000)"
		then
		  sed -i -e '/<theme>amstradcpc<\/theme>/{r /home/ark/add_gx4000.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(grep 'cap32' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == "cap32" \]\]/' /usr/local/bin/perfmax
  		  sudo sed -i '/\[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == "cap32" \]\]/' /usr/local/bin/perfmax.pic
  		  sudo sed -i '/\[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == "cap32" \]\]/' /usr/local/bin/perfmax.asc
		fi
		if [ ! -d "/roms/gx4000" ]; then
		  mkdir -v /roms/gx4000 | tee -a "$LOG_FILE"
		fi
		if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		then
		  if [ ! -d "/roms2/gx4000" ]; then
		    mkdir -v /roms2/gx4000 | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/gx4000/s//<path>\/roms2\/gx4000/g' /etc/emulationstation/es_systems.cfg
		  fi
		fi
		if [ -f "/opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep gx4000 | tr -d '\0')"
		  then
		    sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gx4000\/" ]\; then\n      sudo mkdir \/roms2\/gx4000\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nAmstrad GX4000 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep gx4000 | tr -d '\0')"
		  then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gx4000\/" ]\; then\n      sudo mkdir \/roms2\/gx4000\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nAmstrad GX4000 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
		  sudo rm -fv /home/ark/.config/retroarch/retroarch.cfg.ext | tee -a "$LOG_FILE"
		  sudo rm -fv /home/ark/.config/retroarch32/retroarch.cfg.ext | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/add_gx4000.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11182022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct cap32_libretro core for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      mv -fv /home/ark/cap32_libretro.so.rk3566 /home/ark/.config/retroarch/cores/cap32_libretro.so | tee -a "$LOG_FILE"
      rm -fv /home/ark/cap32_libretro.so.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /home/ark/cap32_libretro.so.rk3326 /home/ark/.config/retroarch/cores/cap32_libretro.so | tee -a "$LOG_FILE"
      rm -fv /home/ark/cap32_libretro.so.rk3566 | tee -a "$LOG_FILE"
	fi

	printf "\nEnable N64DD by default in retroarch-core options file\n" | tee -a "$LOG_FILE"
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg.bak

	printf "\nFix mupen64plus rice standalone emulator resolution\n"
	if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sed -i '/ResolutionWidth \= /c\ResolutionWidth \= "640"' /home/ark/.config/mupen64plus/mupen64plus.cfg
	else
	  printf "  This doesn't seem to be a 640x480 resolution unit.  This change is not needed." | tee -a "$LOG_FILE"
	fi

	printf "\nAdd symlink for librga.so.2 arm32bit environment\n" | tee -a "$LOG_FILE"
	if [ ! -f "/usr/lib/arm-linux-gnueabihf/librga.so.2" ]; then
	  cd /usr/lib/arm-linux-gnueabihf/
	  sudo ln -sf librga.so librga.so.2
	  cd /home/ark
	else
	  printf "  librga.so.2 already exists in /usr/lib/arm-linux-gnueabihf/" | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11182022"

fi

if [ ! -f "/home/ark/.config/.update12012022" ]; then

	printf "\nUpdated retroarch and retroarch32 to 1.13.0\nFix controls not working in retroarches with bt audio connected\nDisable OC for 353m and 353v units\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12012022/arkosupdate12012022.zip -O /home/ark/arkosupdate12012022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12012022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12012022.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo unzip -X -o /home/ark/arkosupdate12012022.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /home/ark/arkosupdate12012022.zip -x usr/local/bin/retroarch* home/ark/rk3566* /opt/system/Wifi.sh -d / | tee -a "$LOG_FILE"
		fi
		if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
		  sudo cp -fv /home/ark/rk3566-353m-notimingchange.dtb /boot/rk3566-OC.dtb.orig | tee -a "$LOG_FILE"
		  sudo cp -fv /home/ark/rk3566-353m.dtb /boot/rk3566-OC.dtb.tony | tee -a "$LOG_FILE"
		  if [ -f "/opt/system/Advanced/Screen - Switch to Original Screen Timings.sh" ]; then
		    sudo cp -fv /boot/rk3566-OC.dtb.tony /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  else 
		    sudo cp -fv /boot/rk3566-OC.dtb.orig /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  fi
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		elif [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
		  sudo cp -fv /home/ark/rk3566-353v-notimingchange.dtb /boot/rk3566-OC.dtb.orig | tee -a "$LOG_FILE"
		  sudo cp -fv /home/ark/rk3566-353v.dtb /boot/rk3566-OC.dtb.tony | tee -a "$LOG_FILE"
		  if [ -f "/opt/system/Advanced/Screen - Switch to Original Screen Timings.sh" ]; then
		    sudo cp -fv /boot/rk3566-OC.dtb.tony /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  else 
		    sudo cp -fv /boot/rk3566-OC.dtb.orig /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  fi
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		else
		  echo "  This is not a rg353m or rg353v unit so no need to update the dtb on this unit." | tee -a "$LOG_FILE"
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate12012022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nAdjust root partition check interval and enable roms partition checking on boot\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo tune2fs -c 15 -i 1w -l /dev/mmcblk1p4 | egrep -i 'mount count|check' | tr -d '\0' | tee -a "$LOG_FILE"
	  sudo sed -i '/\/dev\/mmcblk1p5 \/roms exfat defaults,auto,umask\=000,uid\=1002,gid\=1002,noatime 0 0/s//\/dev\/mmcblk1p5 \/roms exfat defaults,auto,umask\=000,uid\=1002,gid\=1002,noatime 0 2/' /etc/fstab
	else
	  echo "  This doesn't seem to be a rk3566 device so root partition check interval will not be adjusted" | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Gliden64 and glide64mk2 plugins for the chipset\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  cp -fv /opt/mupen64plus/mupen64plus-video-GLideN64.so.rk3326 /opt/mupen64plus/mupen64plus-video-GLideN64.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-glide64mk2.so.rk3326 /opt/mupen64plus/mupen64plus-video-glide64mk2.so | tee -a "$LOG_FILE"
	  rm -fv /opt/mupen64plus/mupen64plus-video-GLideN64.so.rk3326 | tee -a "$LOG_FILE"
	  rm -fv /opt/mupen64plus/mupen64plus-video-glide64mk2.so.rk3326 | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/mupen64plus/mupen64plus-video-GLideN64.so.rk3326 | tee -a "$LOG_FILE"
	  rm -fv /opt/mupen64plus/mupen64plus-video-glide64mk2.so.rk3326 | tee -a "$LOG_FILE"
	  echo "  Correct Gliden64 and glide64mk2 plugins are already in place for this rk3566 device" | tee -a "$LOG_FILE"
	fi

	printf "\nAdjust some GlideN64 plugin settings\n" | tee -a "$LOG_FILE"
	sed -i "/EnableHWLighting \=/c\EnableHWLighting \= 0" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/UseNativeResolutionFactor \=/c\UseNativeResolutionFactor \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/ThreadedVideo \=/c\ThreadedVideo \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/bilinearMode \=/c\bilinearMode \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12012022"

fi

if [ ! -f "/home/ark/.config/.update12022022" ]; then

	printf "\nRemove easyroms partition check on tf1 with everyboot\nVerify GlideN64 plugin settings\n" | tee -a "$LOG_FILE"

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo sed -i '/\/dev\/mmcblk1p5 \/roms exfat defaults,auto,umask\=000,uid\=1002,gid\=1002,noatime 0 0/s//\/dev\/mmcblk1p5 \/roms exfat defaults,auto,umask\=000,uid\=1002,gid\=1002,noatime 0 0/' /etc/fstab
	else
	  echo "  This doesn't seem to be a rk3566 device so root partition check interval will not be adjusted" | tee -a "$LOG_FILE"
	fi

	sudo chown -Rv ark:ark /home/ark/.config/mupen64plus/ | tee -a "$LOG_FILE"
	sed -i "/EnableHWLighting \=/c\EnableHWLighting \= 0" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/UseNativeResolutionFactor \=/c\UseNativeResolutionFactor \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/ThreadedVideo \=/c\ThreadedVideo \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/bilinearMode \=/c\bilinearMode \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	if test -z "$(cat /home/ark/.config/mupen64plus/mupen64plus.cfg | grep ThreadedVideo | tr -d '\0')"
	then
	  sed -i "/\[Video-GLideN64\]/c\\[Video-GLideN64\]\nThreadedVideo \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12022022"

fi

if [ ! -f "/home/ark/.config/.update12032022" ]; then

	printf "\nFix Wifi Menu\nFix Glide64mk2 and glideN64 plugins for mupen64plus standalone\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12032022/arkosupdate12032022.zip -O /home/ark/arkosupdate12032022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12032022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12032022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12032022.zip -d / | tee -a "$LOG_FILE"
		if [ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]; then
		  cp -fv /opt/system/Wifi.sh.351v /opt/system/Wifi.sh | tee -a "$LOG_FILE"
		  rm -fv /opt/system/Wifi.sh.* | tee -a "$LOG_FILE"
		elif [ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]; then
		  cp -fv /opt/system/Wifi.sh.chi /opt/system/Wifi.sh | tee -a "$LOG_FILE"
		  rm -fv /opt/system/Wifi.sh.* | tee -a "$LOG_FILE"
		else
		  rm -fv /opt/system/Wifi.sh.* | tee -a "$LOG_FILE"
		fi
		cd /usr/lib/aarch64-linux-gnu/
		sudo ln -sfv libmali.so libmali.so.1 | tee -a "$LOG_FILE"
		cd /home/ark
		sudo rm -v /home/ark/arkosupdate12032022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nAdjust some GlideN64 plugin settings\n" | tee -a "$LOG_FILE"
	sudo chown -Rv ark:ark /home/ark/.config/mupen64plus/ | tee -a "$LOG_FILE"
	sed -i "/EnableHWLighting \=/c\EnableHWLighting \= 0" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/UseNativeResolutionFactor \=/c\UseNativeResolutionFactor \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/ThreadedVideo \=/c\ThreadedVideo \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/bilinearMode \=/c\bilinearMode \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	if test -z "$(cat /home/ark/.config/mupen64plus/mupen64plus.cfg | grep ThreadedVideo | tr -d '\0')"
	then
	  sed -i "/\[Video-GLideN64\]/c\\[Video-GLideN64\]\nThreadedVideo \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12032022"

fi

if [ ! -f "/home/ark/.config/.update12182022" ]; then

	printf "\nAdd vic20 as separate system\nAdd vic20 rom folder\nUpdate retroarch.cfg.vert\nUpdate pico8.sh script for png to p8 conversion for libretro\nUpdate ppsspp to version 1.14\nUpdate Retroarch to 1.14\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12182022/arkosupdate12182022.zip -O /home/ark/arkosupdate12182022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12182022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12182022.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo unzip -X -o /home/ark/arkosupdate12182022.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /home/ark/arkosupdate12182022.zip -x home/ark/.config/retroarch/retroarch.cfg.vert -d / | tee -a "$LOG_FILE"
		fi
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12182022.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep vic20)"
		then
		  sed -i -e '/<theme>c128<\/theme>/{r /home/ark/add_vic20.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if [ ! -d "/roms/vic20" ]; then
		  mkdir -v /roms/vic20 | tee -a "$LOG_FILE"
		  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		  then
		    if [ ! -d "/roms2/vic20" ]; then
		      mkdir -v /roms2/vic20 | tee -a "$LOG_FILE"
			fi
		    sed -i '/<path>\/roms\/vic20/s//<path>\/roms2\/vic20/g' /etc/emulationstation/es_systems.cfg
		  fi
		fi
		if [ -f "/opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep vic20 | tr -d '\0')"
		  then
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vic20\/" ]\; then\n      sudo mkdir \/roms2\/vic20\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nVic20 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep vic20 | tr -d '\0')"
		  then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vic20\/" ]\; then\n      sudo mkdir \/roms2\/vic20\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nVic20 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		sudo rm -v /home/ark/add_vic20.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12182022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nUpdate exfat kernel module\n" | tee -a "$LOG_FILE"
	  sudo install -m644 -b -D -v /home/ark/exfat.ko /lib/modules/4.19.172/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	  sudo depmod -a
	fi
	sudo rm -fv /home/ark/exfat.ko | tee -a "$LOG_FILE"

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	#printf "\nDecrease default audio latency retroarch and retroarch32 to 0ms\n" | tee -a "$LOG_FILE"
	#sed -i '/audio_latency \= \"128\"/c\audio_latency \= \"0\"' /home/ark/.config/retroarch32/retroarch.cfg
	#sed -i '/audio_latency \= \"128\"/c\audio_latency \= \"0\"' /home/ark/.config/retroarch/retroarch.cfg
	#sed -i '/audio_latency \= \"128\"/c\audio_latency \= \"0\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	#sed -i '/audio_latency \= \"128\"/c\audio_latency \= \"0\"' /home/ark/.config/retroarch/retroarch.cfg.bak

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12182022"

fi

if [ ! -f "/home/ark/.config/.update12232022" ]; then

	printf "\nAdd workaround for auto reconnecting connected bluetooth devices\nDisable Message Of The Day service for ssh logins\nFix EasyRPG scan script\nUpdate dtb for 353m and 353v for analog range fix\nUpdated PPSSPP standalone to 1.14.1\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12232022/arkosupdate12232022.zip -O /home/ark/arkosupdate12232022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12232022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12232022.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo unzip -X -o /home/ark/arkosupdate12232022.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /home/ark/arkosupdate12232022.zip -x usr/local/bin/btconnected.sh usr/lib/systemd/system-sleep/sleep -d / | tee -a "$LOG_FILE"
		fi
		sudo chmod -x /etc/update-motd.d/50-motd-news
		if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
		  sudo cp -fv /home/ark/rk3566-353m-notimingchange.dtb /boot/rk3566-OC.dtb.orig | tee -a "$LOG_FILE"
		  sudo cp -fv /home/ark/rk3566-353m.dtb /boot/rk3566-OC.dtb.tony | tee -a "$LOG_FILE"
		  if [ -f "/opt/system/Advanced/Screen - Switch to Original Screen Timings.sh" ]; then
		    sudo cp -fv /boot/rk3566-OC.dtb.tony /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  else 
		    sudo cp -fv /boot/rk3566-OC.dtb.orig /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  fi
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		elif [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
		  sudo cp -fv /home/ark/rk3566-353v-notimingchange.dtb /boot/rk3566-OC.dtb.orig | tee -a "$LOG_FILE"
		  sudo cp -fv /home/ark/rk3566-353v.dtb /boot/rk3566-OC.dtb.tony | tee -a "$LOG_FILE"
		  if [ -f "/opt/system/Advanced/Screen - Switch to Original Screen Timings.sh" ]; then
		    sudo cp -fv /boot/rk3566-OC.dtb.tony /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  else 
		    sudo cp -fv /boot/rk3566-OC.dtb.orig /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  fi
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		else
		  echo "  This is not a rg353m or rg353v unit so no need to update the dtb on this unit." | tee -a "$LOG_FILE"
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate12232022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12232022"

fi

if [ ! -f "/home/ark/.config/.update12272022" ]; then

	printf "\nUpdate ScummVM to 2.7.0 pre-release\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12272022/arkosupdate12272022.zip -O /dev/shm/arkosupdate12272022.zip -a "$LOG_FILE" || rm -f /dev/shm/arkosupdate12272022.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate12272022.zip" ]; then
		sudo unzip -X -o /dev/shm/arkosupdate12272022.zip -d / | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate12272022.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate12272022.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12272022"

fi

if [ ! -f "/home/ark/.config/.update01032023" ]; then

	printf "\nUpdate estuary Kodi skin UI element size for 640x480 devices\nIncrease font size for estuary Kodi skin\nFix no controls for Atari 800 and Atari XEGS\nAdd snd_aloop kernel module\nUpdate watchforbtaudio script\nUpdate PPSSPP to 1.14.3\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01032023/arkosupdate01032023.zip -O /dev/shm/arkosupdate01032023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01032023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate01032023.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  cp -v /opt/kodi/share/kodi/addons/skin.estuary/xml/Font.xml cp /opt/kodi/share/kodi/addons/skin.estuary/xml/Font.xml.update01032023.bak | tee -a "$LOG_FILE"
		  sudo unzip -X -o /dev/shm/arkosupdate01032023.zip -d / | tee -a "$LOG_FILE"
		  sudo depmod -a
		else
		  sudo unzip -X -o /dev/shm/arkosupdate01032023.zip -x opt/kodi/share/kodi/addons/skin.estuary/xml/Font.xml home/ark/.config/retroarch/config/Atari800/retroarch_* usr/local/bin/watchforbtaudio.sh home/ark/.asoundrcbt lib/modules/4.19.172/kernel/sound/drivers/snd-aloop.ko -d / | tee -a "$LOG_FILE"
		fi
		if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
		  sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' /opt/kodi/share/kodi/addons/skin.estuary/addon.xml
		else
		  echo "  This is not a RG353M or RG353V/VS unit so no modification to the esturary skin ui element size will be done here." | tee -a "$LOG_FILE"
		fi
		sudo rm -fv /dev/shm/arkosupdate01032023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate01032023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nChange default nekop2 and nekop2kai retroarch core joypad mappings\n" | tee -a "$LOG_FILE"
	if test -z "$(grep 'np2kai_joymode' /home/ark/.config/retroarch/retroarch-core-options.cfg | tr -d '\0')"
	then
	  sed -i -e '$anp2kai_joymode = "Keypad"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  sed -i -e '$anp2kai_joymode = "Keypad"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	else
	  sed -i '/np2kai_joymode \= "OFF"/c\np2kai_joymode = "Keypad"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  sed -i -e '$anp2kai_joymode = "Keypad"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	fi
	if test -z "$(grep 'np2_GUI_controller' /home/ark/.config/retroarch/retroarch-core-options.cfg | tr -d '\0')"
	then
	  sed -i -e '$anp2_GUI_controller = "JOY0"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  sed -i -e '$anp2_GUI_controller = "JOY0"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	else
	  sed -i '/np2_GUI_controller = "MOUSE"/c\np2_GUI_controller = "JOY0"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  sed -i -e '$anp2_GUI_controller = "JOY0"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	fi
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01032023"

fi

if [ ! -f "/home/ark/.config/.update01142023" ]; then

	printf "\nDefault pico-8 to look for 64 bit executable first\nUpdate PPSSPP to 1.14.4\nUpdate Hypseus-Singe to 2.10.1\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01142023/arkosupdate01142023.zip -O /dev/shm/arkosupdate01142023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01142023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate01142023.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate01142023.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /dev/shm/arkosupdate01142023.zip -x boot/uInitrd -d / | tee -a "$LOG_FILE"
		fi
		sudo rm -fv /dev/shm/arkosupdate01142023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate01142023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Hypseus-Singe for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01142023"

fi

if [ ! -f "/home/ark/.config/.update01152023" ]; then

	printf "\nFix scraping for SFC\nAdd coolCV retroarch core\nUpdate OpenMSC Standalone emulator to 18.0\nBluetooth audio delay improvement\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01152023/arkosupdate01152023.zip -O /dev/shm/arkosupdate01152023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01152023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate01152023.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate01152023.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /dev/shm/arkosupdate01152023.zip -x home/ark/.asoundrcbt -d / | tee -a "$LOG_FILE"
		fi
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01152023.bak | tee -a "$LOG_FILE"
		sed -i 's/<platform>sfc<\/platform>/<platform>snes<\/platform>/' /etc/emulationstation/es_systems.cfg
		sed -i -e '/bluemsx_libretro.so/{r /home/ark/add_coolcv.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		if [ -d "/roms/bios/openmsx" ]; then
		  cp -R -f -v /opt/openmsx/backupconfig/openmsx/share/ /roms/bios/openmsx/ | tee -a "$LOG_FILE"
		else
		  printf "No need to copy openmsx bios files as they don't exist in roms/bios for this unit yet.  Will be copied on initial load of openmsx standalone."  | tee -a "$LOG_FILE"
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  if [ -d "/roms2/bios/openmsx" ]; then
		    cp -R -f -v /opt/openmsx/backupconfig/openmsx/share/ /roms2/bios/openmsx/ | tee -a "$LOG_FILE"
		  else
		    printf "No need to copy openmsx bios files as they don't exist in roms2/bios on this unit yet.  Will be copied on initial load of openmsx standalone."  | tee -a "$LOG_FILE"
		  fi
		fi
		sudo rm -fv /home/ark/add_coolcv.txt | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate01152023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate01152023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix default screenshots to content directory setting for retroarch and retroarch32\n" | tee -a "$LOG_FILE"
	sed -i '/screenshots_in_content_dir \= "false"/c\screenshots_in_content_dir \= "true"' /home/ark/.config/retroarch32/retroarch.cfg
	sed -i '/screenshots_in_content_dir \= "false"/c\screenshots_in_content_dir \= "true"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	sed -i '/screenshots_in_content_dir \= "false"/c\screenshots_in_content_dir \= "true"' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/screenshots_in_content_dir \= "false"/c\screenshots_in_content_dir \= "true"' /home/ark/.config/retroarch/retroarch.cfg.bak
	
	printf "\nCopy correct OPENMSX for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/openmsx/openmsx.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/openmsx/openmsx.rk3326 /opt/openmsx/openmsx | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct latest PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01152023"

fi

if [ ! -f "/home/ark/.config/.update01152023-1" ]; then

	printf "\nRevert openMSX back to 17.0\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01152023-1/arkosupdate01152023-1.zip -O /dev/shm/arkosupdate01152023-1.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01152023-1.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate01152023-1.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate01152023-1.zip -d / | tee -a "$LOG_FILE"
	  if [ -d "/roms/bios/openmsx" ]; then
		cp -R -f -v /opt/openmsx/backupconfig/openmsx/share/ /roms/bios/openmsx/ | tee -a "$LOG_FILE"
	  else
		printf "No need to copy openmsx bios files as they don't exist in roms/bios for this unit yet.  Will be copied on initial load of openmsx standalone."  | tee -a "$LOG_FILE"
	  fi
	  if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		if [ -d "/roms2/bios/openmsx" ]; then
		  cp -R -f -v /opt/openmsx/backupconfig/openmsx/share/ /roms2/bios/openmsx/ | tee -a "$LOG_FILE"
		else
		  printf "No need to copy openmsx bios files as they don't exist in roms2/bios on this unit yet.  Will be copied on initial load of openmsx standalone."  | tee -a "$LOG_FILE"
		fi
	  fi
	  sudo rm -fv /dev/shm/arkosupdate01152023-1.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate01152023-1.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01152023-1"

fi

if [ ! -f "/home/ark/.config/.update01242023" ]; then

	printf "\nUpdate kernel to remove battery info log spamming\nUpdate controller_setup.sh for ps4 controller support\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01242023/arkosupdate01242023.zip -O /dev/shm/arkosupdate01242023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01242023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate01242023.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate01242023.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /dev/shm/arkosupdate01242023.zip -x home/ark/Image.353 usr/local/bin/controller_setup.sh usr/lib/systemd/system-sleep/sleep -d / | tee -a "$LOG_FILE"
		fi
		sudo rm -fv /dev/shm/arkosupdate01242023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate01242023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  if [ -f "/home/ark/.config/.DEVICE" ]; then
	    if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/Image.353 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')"
		then
	      sudo mv -fv /home/ark/Image.353 /boot/Image | tee -a "$LOG_FILE"
		else 
		  sudo rm -fv /home/ark/Image.353 | tee -a "$LOG_FILE"
		fi
	  else
		sudo rm -fv /home/ark/Image.353 | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nUpdate sleep.conf to allow only freeze sleep for rk3566 devices\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo sed -i "/#SuspendState\=/c\SuspendState\=freeze" /etc/systemd/sleep.conf
	else
	  echo " This is not a supported rk3566 device so sleep.conf will not be edited" | tee -a "$LOG_FILE"
	fi

	printf "\nDisable True drive emulation for C64 by default\n" | tee -a "$LOG_FILE"
	if test ! -z "$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep 'vice_drive_true_emulation' | tr -d '\0')"
	then
	  sed -i '/vice_drive_true_emulation \= "enabled"/c\vice_drive_true_emulation \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'vice_drive_true_emulation = "disabled"' >> /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	else
  	  echo 'vice_drive_true_emulation = "disabled"' >> /home/ark/.config/retroarch/retroarch-core-options.cfg
  	  echo 'vice_drive_true_emulation = "disabled"' >> /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01242023"

fi

if [ ! -f "/home/ark/.config/.update02092023" ]; then

	printf "\nAdd wifi importer tool\nUpdate filebrowser to version 2.23.0\nUpdate dtbs to support led on during sleep\nUpdate Hypseus-Singe to 2.10.2\nFix drastic, ppsspp, hypseus-singe, ecwolf and 351Files hdmi output\nUpdate retroarch with drm connection patch\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02092023/arkosupdate02092023.zip -O /dev/shm/arkosupdate02092023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02092023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate02092023.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	      sudo unzip -X -o /dev/shm/arkosupdate02092023.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /dev/shm/arkosupdate02092023.zip -x usr/local/bin/hdmi-test.sh opt/retroarch/bin/retroarch opt/retroarch/bin/retroarch32 -d / | tee -a "$LOG_FILE"
		fi
	  sudo sed -i '/filebrowser.db \&/s//filebrowser.db -r \/ \&/' /opt/system/Enable\ Remote\ Services.sh
	  sudo chown ark:ark /opt/system/Enable\ Remote\ Services.sh
	  sudo systemctl daemon-reload
	  sudo systemctl enable wifi_importer.service
	  sudo rm -fv /dev/shm/arkosupdate02092023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate02092023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nAdd check on boot for connected hdmi resolution and set drmMode\n" | tee -a "$LOG_FILE"
	  if test -z "$(sudo cat /var/spool/cron/crontabs/root | grep 'hdmi-test' | tr -d '\0')"
	  then
	    echo "@reboot /usr/local/bin/hdmi-test.sh" | sudo tee -a /var/spool/cron/crontabs/root | tee -a "$LOG_FILE"
	  else
	    printf " Check has already been added to crontab.  No need to do it again." | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nAdd support for .7z to Pokemon Mini\n" | tee -a "$LOG_FILE"
	cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02092023.bak | tee -a "$LOG_FILE"
	sed -i '/<extension>.min .MIN .zip .ZIP/s//<extension>.7z .7Z .min .MIN .zip .ZIP/' /etc/emulationstation/es_systems.cfg

	printf "\nSet performance mode for drastic\n" | tee -a "$LOG_FILE"
	sed -i '/sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/drastic.sh %ROM%; sudo perfnorm/c\\t\t<command>sudo perfmax On; nice -n -19 \/usr\/local\/bin\/drastic.sh %ROM%; sudo perfnorm<\/command>' /etc/emulationstation/es_systems.cfg

	printf "\nCopy updated dtb based on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  if [ -f "/home/ark/.config/.DEVICE" ]; then
	    if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
		  sudo apt -y update | tee -a "$LOG_FILE"
		  sudo apt -y install libarchive-zip-perl | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-353v* /boot/ | tee -a "$LOG_FILE"
		  if [ $(crc32 /boot/rk3566-OC.dtb) = "4bde4e4c" ]; then
		    sudo cp -fv /boot/rk3566-353v.dtb.v2 /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  else
		    sudo cp -fv /boot/rk3566-353v.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  fi
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')"
		then
	      sudo mv -fv /home/ark/rk3566-353m* /boot/ | tee -a "$LOG_FILE"
		  sudo cp -fv /boot/rk3566-353m.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		else 
		  sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
		fi
	  else
		sudo rm -fv /home/ark/rk3566-* | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nCopy correct Hypseus-Singe for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate perfmax and perfnorm scripts to replace image-viewer with ffplay\n" | tee -a "$LOG_FILE"
	sudo sed -i '/image-viewer/s//ffplay -x 1280 -y 720/' /usr/local/bin/perfmax
	sudo sed -i '/image-viewer/s//ffplay -x 1280 -y 720/' /usr/local/bin/perfmax.pic
	sudo sed -i '/image-viewer/s//ffplay -x 1280 -y 720/' /usr/local/bin/perfnorm.pic
	sudo sed -i '/image-viewer/s//ffplay -x 1280 -y 720/' /usr/local/bin/perfnorm
	sudo sed -i '/1.5s/s//2s/' /usr/local/bin/perfmax
	sudo sed -i '/1.5s/s//2s/' /usr/local/bin/perfmax.pic
	sudo sed -i '/1.5s/s//2s/' /usr/local/bin/perfnorm.pic
	sudo sed -i '/1.5s/s//2s/' /usr/local/bin/perfnorm

	printf "\nInstall and link new SDL 2.0.2600.2 (aka SDL 2.0.26.2)\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.2600.2.rk3566 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2600.2 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.2600.2.rk3566 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2600.2 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2600.2 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2600.2 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.2600.2.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2600.2 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.2600.2.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2600.2 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2600.2 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2600.2 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.2600.2.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2600.2 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.2600.2.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2600.2 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2600.2 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2600.2 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02092023"

fi

if [ ! -f "/home/ark/.config/.update02172023" ]; then

	printf "\nAdd IPTV Simple PVR plugin for Kodi for rk3566 devices\nFix connection and disconnection of joysticks issue for rk3566 devices\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02172023/arkosupdate02172023.zip -O /dev/shm/arkosupdate02172023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02172023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate02172023.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	      sudo unzip -X -o /dev/shm/arkosupdate02172023.zip -x "usr/bin/*" -d / | tee -a "$LOG_FILE"
		elif [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate02172023.zip -x "opt/kodi/*" "usr/bin/*" -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /dev/shm/arkosupdate02172023.zip -x "opt/kodi/*" -d / | tee -a "$LOG_FILE"
		fi
	    sudo rm -fv /dev/shm/arkosupdate02172023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate02172023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix emulationstation restarting on wake from sleep on 351v and when connecting joysticks for rk3566 devices\n" | tee -a "$LOG_FILE"
	if test -z "$(sudo cat /usr/bin/emulationstation/emulationstation.sh.es | grep 'SDL_ASSERT' | tr -d '\0')"
	then
	  sudo sed -i '/#!\/bin\/bash/c\#!\/bin\/bash\n\nexport SDL_ASSERT\=\"always_ignore\"' /usr/bin/emulationstation/emulationstation.sh
	  sudo sed -i '/#!\/bin\/bash/c\#!\/bin\/bash\n\nexport SDL_ASSERT\=\"always_ignore\"' /usr/bin/emulationstation/emulationstation.sh.es
	  sudo sed -i '/#!\/bin\/bash/c\#!\/bin\/bash\n\nexport SDL_ASSERT\=\"always_ignore\"' /usr/bin/emulationstation/emulationstation.sh.ra
	else
	  printf " Fix has already been applied.  No need to do it again." | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate Retroarches for 351v, 351mp and chi devices Only\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo chmod -v 777 /opt/retroarch/bin/* | tee -a "$LOG_FILE"
	  sudo chown -v ark:ark /opt/retroarch/bin/* | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  printf " This is not a 351mp, 351v or chi device.  No need to update retroarch again at this time." | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02172023"

fi

if [ ! -f "/home/ark/.config/.update02252023" ]; then

	printf "\nUpdate emulationstation to add Ignore Leading Articles when sorting feature\nAdd display panel adjustment features for 353 devices\nFix shoulder buttons paging after reconfiguration in ES\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02252023/arkosupdate02252023.zip -O /dev/shm/arkosupdate02252023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02252023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate02252023.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  #if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
	        sudo unzip -X -o /dev/shm/arkosupdate02252023.zip -d / | tee -a "$LOG_FILE"
		    sudo systemctl daemon-reload
			sudo systemctl enable shutdowntasks
		  #else
		  #  sudo unzip -X -o /dev/shm/arkosupdate02252023.zip -x usr/local/bin/panel_drm_tool usr/local/bin/panel_set.sh etc/systemd/system/shutdowntasks.service -d / | tee -a "$LOG_FILE"
		  #fi
		else
		  sudo unzip -X -o /dev/shm/arkosupdate02252023.zip -x usr/local/bin/panel_drm_tool usr/local/bin/panel_set.sh etc/systemd/system/shutdowntasks.service -d / | tee -a "$LOG_FILE"
		fi
	    sudo rm -fv /dev/shm/arkosupdate02252023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate02252023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3191376" ]; then
	    sudo cp -fv /home/ark/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
	    sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  fi
	  sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo mv -fv /home/ark/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3566.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi


	if test ! -z "$(cat /etc/emulationstation/es_input.cfg | grep 190000004b4800000010000000010000 | tr -d '\0')"
	then
	  printf "\nFix Pico-8 controls for RK2020\nFix PSP controls for RK2020\nFix openmsx standalone controls for RK2020\n" | tee -a "$LOG_FILE"
	  sed -i "/odroidgo2 joypad v11/d" /opt/fake08/gamecontrollerdb.txt
	  sudo sed -i "/190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1)/d" /usr/local/bin/pico8.sh
	  sed -i "/190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1)/d" /opt/ppsspp/assets/gamecontrollerdb.txt
	  sed -i "/190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1)/d" /opt/ppssppgo/assets/gamecontrollerdb.txt
	  sed -i "/190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1)/d" /opt/openmsx/gamecontrollerdb.txt
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nAdd restore panel display settings on boot for rk3566 devices\n" | tee -a "$LOG_FILE"
	    if test -z "$(sudo cat /var/spool/cron/crontabs/root | grep 'panel_set.sh' | tr -d '\0')"
	    then
	      echo "@reboot /usr/local/bin/panel_set.sh RestoreSettings &" | sudo tee -a /var/spool/cron/crontabs/root | tee -a "$LOG_FILE"
	    else
	      printf " Panel settings restore has already been added to crontab.  No need to do it again.\n" | tee -a "$LOG_FILE"
	    fi
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02252023"

fi

if [ ! -f "/home/ark/.config/.update02282023" ]; then

	printf "\nUpdate ES for rk3566 devices to disable display settings via hdmi\nUpdate ScummVM\nUpdate color profile restore settings failsafe for rk3566 devices\nAdded Greek translation for es\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02282023/arkosupdate02282023.zip -O /dev/shm/arkosupdate02282023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02282023.zip | tee -a "$LOG_FILE"
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02282023/arkosupdate02282023.z01 -O /dev/shm/arkosupdate02282023.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02282023.z01 | tee -a "$LOG_FILE"
	else
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02282023/rk3326/arkosupdate02282023.zip -O /dev/shm/arkosupdate02282023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02282023.zip | tee -a "$LOG_FILE"
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02282023/rk3326/arkosupdate02282023.z01 -O /dev/shm/arkosupdate02282023.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02282023.z01 | tee -a "$LOG_FILE"
	fi
	if [ -f "/dev/shm/arkosupdate02282023.zip" ] && [ -f "/dev/shm/arkosupdate02282023.z01" ]; then
	  zip -FF /dev/shm/arkosupdate02282023.zip --out /dev/shm/arkosupdate.zip -fz | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate02282023.z* | tee -a "$LOG_FILE"
      sudo unzip -X -o /dev/shm/arkosupdate.zip -x opt/scummvm/extra/gamecontrollerdb.txt -d / | tee -a "$LOG_FILE"
      sudo rm -fv /dev/shm/arkosupdate02282023.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate02282023.z* | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02282023"

fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate Retroarch to 1.15.0\nAdd force kill capability for drastic and scummvm\nAdd Sega Pico platform\nUpdate emulationstation for scraping sega pico\nUpdate nes-box theme\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/03112023/arkosupdate03112023.zip -O /dev/shm/arkosupdate03112023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate03112023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate03112023.zip" ]; then
        sudo unzip -X -o /dev/shm/arkosupdate03112023.zip -d / | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep '<name>pico</name>')"
		then
		  sed -i -e '/<theme>gamegear<\/theme>/{r /home/ark/add_pico.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		mkdir -v /roms/pico | tee -a "$LOG_FILE"
		if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		then
		  mkdir -v /roms2/pico | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\/pico/s//<path>\/roms2\/pico/g' /etc/emulationstation/es_systems.cfg
		fi
	    sudo rm -fv /dev/shm/arkosupdate03112023.zip | tee -a "$LOG_FILE"
	    sudo rm -fv /home/ark/add_pico.txt | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate03112023.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3203664" ]; then
	    sudo cp -fv /home/ark/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
	    sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  fi
	  sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo mv -fv /home/ark/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3566.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nMake sure permissions for the ark home directory are set to 755\n" | tee -a "$LOG_FILE"
	sudo chmod -R 755 /home/ark
	
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