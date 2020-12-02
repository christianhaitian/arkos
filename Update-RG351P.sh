#!/bin/bash
clear

UPDATE_DATE="12012020"
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

if [ ! -f "/home/ark/.config/.update11132020" ]; then
	printf "\nCorrect FAVORIS to FAVORITE at the bottom of the screen when inside a system menu...\n" | tee -a "$LOG_FILE"
	sudo mv -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11132020/emulationstation -O /usr/bin/emulationstation/emulationstation -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	
	printf "\nAdd missing genesis folder to EASYROMS directory if it doesn't already exist...\n" | tee -a "$LOG_FILE"
	if [ ! -d "/roms/genesis/" ]; then
		sudo mkdir -v /roms/genesis
	fi

	printf "\nFix input not shown when inserting username/password in scraper menu...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11132020/theme.xml -O /etc/emulationstation/themes/es-theme-nes-box/theme.xml -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/themes/es-theme-nes-box/theme.xml | tee -a "$LOG_FILE"
	sudo chmod -v 664 /etc/emulationstation/themes/es-theme-nes-box/theme.xml | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update11132020"
fi

if [ ! -f "/home/ark/.config/.update11142020" ]; then
	printf "\nFix the power led status...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/boot.ini -O /boot/boot.ini -a "$LOG_FILE"
	
	printf "\nAdd support for Rumble...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/addrumblesupport-crontab -O /home/ark/addrumblesupport-crontab -a "$LOG_FILE"	
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/enable_rumble -O /usr/local/bin/enable_rumble -a "$LOG_FILE"	
	sudo chmod -v 777 /usr/local/bin/enable_rumble | tee -a "$LOG_FILE"
	sudo crontab /home/ark/addrumblesupport-crontab
	printf "\nsudo crontab -e has been updated to:\n" | tee -a "$LOG_FILE" && sudo crontab -l | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/addrumblesupport-crontab | tee -a "$LOG_FILE"
	
	printf "\nInstall lr-pcsx_rearmed core with rumble support...\n"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"	
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/pcsx_rearmed_libretro.so.lck -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck -a "$LOG_FILE"	
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 644 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update11142020"
fi

if [ ! -f "/home/ark/.config/.update11152020" ]; then
	printf "\nInstall lr-flycast_rumble core with rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11152020/flycast_rumble_libretro.so -O /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	
	printf "\nInstall Amstrad CPC and Game and Watch retroarch cores...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11152020/cap32_libretro.so -O /home/ark/.config/retroarch/cores/cap32_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11152020/gw_libretro.so -O /home/ark/.config/retroarch/cores/gw_libretro.so -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11152020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11152020/es_systems.cfg -O /etc/emulationstation/es_systems.cfg -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11152020/es-theme-nes-box.zip -O /home/ark/es-theme-nes-box.zip -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-nes-box.zip -d /etc/emulationstation/themes/es-theme-nes-box/' | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-nes-box.zip | tee -a "$LOG_FILE"
	sudo runuser -l ark -c "git clone https://github.com/tiduscrying/es-theme-gbz35_mod /etc/emulationstation/themes/es-theme-gbz35-mod/ 2> /dev/tty1"
	sudo runuser -l ark -c "git clone https://github.com/tiduscrying/es-theme-gbz35-dark_mod /etc/emulationstation/themes/es-theme-gbz35-dark-mod/ 2> /dev/tty1"

	touch "/home/ark/.config/.update11152020"
fi

