#!/bin/bash
clear

UPDATE_DATE="05012021-1"
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

if [ ! -f "/home/ark/.config/.update11132020" ]; then
	printf "\nCorrect FAVORIS to FAVORITE at the bottom of the screen when inside a system menu...\n" | tee -a "$LOG_FILE"
	sudo mv -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11132020/emulationstation -O /usr/bin/emulationstation/emulationstation -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	
	printf "\nAdd missing genesis folder to EASYROMS directory if it doesn't already exist...\n" | tee -a "$LOG_FILE"
	if [ ! -d "/roms/genesis/" ]; then
		sudo mkdir -v /roms/genesis
	fi

	printf "\nFix input not shown when inserting username/password in scraper menu...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11132020/theme.xml -O /etc/emulationstation/themes/es-theme-nes-box/theme.xml -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/themes/es-theme-nes-box/theme.xml | tee -a "$LOG_FILE"
	sudo chmod -v 664 /etc/emulationstation/themes/es-theme-nes-box/theme.xml | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update11132020"
fi

if [ ! -f "/home/ark/.config/.update11142020" ]; then
	printf "\nFix the power led status...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11142020/boot.ini -O /boot/boot.ini -a "$LOG_FILE"
	
	printf "\nAdd support for Rumble...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11142020/addrumblesupport-crontab -O /home/ark/addrumblesupport-crontab -a "$LOG_FILE"	
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11142020/enable_rumble -O /usr/local/bin/enable_rumble -a "$LOG_FILE"	
	sudo chmod -v 777 /usr/local/bin/enable_rumble | tee -a "$LOG_FILE"
	sudo crontab /home/ark/addrumblesupport-crontab
	printf "\nsudo crontab -e has been updated to:\n" | tee -a "$LOG_FILE" && sudo crontab -l | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/addrumblesupport-crontab | tee -a "$LOG_FILE"
	
	printf "\nInstall lr-pcsx_rearmed core with rumble support...\n"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11142020/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"	
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11142020/pcsx_rearmed_libretro.so.lck -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck -a "$LOG_FILE"	
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 644 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update11142020"
fi

if [ ! -f "/home/ark/.config/.update11152020" ]; then
	printf "\nInstall lr-flycast_rumble core with rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11152020/flycast_rumble_libretro.so -O /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	
	printf "\nInstall Amstrad CPC and Game and Watch retroarch cores...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11152020/cap32_libretro.so -O /home/ark/.config/retroarch/cores/cap32_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11152020/gw_libretro.so -O /home/ark/.config/retroarch/cores/gw_libretro.so -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11152020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11152020/es_systems.cfg -O /etc/emulationstation/es_systems.cfg -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/cap32_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/gw_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	if [ ! -d "/roms/gameandwatch/" ]; then
		sudo mkdir -v /roms/gameandwatch | tee -a "$LOG_FILE"
	fi
	if [ ! -d "/roms/amstradcpc/" ]; then
		sudo mkdir -v /roms/amstradcpc | tee -a "$LOG_FILE"
	fi	

	printf "\nInstall updated themes from Tiduscrying(gbz35 and gz35 dark mod) and Jetup(nes-box)..." | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11152020/es-theme-nes-box.zip -O /home/ark/es-theme-nes-box.zip -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-nes-box.zip -d /etc/emulationstation/themes/es-theme-nes-box/' | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-nes-box.zip | tee -a "$LOG_FILE"
	sudo runuser -l ark -c "git clone https://github.com/tiduscrying/es-theme-gbz35_mod /etc/emulationstation/themes/es-theme-gbz35-mod/ 2> /dev/tty1"
	sudo runuser -l ark -c "git clone https://github.com/tiduscrying/es-theme-gbz35-dark_mod /etc/emulationstation/themes/es-theme-gbz35-dark-mod/ 2> /dev/tty1"

	touch "/home/ark/.config/.update11152020"
fi

if [ ! -f "/home/ark/.config/.update11162020" ]; then
	printf "\nInstall updated lr-mgba core with rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11162020/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11162020/mgba_libretro.so.lck -O /home/ark/.config/retroarch/cores/mgba_libretro.so.lck -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so.lck | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so.lck | tee -a "$LOG_FILE"	

	printf "\nInstall updated options scripts to remove unnecessary screen outputs during loading...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11162020/Change%20Password.sh -O /opt/system/"Change Password.sh" -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11162020/Network%20Info.sh -O /opt/system/"Network Info.sh" -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11162020/Update.sh -O /opt/system/Update.sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11162020/Wifi.sh -O /opt/system/Wifi.sh -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/* | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/* | tee -a "$LOG_FILE"
	
	printf "\nFix analog to digital setting for flycast..." | tee -a "$LOG_FILE"
	sudo sed -i '/input_player1_analog_dpad/c\input_player1_analog_dpad_mode \= \"0\"' /home/ark/.config/retroarch/config/remaps/Flycast/Flycast.rmp
	sudo chown -v ark:ark /home/ark/.config/retroarch/config/remaps/Flycast/Flycast.rmp

	printf "\nSet analog sensitivity to 1.5..." | tee -a "$LOG_FILE"
	sudo sed -i '/input_analog_sensitivity/c\input_analog_sensitivity \= \"1.500000\"' /home/ark/.config/retroarch/retroarch.cfg
	sudo sed -i '/input_analog_sensitivity/c\input_analog_sensitivity \= \"1.500000\"' /home/ark/.config/retroarch32/retroarch.cfg
	sudo chown -v ark:ark /home/ark/.config/retroarch/retroarch.cfg
	sudo chown -v ark:ark /home/ark/.config/retroarch32/retroarch.cfg
	
	touch "/home/ark/.config/.update11162020"
fi	

if [ ! -f "/home/ark/.config/.update11182020-1" ]; then
	printf "\nApply alternative power led fix to improve system booting stability...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11182020/boot.ini -O /boot/boot.ini -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11182020/addledfix-crontab -O /home/ark/addledfix-crontab -a "$LOG_FILE"	
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11182020/fix_power_led -O /usr/local/bin/fix_power_led -a "$LOG_FILE"	
	sudo chmod -v 777 /usr/local/bin/fix_power_led | tee -a "$LOG_FILE"
	sudo crontab /home/ark/addledfix-crontab
	sudo rm -v /home/ark/addledfix-crontab | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update11182020-1"
fi

if [ ! -f "/home/ark/.config/.update1120020" ]; then

	printf "\nUpdate mednafen_pce_fast libretro core to fix turbo button issue..." | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11202020/mednafen_pce_fast_libretro.so -O /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so -a "$LOG_FILE"
	sudo touch /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so.lck
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so.lck | tee -a "$LOG_FILE"

	printf "\nUpdate Emulationstation to fix shift key for builtin keyboard...\n" | tee -a "$LOG_FILE"
	sudo mv -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11202020/emulationstation -O /usr/bin/emulationstation/emulationstation -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"

	printf "\nUpdate boot colors\n" | tee -a "$LOG_FILE"
	sudo sed -i '/black\=/c\black\=0x000000' /usr/share/plymouth/themes/text.plymouth
	sudo sed -i '/brown\=/c\brown\=0xff0000' /usr/share/plymouth/themes/text.plymouth
	sudo sed -i '/blue\=/c\blue\=0x0000ff' /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update1120020"
