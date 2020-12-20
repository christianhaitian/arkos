#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

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
fi
