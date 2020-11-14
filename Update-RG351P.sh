#!/bin/bash
clear

UPDATE_DATE="11142020"
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

if [ ! -f "$UPDATE_DONE" ]; then
	printf "\nFix the power led status...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/boot.ini -O /boot/boot.ini -a "$LOG_FILE"
	
	printf "\nAdd support for Rumble...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/addrumblesupport-crontab -O /home/ark/addrumblesupport-crontab -a "$LOG_FILE"	
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/enable_rumble -O /usr/local/bin/enable_rumble -a "$LOG_FILE"	
	sudo chmod -v 777 /usr/local/bin/enable_rumble | tee -a "$LOG_FILE"
	sudo crontab /home/ark/addrumblesupport-crontab
	printf "\nsudo crontab -e has been updated to:\n" | tee -a testlog.txt && sudo crontab -l | tee -a testlog.txt
	sudo rm -v /home/ark/addrumblesupport-crontab | tee -a "$LOG_FILE"
	
	printf "\nInstall lr-pcsx_rearmed core with rumble support...\n"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"	
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11142020/pcsx_rearmed_libretro.so.lck -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck -a "$LOG_FILE"	
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 644 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so.lck | tee -a "$LOG_FILE"

	touch "$UPDATE_DONE"
	msgbox "Updates have been completed.  For instructions on how to enable rumble in the pcsx_rearmed emulator, check Frequent Asked Questions RG351P #12 in the ArkOS wiki.  You're system will now reboot so the updates can take effect after you hit the A button."
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187
fi