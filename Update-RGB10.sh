#!/bin/bash
clear

UPDATE_DATE="02132021"
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

c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/devices/platform/backlight/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update12262020" ]; then

	printf "\nAdd File Manger to Options section\nAdd updated dtb to address possible occassional freezes for RG351P\nAdd updated blacklist to stabilize rtl8xxx wifi chipsets" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12262020/arkosupdate12262020.zip -O /home/ark/arkosupdate12262020.zip -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12262020-1/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb -O /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb -a "$LOG_FILE"
	sudo dpkg -i /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb
	sudo rm -v /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb | tee -a "$LOG_FILE"

	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update12262020-1"
fi

if [ ! -f "/home/ark/.config/.update12272020" ]; then

	printf "\nUpdated es_systems.cfg to support .m3u for cd systems and .sh for doom mods\nAdd updated blacklist for realtek chipset fixes.\nFix sleep for OGA 1.1 due to internal wifi\n"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12272020/rgb10-rk2020/arkosupdate12272020.zip -O /home/ark/arkosupdate12272020.zip -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12272020-1/arkosupdate12272020-1.zip -O /home/ark/arkosupdate12272020-1.zip -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01022021/rgb10/arkosupdate01022021.zip -O /home/ark/arkosupdate01022021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01022021.zip | tee -a "$LOG_FILE"
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
		sudo wget https://github.com/christianhaitian/arkos/raw/main/01052021/rgb10rk2020/arkosupdate01052021.zip -O /home/ark/arkosupdate01052021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01052021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01092021/arkosupdate01092021.zip -O /home/ark/arkosupdate01092021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01092021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01102021/rgb10/arkosupdate01102021.zip -O /home/ark/arkosupdate01102021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01102021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01112021/rgb10rk2020/arkosupdate01112021.zip -O /home/ark/arkosupdate01112021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01112021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01162021/arkosupdate01162021.zip -O /home/ark/arkosupdate01162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01162021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01172021/arkosupdate01172021.zip -O /home/ark/arkosupdate01172021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01172021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01182021/arkosupdate01182021.zip -O /home/ark/arkosupdate01182021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01182021.zip | tee -a "$LOG_FILE"
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

	printf "\nAdjust sound settings in ArkOS so future updates should not impact emulators and ports needing direct access to set sound\nUpdate kyra.dat for standalone scummvm\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01212021/arkosupdate01212021.zip -O /home/ark/arkosupdate01212021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01212021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01242021/arkosupdate01242021.zip -O /home/ark/arkosupdate01242021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01242021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01282021/rgb10/arkosupdate01282021.zip -O /home/ark/arkosupdate01282021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01282021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/01292021/rgb10rk2020/arkosupdate01292021.zip -O /home/ark/arkosupdate01292021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01292021.zip | tee -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/02032021/rgb10/arkosupdate02032021.zip -O /home/ark/arkosupdate02032021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02032021.zip | tee -a "$LOG_FILE"
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

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nAdd flycast32 rumble enabled core as selectable core\nRecompiled scummvm standalone to allow the use of virtual keyboards\nFix ability to load .adf for Amiberry (Amiga)\nUpdate 32bit and 64bit libgo2 libraries\nAdd tools folder into roms partition\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/02132021/arkosupdate02132021.zip -O /home/ark/arkosupdate02132021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02132021.zip | tee -a "$LOG_FILE"
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

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187	
fi