if [ ! -f "/home/ark/.config/.update11162020" ]; then
	printf "\nInstall updated lr-mgba core with rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11162020/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11162020/mgba_libretro.so.lck -O /home/ark/.config/retroarch/cores/mgba_libretro.so.lck -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so.lck | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so.lck | tee -a "$LOG_FILE"	

	printf "\nInstall updated options scripts to remove unnecessary screen outputs during loading...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11162020/Change%20Password.sh -O /opt/system/"Change Password.sh" -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11162020/Network%20Info.sh -O /opt/system/"Network Info.sh" -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11162020/Update.sh -O /opt/system/Update.sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11162020/Wifi.sh -O /opt/system/Wifi.sh -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11182020/boot.ini -O /boot/boot.ini -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11182020/addledfix-crontab -O /home/ark/addledfix-crontab -a "$LOG_FILE"	
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11182020/fix_power_led -O /usr/local/bin/fix_power_led -a "$LOG_FILE"	
	sudo chmod -v 777 /usr/local/bin/fix_power_led | tee -a "$LOG_FILE"
	sudo crontab /home/ark/addledfix-crontab
	sudo rm -v /home/ark/addledfix-crontab | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update11182020-1"
fi

if [ ! -f "/home/ark/.config/.update1120020" ]; then

	printf "\nUpdate mednafen_pce_fast libretro core to fix turbo button issue..." | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11202020/mednafen_pce_fast_libretro.so -O /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so -a "$LOG_FILE"
	sudo touch /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so.lck
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mednafen_pce_fast_libretro.so.lck | tee -a "$LOG_FILE"

	printf "\nUpdate Emulationstation to fix shift key for builtin keyboard...\n" | tee -a "$LOG_FILE"
	sudo mv -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11202020/emulationstation -O /usr/bin/emulationstation/emulationstation -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"

	printf "\nUpdate boot colors\n" | tee -a "$LOG_FILE"
	sudo sed -i '/black\=/c\black\=0x000000' /usr/share/plymouth/themes/text.plymouth
	sudo sed -i '/brown\=/c\brown\=0xff0000' /usr/share/plymouth/themes/text.plymouth
	sudo sed -i '/blue\=/c\blue\=0x0000ff' /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update1120020"
fi

if [ ! -f "/home/ark/.config/.update11212020" ]; then

	printf "\nInstall updated kernel with realtek chipset wifi fixes...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11212020/BootFileUpdates.tar.gz -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11212020/KernelUpdate.tar.gz -a "$LOG_FILE"
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
	wget https://github.com/christianhaitian/arkos/raw/main/11212020-1/retroarch -O /opt/retroarch/bin/retroarch -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/BootFileUpdates.tar.gz -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/KernelUpdate.tar.gz -a "$LOG_FILE"
	sudo tar --same-owner -zxvf BootFileUpdates.tar.gz -C / | tee -a "$LOG_FILE"
	sudo tar --same-owner -zxvf KernelUpdate.tar.gz -C / | tee -a "$LOG_FILE"
	sudo rm -v BootFileUpdates.tar.gz | tee -a "$LOG_FILE"
	sudo rm -v KernelUpdate.tar.gz | tee -a "$LOG_FILE"

	printf "\nCopy new dtbs and allow normal and high clock options...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /opt/system/Advanced | tee -a "$LOG_FILE"
	sudo mv -v /opt/system/"Fix ExFat Partition".sh /opt/system/Advanced/"Fix ExFat Partition".sh | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/Normal%20Clock.sh -O /opt/system/Advanced/"Normal Clock".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/High%20Clock.sh -O /opt/system/Advanced/"High Clock".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/Check%20Current%20Max%20Speed.sh -O /opt/system/Advanced/"Check Current Max Speed".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/rk3326-rg351p-linux.dtb.13 -O /boot/rk3326-rg351p-linux.dtb.13 -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/rk3326-rg351p-linux.dtb.15 -O /boot/rk3326-rg351p-linux.dtb.15 -a "$LOG_FILE"
	sudo sed -i '/load mmc 1:1 ${dtb_loadaddr} rk3326-rg351p-linux.dtb/c\    load mmc 1:1 ${dtb_loadaddr} rk3326-rg351p-linux.dtb.13' /boot/boot.ini
	sudo chmod 777 -v /opt/system/Advanced/"Check Current Max Speed".sh | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Normal Clock".sh | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"High Clock".sh | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /opt/system | tee -a "$LOG_FILE"
	
	printf "\nAdd zh-CN as a language locale for Emulationstation...\n"
	sudo mkdir -v /usr/bin/emulationstation/resources/locale/zh-CN/ | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/zh-CN/emulationstation2.po -O /usr/bin/emulationstation/resources/locale/zh-CN/emulationstation2.po -a "$LOG_FILE"
	sudo chmod -R -v 777 /usr/bin/emulationstation/resources/locale/zh-CN | tee -a "$LOG_FILE"
	
	printf "\nUpdate Emulationstation to fix background music doesn't return after video screensaver stops...\n" | tee -a "$LOG_FILE"
	sudo mv -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11232020/emulationstation -O /usr/bin/emulationstation/emulationstation -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo touch .config/retroarch32/cores/parallel_n64_libretro.so.lck

	printf "\nAdd left analog stick support for pico-8...\n" | tee -a "$LOG_FILE"
	sudo cp -v /roms/bios/pico-8/sdl_controllers.txt /roms/bios/pico-8/sdl_controllers.txt.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/sdl_controllers.txt -O /roms/bios/pico-8/sdl_controllers.txt -a "$LOG_FILE"

	printf "\nAdd option to disable and enable wifi to options/Advanced section for those with internal wifi...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/Enable%20Wifi.sh -O /opt/system/Advanced/"Enable Wifi".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/Disable%20Wifi.sh -O /opt/system/Advanced/"Disable Wifi".sh -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Enable Wifi".sh | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Disable Wifi".sh | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /opt/system/Advanced | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.3 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11242020"