fi

if [ ! -f "/home/ark/.config/.update11212020" ]; then

	printf "\nInstall updated kernel with realtek chipset wifi fixes...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11212020/BootFileUpdates.tar.gz -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11212020/KernelUpdate.tar.gz -a "$LOG_FILE"
	sudo tar --same-owner -zxvf BootFileUpdates.tar.gz -C / | tee -a "$LOG_FILE"
	sudo tar --same-owner -zxvf KernelUpdate.tar.gz -C / | tee -a "$LOG_FILE"
	sudo rm -v BootFileUpdates.tar.gz | tee -a "$LOG_FILE"
	sudo rm -v KernelUpdate.tar.gz | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update11212020"
fi

if [ ! -f "/home/ark/.config/.update11212020-1" ]; then

	printf "\nUpdate platform name for SMS to mastersystem in es_systems.cfg to fix scraping...\n" | tee -a "$LOG_FILE"
	sudo sed -i '/platform>sms/c\\t\t<platform>mastersystem<\/platform>' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate retroarch to fix loading remap issues...\n" | tee -a "$LOG_FILE"
	mv -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11212020-1/retroarch -O /opt/retroarch/bin/retroarch -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"


	touch "/home/ark/.config/.update11212020-1"
fi

if [ ! -f "/home/ark/.config/.update11222020" ]; then

	printf "\nUpdate permissions on cheats and assets folder for retroarch and retroarch32 to fix cheats update\n" | tee -a "$LOG_FILE"
	sudo chown -R ark:ark /home/ark/.config/retroarch/cheats/*
	sudo chown -R ark:ark /home/ark/.config/retroarch32/cheats/*
	sudo chown -R ark:ark /home/ark/.config/retroarch/assets/*
	sudo chown -R ark:ark /home/ark/.config/retroarch32/assets/*
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.2 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11222020"
fi

if [ ! -f "/home/ark/.config/.update11232020" ]; then

	printf "\nInstall updated kernel adding additional supported realtek chipset wifi dongles...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/BootFileUpdates.tar.gz -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/KernelUpdate.tar.gz -a "$LOG_FILE"
	sudo tar --same-owner -zxvf BootFileUpdates.tar.gz -C / | tee -a "$LOG_FILE"
	sudo tar --same-owner -zxvf KernelUpdate.tar.gz -C / | tee -a "$LOG_FILE"
	sudo rm -v BootFileUpdates.tar.gz | tee -a "$LOG_FILE"
	sudo rm -v KernelUpdate.tar.gz | tee -a "$LOG_FILE"

	printf "\nCopy new dtbs and allow normal and high clock options...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /opt/system/Advanced | tee -a "$LOG_FILE"
	sudo mv -v /opt/system/"Fix ExFat Partition".sh /opt/system/Advanced/"Fix ExFat Partition".sh | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/Normal%20Clock.sh -O /opt/system/Advanced/"Normal Clock".sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/High%20Clock.sh -O /opt/system/Advanced/"High Clock".sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/Check%20Current%20Max%20Speed.sh -O /opt/system/Advanced/"Check Current Max Speed".sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/rk3326-rg351p-linux.dtb.13 -O /boot/rk3326-rg351p-linux.dtb.13 -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/rk3326-rg351p-linux.dtb.15 -O /boot/rk3326-rg351p-linux.dtb.15 -a "$LOG_FILE"
	sudo sed -i '/load mmc 1:1 ${dtb_loadaddr} rk3326-rg351p-linux.dtb/c\    load mmc 1:1 ${dtb_loadaddr} rk3326-rg351p-linux.dtb.13' /boot/boot.ini
	sudo chmod 777 -v /opt/system/Advanced/"Check Current Max Speed".sh | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Normal Clock".sh | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"High Clock".sh | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /opt/system | tee -a "$LOG_FILE"
	
	printf "\nAdd zh-CN as a language locale for Emulationstation...\n"
	sudo mkdir -v /usr/bin/emulationstation/resources/locale/zh-CN/ | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/zh-CN/emulationstation2.po -O /usr/bin/emulationstation/resources/locale/zh-CN/emulationstation2.po -a "$LOG_FILE"
	sudo chmod -R -v 777 /usr/bin/emulationstation/resources/locale/zh-CN | tee -a "$LOG_FILE"
	
	printf "\nUpdate Emulationstation to fix background music doesn't return after video screensaver stops...\n" | tee -a "$LOG_FILE"
	sudo mv -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11232020/emulationstation -O /usr/bin/emulationstation/emulationstation -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"

	printf "\nRedirect background music to roms/bgmusic folder for easy management...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/bgmusic/ | tee -a "$LOG_FILE"
	sudo mv -v /home/ark/.emulationstation/music/* /roms/bgmusic/ | tee -a "$LOG_FILE"
	sudo rm -rfv /home/ark/.emulationstation/music/ | tee -a "$LOG_FILE"
	sudo ln -s -v /roms/bgmusic/ /home/ark/.emulationstation/music | tee -a "$LOG_FILE"

	printf "\nInstall updated themes from Jetup(switch, epicnoir)..." | tee -a "$LOG_FILE"
	sudo rm -rfv /etc/emulationstation/themes/es-theme-switch/ | tee -a "$LOG_FILE"
	sudo rm -rfv /etc/emulationstation/themes/es-theme-epicnoir/ | tee -a "$LOG_FILE"
	sudo runuser -l ark -c "git clone --progress https://github.com/Jetup13/es-theme-switch /etc/emulationstation/themes/es-theme-switch/ 2> /dev/tty1"
	sudo runuser -l ark -c "git clone --progress https://github.com/Jetup13/es-theme-epicnoir /etc/emulationstation/themes/es-theme-epicnoir/ 2> /dev/tty1"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.3 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11232020"
fi

if [ ! -f "/home/ark/.config/.update11242020" ]; then

	printf "\nAdd lr-parallel_n64 core with rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11242020/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo touch .config/retroarch32/cores/parallel_n64_libretro.so.lck

	printf "\nAdd left analog stick support for pico-8...\n" | tee -a "$LOG_FILE"
	sudo cp -v /roms/bios/pico-8/sdl_controllers.txt /roms/bios/pico-8/sdl_controllers.txt.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11242020/sdl_controllers.txt -O /roms/bios/pico-8/sdl_controllers.txt -a "$LOG_FILE"

	printf "\nAdd option to disable and enable wifi to options/Advanced section for those with internal wifi...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11242020/Enable%20Wifi.sh -O /opt/system/Advanced/"Enable Wifi".sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11242020/Disable%20Wifi.sh -O /opt/system/Advanced/"Disable Wifi".sh -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Enable Wifi".sh | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Disable Wifi".sh | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /opt/system/Advanced | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.3 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11242020"
fi

if [ ! -f "/home/ark/.config/.update11252020" ]; then

	printf "\nInstall updated lr-mgba, lr-flycast_rumble, lr-parallel_n64, and lr-pcsx_rearmed cores with more efficient rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11252020/64bit/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11252020/64bit/flycast_rumble_libretro.so -O /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11252020/32bit/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11252020/32bit/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.3 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11252020"
fi

if [ ! -f "/home/ark/.config/.update11272020" ]; then

	printf "\nUpdate emulationstation adding timezone setting in start/advanced settings menu...\n" | tee -a "$LOG_FILE"
	sudo cp -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update11272020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/emulationstation -O /home/ark/emulationstation -a "$LOG_FILE"
	sudo mv -fv /home/ark/emulationstation /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/timezones -O /usr/local/bin/timezones -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/timezones | tee -a "$LOG_FILE"

	printf "\nUpdate retroarch32 to fix loading remap issues...\n" | tee -a "$LOG_FILE"
	mv -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.update11272020.bak | tee -a "$LOG_FILE"
	wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/retroarch32 -O /opt/retroarch/bin/retroarch32 -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"

	printf "\nInstall Atari ST...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/hatari_libretro.so -O /home/ark/.config/retroarch/cores/hatari_libretro.so -a "$LOG_FILE"
	if [ ! -d "/home/ark/.hatari/" ]; then
		sudo mkdir -v /home/ark/.hatari | tee -a "$LOG_FILE"
		sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/hatari.cfg -O /home/ark/.hatari/hatari.cfg -a "$LOG_FILE"
		sudo chown -R -v ark:ark /home/ark/.hatari/ | tee -a "$LOG_FILE"	
	fi
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11272020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/es_systems.cfg -O /etc/emulationstation/es_systems.cfg -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/hatari_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/hatari_libretro.so | tee -a "$LOG_FILE"	
	if [ ! -d "/roms/atarist/" ]; then
		sudo mkdir -v /roms/atarist | tee -a "$LOG_FILE"
	fi

	printf "\nInstall lr-vitaquake2 core...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/vitaquake2_libretro.so -O /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so | tee -a "$LOG_FILE"
	if [ ! -d "/roms/ports/quake2" ]; then
		sudo mkdir -v /roms/ports/quake2 | tee -a "$LOG_FILE"
		sudo mkdir -v /roms/ports/quake2/baseq2 | tee -a "$LOG_FILE"
		sudo touch /roms/ports/quake2/baseq2/"PUT YOUR PAK FILES HERE" | tee -a "$LOG_FILE"
		sudo mkdir -v /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/ | tee -a "$LOG_FILE"
		sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/vitaQuakeII.rmp -O /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/vitaQuakeII.rmp -a "$LOG_FILE"
		sudo chown -R -v ark:ark /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/ | tee -a "$LOG_FILE"
		sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11272020/Quake%202.sh -O /roms/ports/"Quake 2".sh -a "$LOG_FILE"		
	fi
	
	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.3 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11272020"
fi

if [ ! -f "/home/ark/.config/.update11292020" ]; then

	printf "\nUpdate emulationstation fixing missing keyboard for creating custom game collections...\n" | tee -a "$LOG_FILE"
	sudo cp -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update11292020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/emulationstation -O /home/ark/emulationstation -a "$LOG_FILE"
	sudo mv -fv /home/ark/emulationstation /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"

	printf "\nAdd Backup settings and Restore settings function to Options/Advance section...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/Backup%20Settings.sh -O /opt/system/Advanced/"Backup Settings".sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/Restore%20Settings.sh -O /opt/system/Advanced/"Restore Settings".sh -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/Advanced/"Restore Settings".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/Advanced/"Restore Settings".sh | tee -a "$LOG_FILE"

	printf "\nAdd lr-puae as additional Amiga emulator...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/amiga.sh -O /usr/local/bin/amiga.sh -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/amiga.sh | tee -a "$LOG_FILE"

	printf "\nAdd standalone scummvm emulator...\n" | tee -a "$LOG_FILE"
	sudo apt update -y && sudo apt -y install liba52-0.7.4:armhf libcurl4:armhf libmad0:armhf libjpeg62:armhf libmpeg2-4:armhf libogg-dbg:armhf libvorbis0a:armhf libflac8:armhf libpnglite0:armhf libtheora0:armhf libfaad2:armhf libfluidsynth1:armhf libfreetype6:armhf libspeechd2:armhf  | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11292020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/es_systems.cfg -O /etc/emulationstation/es_systems.cfg -a "$LOG_FILE"	
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/scummvm.sh -O /usr/local/bin/scummvm.sh -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/scummvm | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/scummvm.ini -O /home/ark/.config/scummvm/scummvm.ini -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/scummvm.tar.gz -O /home/ark/scummvm.tar.gz -a "$LOG_FILE"
	sudo tar --same-owner -zxhvf /home/ark/scummvm.tar.gz -C / | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/scummvm.sh | tee -a "$LOG_FILE"
	sudo chmod -v 777 /home/ark/.config/scummvm/scummvm.ini | tee -a "$LOG_FILE"
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /home/ark/.config/scummvm/ | tee -a "$LOG_FILE"
	sudo rm -fv /home/ark/scummvm.tar.gz | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/11292020/gamecontrollerdb.txt -O /opt/scummvm/extra/gamecontrollerdb.txt -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/scummvm/extra/gamecontrollerdb.txt | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update11292020"
fi

if [ ! -f "/home/ark/.config/.update12012020" ]; then

	printf "\nRevert Dreamcast(lr-flycast-rumble), N64(lr-parallel-n64), and PSX (lr-pcsx-rearmed) cores to previous versions...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/flycast_rumble_libretro.so -O /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"

	printf "\nAdd support for Tic-80 emulator...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/tic80_libretro.so -O /home/ark/.config/retroarch/cores/tic80_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/tic80_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/tic80_libretro.so | tee -a "$LOG_FILE"	
	sudo mkdir -v /roms/tic80 | tee -a "$LOG_FILE"	

	printf "\nInstall updated themes from Jetup(nes-box, switch, epicnoir)..." | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/es-theme-nes-box.zip -O /home/ark/es-theme-nes-box.zip -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/es-theme-switch.zip -O /home/ark/es-theme-switch.zip -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/es-theme-epicnoir.zip -O /home/ark/es-theme-epicnoir.zip -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-nes-box.zip -d /etc/emulationstation/themes/es-theme-nes-box/' | tee -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-switch.zip -d /etc/emulationstation/themes/es-theme-switch/' | tee -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-epicnoir.zip -d /etc/emulationstation/themes/es-theme-epicnoir/' | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-nes-box.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-switch.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-epicnoir.zip | tee -a "$LOG_FILE"	

	printf "\nUpdate es_systems.cfg to address platform name for famicom to nes and sfc to snes to fix scraping and add tic-80 support...\n" | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12012020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12012020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"

	printf "\nEnsure NDS performance hasn't been impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update12012020"
fi

if [ ! -f "/home/ark/.config/.update12032020" ]; then

	printf "\nRevert GBA(lr-mgba) core with rumble support to previous version...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12032020/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"

	printf "\nAdd Emulationstation menu translation for Portugal...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /usr/bin/emulationstation/resources/locale/pt/ | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12032020/pt/emulationstation2.po -O /usr/bin/emulationstation/resources/locale/pt/emulationstation2.po -a "$LOG_FILE"
	
	touch "/home/ark/.config/.update12032020"
fi

if [ ! -f "/home/ark/.config/.update12072020" ]; then

	printf "\nFix some Emulationstation menu translations...\n" | tee -a "$LOG_FILE"
	sudo rm -vf /usr/bin/emulationstation/resources/locale/pt/emulationstation2.po | tee -a "$LOG_FILE"
	sudo rm -vf /usr/bin/emulationstation/resources/locale/br/emulationstation2.po | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/EmulationStation-fcamod/raw/master/resources/locale/pt/emulationstation2.po -O /usr/bin/emulationstation/resources/locale/pt/emulationstation2.po -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/EmulationStation-fcamod/raw/master/resources/locale/br/emulationstation2.po -O /usr/bin/emulationstation/resources/locale/br/emulationstation2.po -a "$LOG_FILE"

	printf "\nFix wrong resolution for Vitaquake2 to fix initial performance if need be...\n" | tee -a "$LOG_FILE"
	cat /home/ark/.config/retroarch32/retroarch-core-options.cfg | grep vitaquakeii_resolution
	if [ $? -ne 0 ]; then
		sudo sed -i '/tyrquake_rumble/c\tyrquake_rumble \= \"disabled\"\nvitaquakeii_resolution \= \"480x272\"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
	fi

	printf "\nFix supported extensions for msx games and add and default emulator to bluemsx instead...\n" | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12072020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"

	printf "\nAdd support for the right analog stick to standalone ppsspp emulator and permission fix...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/PPSSPPSDL -O /opt/ppsspp/PPSSPPSDL -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/gamecontrollerdb.txt -O /opt/ppsspp/assets/gamecontrollerdb.txt -a "$LOG_FILE"
	sudo chmod -v 777 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/ppsspp/assets/gamecontrollerdb.txt | tee -a "$LOG_FILE"

	printf "\nAdd filebrowser web server...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/filebrowser -O /usr/local/bin/filebrowser -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/filebrowser.db -O /home/ark/.config/filebrowser.db -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/img | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/logo.svg -O /home/ark/.config/img/logo.svg -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/filebrowser | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/filebrowser.db | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/img/logo.svg | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/Disable%20Remote%20Services.sh -O /opt/system/"Disable Remote Services".sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/Enable%20Remote%20Services.sh -O /opt/system/"Enable Remote Services".sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12072020/filebrowser -O /usr/local/bin/filebrowser -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/"Disable Remote Services".sh | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/"Enable Remote Services".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/"Disable Remote Services".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/"Enable Remote Services".sh | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	#The following has been disabled due to reports of dns not resolving even though networkmanager should be able to resolve it.
	#printf "\nDisable systemd-resolved...\n" | tee -a "$LOG_FILE"
	#sudo systemctl disable systemd-resolved
	#sudo systemctl stop systemd-resolved
	#sudo cp -v /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.update12072020.bak | tee -a "$LOG_FILE"
	#sudo sed -i "/plugins\=/c\plugins\=ifupdown\,keyfile\ndns\=default" /etc/NetworkManager/NetworkManager.conf

	touch "/home/ark/.config/.update12072020"
fi

if [ ! -f "/home/ark/.config/.update12092020" ]; then

	printf "\nAdded non rumble enabled GBA cores (MGBA, VBA-M, VBA-NExt)...\n" | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12092020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12092020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12092020/mgba_rumble_libretro.so -O /home/ark/.config/retroarch/cores/mgba_rumble_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12092020/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12092020/vbam_libretro.so -O /home/ark/.config/retroarch/cores/vbam_libretro.so -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12092020/vba_next_libretro.so -O /home/ark/.config/retroarch/cores/vba_next_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"	
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/vbam_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/vbam_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/vba_next_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/vba_next_libretro.so | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/.config/retroarch/cores/mgba_libretro.so.lck | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nEnsure systemd-resolved has been reenabled...\n" | tee -a "$LOG_FILE"
	sudo systemctl enable systemd-resolved
	sudo systemctl start systemd-resolved
	
	touch "/home/ark/.config/.update12092020"
fi

if [ ! -f "/home/ark/.config/.update12122020" ]; then

	printf "\nAdd devolutionx(diablo) port support\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/devilution | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/ports/devilution | tee -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.local/share/diasurgical | tee -a "$LOG_FILE"
	sudo ln -s -v /roms/ports/devilution/ ~/.local/share/diasurgical/ | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/Devilutionx.sh -O /roms/ports/Devilutionx.sh -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/devilutionx -O /home/ark/.config/devilution/devilutionx -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/gamecontrollerdb.txt -O /roms/ports/devilution/gamecontrollerdb.txt -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/CharisSILB.ttf -O /usr/share/fonts/truetype/CharisSILB.ttf -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/libSDL2_mixer.a -O /usr/lib/arm-linux-gnueabihf/libSDL2_mixer.a -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/libSDL2_mixer-2.0.so.0.2.2 -O /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so | tee -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 /usr/lib/arm-linux-gnueabihf/libSDL2_mixer.so | tee -a "$LOG_FILE"	
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/libmodplug.so.1.0.0 -O /usr/lib/arm-linux-gnueabihf/libmodplug.so.1.0.0 -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libmodplug.so.1.0.0 /usr/lib/arm-linux-gnueabihf/libmodplug.so.1 | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/libopusfile.so.0.4.2 -O /usr/lib/arm-linux-gnueabihf/libopusfile.so.0.4.2 -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/libopusfile.a -O /usr/lib/arm-linux-gnueabihf/libopusfile.a -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/libopusurl.a -O /usr/lib/arm-linux-gnueabihf/libopusurl.a -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/libopusurl.so.0.4.2 -O /usr/lib/arm-linux-gnueabihf/libopusurl.so.0.4.2 -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libopusfile.so.0.4.2 /usr/lib/arm-linux-gnueabihf/libopusfile.so.0 | tee -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libopusfile.so.0.4.2 /usr/lib/arm-linux-gnueabihf/libopusfile.so | tee -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libopusurl.so.0.4.2 /usr/lib/arm-linux-gnueabihf/libopusurl.so.0 | tee -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libopusurl.so.0.4.2 /usr/lib/arm-linux-gnueabihf/libopusurl.so | tee -a "$LOG_FILE"
	sudo chmod -R -v 777 /home/ark/.config/devilution | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /home/ark/.config/devilution | tee -a "$LOG_FILE"

	printf "\nUpdate platform names for Colecovision, Intellivision and MSX2 in es_systems.cfg to fix scraping...\n" | tee -a "$LOG_FILE"
	sudo sed -i '/platform>coleco/c\\t\t<platform>colecovision<\/platform>' /etc/emulationstation/es_systems.cfg
	sudo sed -i '/platform>intv/c\\t\t<platform>intellivision<\/platform>' /etc/emulationstation/es_systems.cfg
	sudo sed -i '/platform>msx2/c\\t\t<platform>msx<\/platform>' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate Backup script to not include cheats and overlays to speed up process...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12122020/Backup%20Settings.sh -O /opt/system/Advanced/"Backup Settings".sh -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update12122020"
fi

if [ ! -f "/home/ark/.config/.update12152020" ]; then

	printf "\nInstall correct SDL2, Wayland, and graphics drivers to support more ports...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2+deb10_arm64.deb -O /home/ark/libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2+deb10_arm64.deb -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libsdl2-2.0-0_2.0.10+dfsg1-1ubuntu1_arm64.deb -O /home/ark/libsdl2-2.0-0_2.0.10+dfsg1-1ubuntu1_arm64.deb -a "$LOG_FILE"
	sudo dpkg -i --force-all /home/ark/libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2+deb10_arm64.deb /home/ark/libsdl2-2.0-0_2.0.10+dfsg1-1ubuntu1_arm64.deb
	sudo rm -v /home/ark/libmali-rk-bifrost-g31-rxp0-wayland-gbm_1.7-2+deb10_arm64.deb | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/libsdl2-2.0-0_2.0.10+dfsg1-1ubuntu1_arm64.deb | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libSDL2_image.a -O /usr/lib/aarch64-linux-gnu/libSDL2_image.a -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libSDL2_image-2.0.so.0.2.2 -O /usr/lib/aarch64-linux-gnu/libSDL2_image-2.0.so.0.2.2 -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libjpeg.a -O /usr/lib/aarch64-linux-gnu/libjpeg.a -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libjpeg.so.62.2.0 -O /usr/lib/aarch64-linux-gnu/libjpeg.so.62.2.0 -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libjpegxr.so.1.1 -O /usr/lib/aarch64-linux-gnu/libjpegxr.so.1.1 -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libSDL2_ttf.a -O /usr/lib/aarch64-linux-gnu/libSDL2_ttf.a -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libSDL2_ttf-2.0.so.0.14.1 -O /usr/lib/aarch64-linux-gnu/libSDL2_ttf-2.0.so.0.14.1 -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2_image-2.0.so.0.2.2 /usr/lib/aarch64-linux-gnu/libSDL2_image.so | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2_image-2.0.so.0.2.2 /usr/lib/aarch64-linux-gnu/libSDL2_image-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2_image-2.0.so.0 /usr/lib/aarch64-linux-gnu/libSDL2_image-2.0.so | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libjpeg.so.62.2.0 /usr/lib/aarch64-linux-gnu/libjpeg.so.62 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libjpeg.so.62.2.0 /usr/lib/aarch64-linux-gnu/libjpeg.so | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libjpegxr.so.1.1 /usr/lib/aarch64-linux-gnu/libjpegxr.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2_ttf-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2_ttf-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2_ttf-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2_ttf-2.0.so | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2_ttf-2.0.so.0.14.1 /usr/lib/aarch64-linux-gnu/libSDL2_ttf.so | tee -a "$LOG_FILE"
	
	printf "\nInstall image-viewer and default loading.jpg to support splash screens...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/image-viewer -O /usr/local/bin/image-viewer -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/image-viewer | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/launchimages | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/loading.jpg -O /roms/launchimages/loading.jpg -a "$LOG_FILE"
	
	printf "\nAdd Commander Genius port...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/ports/cgenius | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/ports/cgenius/games | tee -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/CGenius | tee -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.CommanderGenius | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/CGeniusExe -O /home/ark/.config/CGenius/CGeniusExe -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/cgenius.cfg -O /home/ark/.CommanderGenius/cgenius.cfg -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/keen-shr.zip -O /home/ark/keen-shr.zip -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/Commander%20Genius.sh -O /roms/ports/"Commander Genius".sh -a "$LOG_FILE"
	sudo chmod 777 -v /home/ark/.config/CGenius/CGeniusExe | tee -a "$LOG_FILE"
	sudo chown ark:ark -v /home/ark/.config/CGenius/CGeniusExe | tee -a "$LOG_FILE"
	sudo chown -R ark:ark -v /home/ark/.config/CGenius/ | tee -a "$LOG_FILE"
	unzip -o -d /roms/ports/cgenius/games /home/ark/keen-shr.zip
	sudo rm -v /home/ark/keen-shr.zip | tee -a "$LOG_FILE"

	#Not ready for primtime yet due to issues with controls
	#printf "\nAdd Openbor support...\n" | tee -a "$LOG_FILE"
	#sudo mkdir -v /roms/ports/OpenBor/ | tee -a "$LOG_FILE"
	#sudo mkdir -v /roms/ports/OpenBor/Paks | tee -a "$LOG_FILE"
	#sudo mkdir -v /roms/ports/OpenBor/Saves | tee -a "$LOG_FILE"
	#sudo mkdir -v /roms/ports/OpenBor/ScreenShots | tee -a "$LOG_FILE"
	#sudo mkdir -v /home/ark/.config/OpenBor | tee -a "$LOG_FILE"
	#sudo ln -sfv /roms/ports/OpenBor/Saves /home/ark/.config/OpenBor/Saves | tee -a "$LOG_FILE"
	#sudo ln -sfv /roms/ports/OpenBor/ScreenShots /home/ark/.config/OpenBor/ScreenShots | tee -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/OpenBor -O /home/ark/.config/OpenBor/OpenBor -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/OpenBor.elf -O /home/ark/.config/OpenBor/OpenBor.elf -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/master.cfg -O /home/ark/.config/OpenBor/master.cfg -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libvpx.a -O /usr/lib/aarch64-linux-gnu/libvpx.a -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/libvpx.so.5.0.0 -O /usr/lib/aarch64-linux-gnu/libvpx.so.5.0.0 -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/OpenBor.sh -O /roms/ports/OpenBor.sh -a "$LOG_FILE"
	#sudo ln -sfv /usr/lib/aarch64-linux-gnu/libvpx.so.5.0.0 /usr/lib/aarch64-linux-gnu/libvpx.so.5.0 | tee -a "$LOG_FILE"
	#sudo ln -sfv /usr/lib/aarch64-linux-gnu/libvpx.so.5.0.0 /usr/lib/aarch64-linux-gnu/libvpx.so.5 | tee -a "$LOG_FILE"
	#sudo ln -sfv /usr/lib/aarch64-linux-gnu/libvpx.so.5.0.0 /usr/lib/aarch64-linux-gnu/libvpx.so | tee -a "$LOG_FILE"
	#sudo chown -R ark:ark -v /home/ark/.config/OpenBor/ | tee -a "$LOG_FILE"
	#sudo chown 777 -v /home/ark/.config/OpenBor/OpenBor | tee -a "$LOG_FILE"
	#sudo chown 777 -v /home/ark/.config/OpenBor/OpenBor.elf | tee -a "$LOG_FILE"

	printf "\nAdd Opentyrian port...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/ports/opentyrian | tee -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/opentyrian | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/opentyrian-arkos.tar.gz -O /home/ark/opentyrian-arkos.tar.gz -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/otyriandata.zip -O /home/ark/otyriandata.zip -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/OpenTyrian.sh -O /roms/ports/OpenTyrian.sh -a "$LOG_FILE"
	sudo tar --same-owner -zxhvf /home/ark/opentyrian-arkos.tar.gz -C / | tee -a "$LOG_FILE"
	unzip -o -d /roms/ports/opentyrian/ /home/ark/otyriandata.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/otyriandata.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/opentyrian-arkos.tar.gz | tee -a "$LOG_FILE"
	
	printf "\nUpdate scripts to show loading.jpg before game launch if available...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/perfmax -O /usr/local/bin/perfmax -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/perfnorm -O /usr/local/bin/perfnorm -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/perfmax | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/perfnorm | tee -a "$LOG_FILE"

	printf "\nUpdate sources.list to fix apt-get since EOAN is now End of Life for new updates...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/sources.list -O /etc/apt/sources.list -a "$LOG_FILE"

	printf "\nFix L2 button for devilutionX...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/gamecontrollerdb.txt -O /roms/ports/devilution/gamecontrollerdb.txt -a "$LOG_FILE"

	printf "\nReally Update Backup script this time to not include cheats and overlays to speed up process...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/Backup%20Settings.sh -O /opt/system/Advanced/"Backup Settings".sh -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"

	#printf "\nAdd Emulationstation menu translation for German and corrections for es and corrections for Spanish and French...\n" | tee -a "$LOG_FILE"
	#sudo mkdir -v /usr/bin/emulationstation/resources/locale/de/ | tee -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/pt/emulationstation2.po.de -O /usr/bin/emulationstation/resources/locale/de/emulationstation2.po -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/pt/emulationstation2.po.es -O /usr/bin/emulationstation/resources/locale/es/emulationstation2.po -a "$LOG_FILE"
	#sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12152020/pt/emulationstation2.po.fr -O /usr/bin/emulationstation/resources/locale/pr/emulationstation2.po -a "$LOG_FILE"
	
	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update12152020"
fi

if [ ! -f "/home/ark/.config/.update12162020" ]; then
	
	printf "\nFix bad update for German, Spanish and French ES Menu entries...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /usr/bin/emulationstation/resources/locale/de/ | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/emulationstation2.po.de -O /usr/bin/emulationstation/resources/locale/de/emulationstation2.po -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/emulationstation2.po.es -O /usr/bin/emulationstation/resources/locale/es/emulationstation2.po -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/emulationstation2.po.fr -O /usr/bin/emulationstation/resources/locale/fr/emulationstation2.po -a "$LOG_FILE"

	printf "\nAdd update for a few themes to support Solarus and lzdoom system entry...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/es-theme-nes-box.zip -O /home/ark/es-theme-nes-box.zip -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-nes-box.zip -d /etc/emulationstation/themes/es-theme-nes-box/' | tee -a "$LOG_FILE"
	sudo rm -rfv /home/ark/es-theme-nes-box.zip | tee -a "$LOG_FILE"
	sudo rm -rfv /etc/emulationstation/themes/es-theme-switch/ | tee -a "$LOG_FILE"
	sudo rm -rfv /etc/emulationstation/themes/es-theme-epicnoir/ | tee -a "$LOG_FILE"
	sudo runuser -l ark -c "git clone --progress https://github.com/Jetup13/es-theme-switch /etc/emulationstation/themes/es-theme-switch/ 2> /dev/tty1"
	sudo runuser -l ark -c "git clone --progress https://github.com/Jetup13/es-theme-epicnoir /etc/emulationstation/themes/es-theme-epicnoir/ 2> /dev/tty1"

	printf "\nAdd lzdoom as default emulator for Doom wads for new location...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/doom | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12162020.bak | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/lzdoom.tar.gz -O /home/ark/lzdoom.tar.gz -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/doom.sh -O /usr/local/bin/doom.sh -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/doom.sh | tee -a "$LOG_FILE"
	tar -zxvf /home/ark/lzdoom.tar.gz -C / | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/lzdoom.tar.gz | tee -a "$LOG_FILE"
	
	printf "\nAdd support for Solarus...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/solarus | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/solarus.tar.gz -O /home/ark/solarus.tar.gz "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/solarus.sh -O /usr/local/bin/solarus.sh "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12162020/solarushotkeydemon.py -O /usr/local/bin/solarushotkeydemon.py "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/solarus.sh | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/solarushotkeydemon.py | tee -a "$LOG_FILE"
	sudo tar --same-owner -zxvf /home/ark/solarus.tar.gz -C / | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/solarus.tar.gz | tee -a "$LOG_FILE"
	
	touch "/home/ark/.config/.update12162020"
fi

#Accidentally merged this update without include an apt update first so this may not have been implemented.
#if [ ! -f "/home/ark/.config/.update12172020" ]; then
	
#	printf "\nAdd support for RetroArch text-to-speech accessibility feature...\n" | tee -a "$LOG_FILE"
#	sudo apt update -y && sudo apt -y install espeak espeak-data | tee -a "$LOG_FILE"
	
#	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
#	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
#	touch "/home/ark/.config/.update12172020"
#fi

if [ ! -f "/home/ark/.config/.update12182020" ]; then

	printf "\nAdd support for RetroArch text-to-speech accessibility feature...\n" | tee -a "$LOG_FILE"
	sudo apt update -y && sudo apt -y install espeak espeak-data | tee -a "$LOG_FILE"
	
	printf "\nAdd Tic-80 to the ES system menu\nAdd VVVVVV port" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12182020/arkosupdate12182020.zip -O /home/ark/arkosupdate12182020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12182020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12182020.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12182020.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	if [ -f "/home/ark/.config/.update12182020" ]; then
		printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	touch "/home/ark/.config/.update12182020"
fi

if [ ! -f "/home/ark/.config/.update12192020" ]; then

	printf "\nUpdate lzdoom to swap OK and Cancel buttons\nUpdated PPSSPPSDL to version 1.10.3 version with batocera speedup\nCenter Solarus" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12192020/arkosupdate12192020.zip -O /home/ark/arkosupdate12192020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12192020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12192020.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12192020.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	sudo rm -v /opt/solarus/libsolarus.so.1 | tee -a "$LOG_FILE"
	sudo rm -v /opt/solarus/libsolarus.so | tee -a "$LOG_FILE"
	sudo ln -sfv /opt/solarus/libsolarus.so.1.7.0 /opt/solarus/libsolarus.so.1 | tee -a "$LOG_FILE"
	sudo ln -sfv /opt/solarus/libsolarus.so.1.7.0 /opt/solarus/libsolarus.so | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/solarus/libsolarus* | tee -a "$LOG_FILE"
	sudo chown ark:ark -v /opt/solarus/libsolarus* | tee -a "$LOG_FILE"

	if [ -f "/home/ark/.config/.update12192020" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.update12192020"
fi

if [ ! -f "/home/ark/.config/.update12192020-1" ]; then

	printf "\nRevert PPSSPP back to previous version...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12192020-1/arkosupdate12192020-1.zip -O /home/ark/arkosupdate12192020-1.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12192020-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12192020-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12192020-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12192020-1" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	touch "/home/ark/.config/.update12192020-1"
fi

if [ ! -f "/home/ark/.config/.update12212020" ]; then

	printf "\nReadd PPSSPPSDL and keep original PPSSPPGO\nAdd glide64mk2 plugin for mupen64plus\nUpdate lzdoom.ini to support Heretic, Hexen, Strife, and Chex Quest...\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12212020/arkosupdate12212020.zip -O /home/ark/arkosupdate12212020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12212020.zip" ]; then
		cp -r -f -v /opt/ppsspp /opt/ppssppgo | tee -a "$LOG_FILE"
		cp -f -v /roms/psp/ppsspp/PSP/SYSTEM/ppsspp.ini /roms/psp/ppsspp/PSP/SYSTEM/ppsspp.ini.go
		touch /home/ark/.config/.update12212020
		sudo unzip -X -o /home/ark/arkosupdate12212020.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12212020.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12212020" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	touch "/home/ark/.config/.update12212020"
fi

if [ ! -f "/home/ark/.config/.update12212020-1" ]; then

	printf "\nFix Emulationstation menu for last update\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12212020-1/arkosupdate12212020-1.zip -O /home/ark/arkosupdate12212020-1.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12212020-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12212020-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate12212020-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update12212020-1" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi
	
	touch "/home/ark/.config/.update12212020-1"
fi

if [ ! -f "/home/ark/.config/.update12222020" ]; then

	printf "\nAdd support for half-life\nAdd battery life indicator\nAdd PoP port\nAdd dosbox-pure\nFix solarus exit daemon\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12222020/arkosupdate12222020.zip -O /home/ark/arkosupdate12222020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12222020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12222020.zip -d / | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		sudo systemctl enable batt_led.service
		sudo systemctl start batt_led.service
		sudo rm -v /home/ark/arkosupdate12222020.zip | tee -a "$LOG_FILE"
		sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12222020/XASH3D_LICENSE -O /roms/ports/Half-Life/XASH3D_LICENSE -a "$LOG_FILE"
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

if [ ! -f "/home/ark/.config/.update12262020" ]; then

	printf "\nAdd File Manger to Options section\nAdd updated dtb to address possible occassional freezes for RG351P\nAdd updated blacklist to stabilize rtl8xxx wifi chipsets\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12262020/arkosupdate12262020.zip -O /home/ark/arkosupdate12262020.zip -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12262020.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate12262020.zip -d / | tee -a "$LOG_FILE"
		sudo dpkg -i /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb
		sudo rm -v /home/ark/arkosupdate12262020.zip | tee -a "$LOG_FILE"
		sudo rm -v /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12262020-1/DinguxCommander -O /opt/dingux/DinguxCommander -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12262020-1/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb -O /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12262020-1/oshgamepad.cfg -O /opt/dingux/oshgamepad.cfg -a "$LOG_FILE"
	sudo dpkg -i /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb
	sudo rm -v /opt/dingux/libsdl2-gfx-1.0-0_1.0.4+dfsg-3_armhf.deb | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/dingux/DinguxCommander | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/dingux/DinguxCommander | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/dingux/oshgamepad.cfg | tee -a "$LOG_FILE"

	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update12262020-1"
fi

if [ ! -f "/home/ark/.config/.update12272020" ]; then

	printf "\nUpdated es_systems.cfg to support .m3u for cd systems and .sh for doom mods\nAdd updated blacklist for realtek chipset fixes.\n"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12272020/arkosupdate12272020.zip -O /home/ark/arkosupdate12272020.zip -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/12272020-1/arkosupdate12272020-1.zip -O /home/ark/arkosupdate12272020-1.zip -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01022021/rg351p/arkosupdate01022021.zip -O /home/ark/arkosupdate01022021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01022021.zip | tee -a "$LOG_FILE"
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

	printf "\nUpdate low battery warning python script to flash on 19 percent or lower\n"
		sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01042021/arkosupdate01042021.zip -O /home/ark/arkosupdate01042021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01042021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01042021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01042021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01042021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	if [ -f "/home/ark/.config/.update01042021" ]; then
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
		sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.update01042021"
fi

if [ ! -f "/home/ark/.config/.update01052021" ]; then

	printf "\nIncrease audio period and buffer sizes temporarily for Drastic\nFix excessive cpu usage from batt_life_warning script\nAdded updated retroarch with netplay fix\n"
		sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01052021/arkosupdate01052021.zip -O /home/ark/arkosupdate01052021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01052021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01092021/arkosupdate01092021.zip -O /home/ark/arkosupdate01092021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01092021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01102021/arkosupdate01102021.zip -O /home/ark/arkosupdate01102021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01102021.zip | tee -a "$LOG_FILE"
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

	printf "\nAdd vibration support for Pokemon mini emulator (RG351P Only!)\nAdd 32bit opentyrian port to address performance\n" | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /home/ark/.config/opentyrian/ | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01112021/arkosupdate01112021.zip -O /home/ark/arkosupdate01112021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01112021.zip | tee -a "$LOG_FILE"
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

if [ ! -f "/home/ark/.config/.update01152021" ]; then

	printf "\nUpdate vibration enabled cores (flycast, mgba, and pcsx_rearmed)\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01152021/arkosupdate01152021.zip -O /home/ark/arkosupdate01152021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01152021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate01152021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate01152021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate01152021.zip | tee -a "$LOG_FILE"
		sudo sed -i -e '/<core>pcsx_rearmed<\/core>/{r /home/ark/add_pcsxrearmedrumble.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_pcsxrearmedrumble.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.update01152021"
fi

if [ ! -f "/home/ark/.config/.update01162021" ]; then

	printf "\nAdd lr-Uzebox emulator\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01162021/arkosupdate01162021.zip -O /home/ark/arkosupdate01162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01162021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01172021/arkosupdate01172021.zip -O /home/ark/arkosupdate01172021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01172021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01182021/arkosupdate01182021.zip -O /home/ark/arkosupdate01182021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01182021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01212021/arkosupdate01212021.zip -O /home/ark/arkosupdate01212021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01212021.zip | tee -a "$LOG_FILE"
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

	printf "\nFix deadzone for Half-Life\n" | tee -a "$LOG_FILE"
	sudo sed -i '/joy_forward_deadzone "0"/c\joy_forward_deadzone "10000"' /roms/ports/Half-Life/valve/config.cfg
	sudo sed -i '/joy_pitch_deadzone "0"/c\joy_pitch_deadzone "10000"' /roms/ports/Half-Life/valve/config.cfg
	sudo sed -i '/joy_side_deadzone "0"/c\joy_side_deadzone "10000"' /roms/ports/Half-Life/valve/config.cfg
	sudo sed -i '/joy_yaw_deadzone "0"/c\joy_yaw_deadzone "10000"' /roms/ports/Half-Life/valve/config.cfg

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.5 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01212021-1"
fi

if [ ! -f "/home/ark/.config/.update01242021" ]; then

	printf "\nUpdate ES to fix scraping for daphne, neogeo cd, and xegs\nAdd tic-80 and sharp x1 scraping\nFix audio for ppsspp-go-standalone\nAdjust batterylife warning\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01242021/arkosupdate01242021.zip -O /home/ark/arkosupdate01242021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01242021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01282021/arkosupdate01282021.zip -O /home/ark/arkosupdate01282021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01282021.zip | tee -a "$LOG_FILE"
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

	printf "\nAdd platform name for scummvm\nFix scummvm scan games script to allow for spaces in directory name\nAdd workaround for OpenBor sleep issue\nFix loading of scummvm games in retroarch\nUpdate dosbox_pure 0.10 for performance\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/01292021/arkosupdate01292021.zip -O /home/ark/arkosupdate01292021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate01292021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/02032021/arkosupdate02032021.zip -O /home/ark/arkosupdate02032021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02032021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/02132021/arkosupdate02132021.zip -O /home/ark/arkosupdate02132021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02132021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/02132021-1/USB%20Drive%20Mount.sh -O "/opt/system/USB Drive Mount.sh" -a "$LOG_FILE" || rm -f "/opt/system/USB Drive Mount.sh" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/02132021-1/USB%20Drive%20Unmount.sh -O "/opt/system/USB Drive Unmount.sh" -a "$LOG_FILE" || rm -f "/opt/system/USB Drive Unmount.sh" | tee -a "$LOG_FILE"
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

if [ ! -f "/home/ark/.config/.update02192021" ]; then

	printf "\nAdd ZX81 lr emulator\nClean up USB mount script\nAdd pico-8 as system\nUpdate NES box theme to include pico-8\nUpdate Emulationstation to support scraping pico-8\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/02192021/arkosupdate02192021.zip -O /home/ark/arkosupdate02192021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02192021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/02202021/arkosupdate02202021.zip -O /home/ark/arkosupdate02202021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02202021.zip | tee -a "$LOG_FILE"
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
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/02272021/arkosupdate02272021.zip -O /home/ark/arkosupdate02272021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate02272021.zip | tee -a "$LOG_FILE"
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

	printf "\nUpdate retroarch and retroarch32 core_updater_buildbot_cores_url\nUpdate retroarch and retroarch32 to support OGS resolution\nAdd easyrpg as ES system with scraping support\nAdd option for ascii art loading screen\nUpdate nes-box theme for easyrpg\nRevert lr-mgba to older faster core\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/03082021/arkosupdate03082021.zip -O /home/ark/arkosupdate03082021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate03082021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate03082021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate03082021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate03082021.zip | tee -a "$LOG_FILE"
		sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02272021.bak | tee -a "$LOG_FILE"
		sudo sed -i -e '/<theme>doom<\/theme>/{r /home/ark/add_easyrpg.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/add_easyrpg.txt | tee -a "$LOG_FILE"
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
	if [[ "$test" == "3150376" ]]; then
		sudo cp -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	else
		sudo cp -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	fi
	
	touch "/home/ark/.config/.update03082021"
fi

if [ ! -f "/home/ark/.config/.kernelupdate02032021" ]; then

	printf "\nInstall updated kernel, dtb, and modules\n"
	sudo wget --no-check-certificate http://gitcdn.link/repo/christianhaitian/arkos/main/03082021/newkernelnmodndtb02032021.zip -O /home/ark/newkernelnmodndtb02032021.zip -a "$LOG_FILE" || rm -f /home/ark/newkernelnmodndtb02032021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/newkernelnmodndtb02032021.zip" ]; then
		sudo unzip -X -o /home/ark/newkernelnmodndtb02032021.zip -d / | tee -a "$LOG_FILE"
		sudo depmod 4.4.189
		sudo rm -v /home/ark/newkernelnmodndtb02032021.zip | tee -a "$LOG_FILE"
		sudo cp -v /boot/rk3326-rg351p-linux.dtb /boot/rk3326-rg351p-linux.dtb.13 | tee -a "$LOG_FILE"
		sudo rm -rfv /lib/modules/4.4.189-139502-g380eeff98d35/ | tee -a "$LOG_FILE"
	else 
		printf "\nThe update of your kernel couldn't complete because the kernel package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	touch "/home/ark/.config/.kernelupdate02032021"
fi

if [ ! -f "/home/ark/.config/.update03182021" ]; then

	printf "\nUpdate oga_events service to use ogage instead\nUpdate retrorun and retrorun32\nUpdate saturn.sh to fix retrorun triggers\nUpdate rtl8812au wifi adapter\nUpdate Option scripts that use rg351p-js2xbox scripts\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/cdn/christianhaitian/arkos/main/03182021/arkosupdate03182021.zip -O /home/ark/arkosupdate03182021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate03182021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate03182021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate03182021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate03182021.zip | tee -a "$LOG_FILE"
		sudo apt update -y && sudo apt -y install brightnessctl
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

	printf "\nFix retrorun hotkey issue\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/cdn/christianhaitian/arkos/main/03182021-1/arkosupdate03182021-1.zip -O /home/ark/arkosupdate03182021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate03182021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate03182021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate03182021-1.zip -d / | tee -a "$LOG_FILE"
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

if [ ! -f "/home/ark/.config/.update04032021" ]; then

	printf "\nUpdate to Retroarch 1.9.1\nUpdated ogage\nUpdate perfmax script for better battery life\nReplace glupen64 with mupen64plus core\nIncrease emulation process priority\nUpdate Hypseus to 1.3.0\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/cdn/christianhaitian/arkos/main/04032021/arkosupdate04032021.zip -O /home/ark/arkosupdate04032021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04032021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate04032021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate04032021.zip -d / | tee -a "$LOG_FILE"
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

	printf "\nUpdate Enable Remote Services script to show assigned IP and 5s pause\nUpdate perfmax and perfnorm for image blinking fix\nUpdate emulationstaton fullscreen and header to not use Batocera's scraping ID\nUpdate ScummVM with AGS support\nUpdate video shader delay settings\nUpdate DevilutionX to resolve mouse control issue\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/cdn/christianhaitian/arkos/main/04162021/arkosupdate04162021.zip -O /home/ark/arkosupdate04162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04162021.zip | tee -a "$LOG_FILE"
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
		if [ -f "/opt/system/Advanced/Switch Launchimage to ascii.sh" ]; then
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
	sudo wget --no-check-certificate http://gitcdn.link/cdn/christianhaitian/arkos/master/04222021/arkosupdate04222021.zip -O /home/ark/arkosupdate04222021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate04222021.zip | tee -a "$LOG_FILE"
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
	if [[ "$test" == "3835024" ]]; then
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
	sudo wget --no-check-certificate http://gitcdn.link/cdn/christianhaitian/arkos/master/05012021/arkosupdate05012021.zip -O /home/ark/arkosupdate05012021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05012021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05012021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05012021.zip -d / | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 351P/M Final" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update05012021"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nFix Sonic CD exit hotkey daemon\n" | tee -a "$LOG_FILE"
	sudo wget --no-check-certificate http://gitcdn.link/cdn/christianhaitian/arkos/master/05012021-1/arkosupdate05012021-1.zip -O /home/ark/arkosupdate05012021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate05012021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate05012021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate05012021-1.zip -d / | tee -a "$LOG_FILE"
		sudo sed -i '/ScreenWidth\=320/s//ScreenWidth\=360/' /roms/ports/sonic1/settings.ini
		sudo sed -i '/ScreenWidth\=320/s//ScreenWidth\=360/' /roms/ports/sonic2/settings.ini
		sudo sed -i '/ScreenWidth\=320/s//ScreenWidth\=360/' /roms/ports/soniccd/settings.ini
		sudo systemctl daemon-reload
		sudo rm -v /home/ark/arkosupdate05012021-1.zip | tee -a "$LOG_FILE"
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
	sudo sed -i "/title\=/c\title\=ArkOS 351P/M Final" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187	
fi