#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12122020" ]; then

	printf "\nAdd devolutionx(diablo) port support\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/devilution | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/ports/devilution | tee -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.local/share/diasurgical | tee -a "$LOG_FILE"
	sudo ln -s -v /roms/ports/devilution/ ~/.local/share/diasurgical/ | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/Devilutionx.sh -O /roms/ports/Devilutionx.sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/devilutionx -O /home/ark/.config/devilution/devilutionx -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/gamecontrollerdb.txt -O /roms/ports/devilution/gamecontrollerdb.txt -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/CharisSILB.ttf -O /usr/share/fonts/truetype/CharisSILB.ttf -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/libSDL2_mixer.a -O /usr/lib/arm-linux-gnueabihf/libSDL2_mixer.a -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/libSDL2_mixer-2.0.so.0.2.2 -O /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so | tee -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libSDL2_mixer-2.0.so.0.2.2 /usr/lib/arm-linux-gnueabihf/libSDL2_mixer.so | tee -a "$LOG_FILE"	
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/libmodplug.so.1.0.0 -O /usr/lib/arm-linux-gnueabihf/libmodplug.so.1.0.0 -a "$LOG_FILE"
	sudo ln -s -v /usr/lib/arm-linux-gnueabihf/libmodplug.so.1.0.0 /usr/lib/arm-linux-gnueabihf/libmodplug.so.1 | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/libopusfile.so.0.4.2 -O /usr/lib/arm-linux-gnueabihf/libopusfile.so.0.4.2 -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/libopusfile.a -O /usr/lib/arm-linux-gnueabihf/libopusfile.a -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/libopusurl.a -O /usr/lib/arm-linux-gnueabihf/libopusurl.a -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/libopusurl.so.0.4.2 -O /usr/lib/arm-linux-gnueabihf/libopusurl.so.0.4.2 -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12122020/Backup%20Settings.sh -O /opt/system/Advanced/"Backup Settings".sh -a "$LOG_FILE"
	sudo chmod -v 777 /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/system/Advanced/"Backup Settings".sh | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
fi