fi

if [ ! -f "/home/ark/.config/.update11252020" ]; then

	printf "\nInstall updated lr-mgba, lr-flycast_rumble, lr-parallel_n64, and lr-pcsx_rearmed cores with more efficient rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11252020/64bit/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11252020/64bit/flycast_rumble_libretro.so -O /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11252020/32bit/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11252020/32bit/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/emulationstation -O /home/ark/emulationstation -a "$LOG_FILE"
	sudo mv -fv /home/ark/emulationstation /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/timezones -O /usr/local/bin/timezones -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/timezones | tee -a "$LOG_FILE"

	printf "\nUpdate retroarch32 to fix loading remap issues...\n" | tee -a "$LOG_FILE"
	mv -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.update11272020.bak | tee -a "$LOG_FILE"
	wget https://github.com/christianhaitian/arkos/raw/main/11272020/retroarch32 -O /opt/retroarch/bin/retroarch32 -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"

	printf "\nInstall Atari ST...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/hatari_libretro.so -O /home/ark/.config/retroarch/cores/hatari_libretro.so -a "$LOG_FILE"
	if [ ! -d "/home/ark/.hatari/" ]; then
		sudo mkdir -v /home/ark/.hatari | tee -a "$LOG_FILE"
		sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/hatari.cfg -O /home/ark/.hatari/hatari.cfg -a "$LOG_FILE"
		sudo chown -R -v ark:ark /home/ark/.hatari/ | tee -a "$LOG_FILE"	
	fi
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11272020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/es_systems.cfg -O /etc/emulationstation/es_systems.cfg -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/hatari_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/hatari_libretro.so | tee -a "$LOG_FILE"	
	if [ ! -d "/roms/atarist/" ]; then
		sudo mkdir -v /roms/atarist | tee -a "$LOG_FILE"
	fi

	printf "\nInstall lr-vitaquake2 core...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/vitaquake2_libretro.so -O /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so | tee -a "$LOG_FILE"
	if [ ! -d "/roms/ports/quake2" ]; then
		sudo mkdir -v /roms/ports/quake2 | tee -a "$LOG_FILE"
		sudo mkdir -v /roms/ports/quake2/baseq2 | tee -a "$LOG_FILE"
		sudo touch /roms/ports/quake2/baseq2/"PUT YOUR PAK FILES HERE" | tee -a "$LOG_FILE"
		sudo mkdir -v /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/ | tee -a "$LOG_FILE"
		sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/vitaQuakeII.rmp -O /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/vitaQuakeII.rmp -a "$LOG_FILE"
		sudo chown -R -v ark:ark /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/ | tee -a "$LOG_FILE"
		sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/Quake%202.sh -O /roms/ports/"Quake 2".sh -a "$LOG_FILE"		
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/emulationstation -O /home/ark/emulationstation -a "$LOG_FILE"
	sudo mv -fv /home/ark/emulationstation /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"

	printf "\nAdd Backup settings and Restore settings function to Options/Advance section...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/Backup%20Settings.sh -O /opt/system/Advanced/"Backup Settings".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/Restore%20Settings.sh -O /opt/system/Advanced/"Restore Settings".sh -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/Advanced/"Restore Settings".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/Advanced/"Restore Settings".sh | tee -a "$LOG_FILE"

	printf "\nAdd lr-puae as additional Amiga emulator...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/amiga.sh -O /usr/local/bin/amiga.sh -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/amiga.sh | tee -a "$LOG_FILE"

	printf "\nAdd standalone scummvm emulator...\n" | tee -a "$LOG_FILE"
	sudo apt update -y && sudo apt -y install liba52-0.7.4:armhf libcurl4:armhf libmad0:armhf libjpeg62:armhf libmpeg2-4:armhf libogg-dbg:armhf libvorbis0a:armhf libflac8:armhf libpnglite0:armhf libtheora0:armhf libfaad2:armhf libfluidsynth1:armhf libfreetype6:armhf libspeechd2:armhf  | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11292020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/es_systems.cfg -O /etc/emulationstation/es_systems.cfg -a "$LOG_FILE"	
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/scummvm.sh -O /usr/local/bin/scummvm.sh -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/scummvm | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/scummvm.ini -O /home/ark/.config/scummvm/scummvm.ini -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/scummvm.tar.gz -O /home/ark/scummvm.tar.gz -a "$LOG_FILE"
	sudo tar --same-owner -zxhvf /home/ark/scummvm.tar.gz -C / | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/scummvm.sh | tee -a "$LOG_FILE"
	sudo chmod -v 777 /home/ark/.config/scummvm/scummvm.ini | tee -a "$LOG_FILE"
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /home/ark/.config/scummvm/ | tee -a "$LOG_FILE"
	sudo rm -fv /home/ark/scummvm.tar.gz | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11292020/gamecontrollerdb.txt -O /opt/scummvm/extra/gamecontrollerdb.txt -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/scummvm/extra/gamecontrollerdb.txt | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "/home/ark/.config/.update11292020"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nRevert Dreamcast(lr-flycast-rumble), N64(lr-parallel-n64), and PSX (lr-pcsx-rearmed) cores to previous versions...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/flycast_rumble_libretro.so -O /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"

	printf "\nAdd support for Tic-80 emulator...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/tic80_libretro.so -O /home/ark/.config/retroarch/cores/tic80_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/tic80_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/tic80_libretro.so | tee -a "$LOG_FILE"	
	sudo mkdir -v /roms/tic80 | tee -a "$LOG_FILE"	

	printf "\nInstall updated themes from Jetup(nes-box, switch, epicnoir)..." | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es-theme-nes-box.zip -O /home/ark/es-theme-nes-box.zip -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es-theme-switch.zip -O /home/ark/es-theme-switch.zip -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es-theme-epicnoir.zip -O /home/ark/es-theme-epicnoir.zip -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-nes-box.zip -d /etc/emulationstation/themes/es-theme-nes-box/' | tee -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-switch.zip -d /etc/emulationstation/themes/es-theme-switch/' | tee -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-epicnoir.zip -d /etc/emulationstation/themes/es-theme-epicnoir/' | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-nes-box.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-switch.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-epicnoir.zip | tee -a "$LOG_FILE"	

	printf "\nUpdate es_systems.cfg to address platform name for famicom to nes and sfc to snes to fix scraping and add tic-80 support...\n" | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12012020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"

	printf "\nEnsure NDS performance hasn't been impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	
	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187
fi