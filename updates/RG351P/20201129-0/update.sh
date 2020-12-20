#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

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
fi
