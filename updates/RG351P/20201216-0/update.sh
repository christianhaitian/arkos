#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12162020" ]; then
	
	printf "\nFix bad update for German, Spanish and French ES Menu entries...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /usr/bin/emulationstation/resources/locale/de/ | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/emulationstation2.po.de -O /usr/bin/emulationstation/resources/locale/de/emulationstation2.po -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/emulationstation2.po.es -O /usr/bin/emulationstation/resources/locale/es/emulationstation2.po -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/emulationstation2.po.fr -O /usr/bin/emulationstation/resources/locale/fr/emulationstation2.po -a "$LOG_FILE"

	printf "\nAdd update for a few themes to support Solarus and lzdoom system entry...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/es-theme-nes-box.zip -O /home/ark/es-theme-nes-box.zip -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-nes-box.zip -d /etc/emulationstation/themes/es-theme-nes-box/' | tee -a "$LOG_FILE"
	sudo rm -rfv /home/ark/es-theme-nes-box.zip | tee -a "$LOG_FILE"
	sudo rm -rfv /etc/emulationstation/themes/es-theme-switch/ | tee -a "$LOG_FILE"
	sudo rm -rfv /etc/emulationstation/themes/es-theme-epicnoir/ | tee -a "$LOG_FILE"
	sudo runuser -l ark -c "git clone --progress https://github.com/Jetup13/es-theme-switch /etc/emulationstation/themes/es-theme-switch/ 2> /dev/tty1"
	sudo runuser -l ark -c "git clone --progress https://github.com/Jetup13/es-theme-epicnoir /etc/emulationstation/themes/es-theme-epicnoir/ 2> /dev/tty1"

	printf "\nAdd lzdoom as default emulator for Doom wads for new location...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /roms/doom | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12162020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/lzdoom.tar.gz -O /home/ark/lzdoom.tar.gz -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/doom.sh -O /usr/local/bin/doom.sh -a "$LOG_FILE"
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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/solarus.tar.gz -O /home/ark/solarus.tar.gz "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/solarus.sh -O /usr/local/bin/solarus.sh "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12162020/solarushotkeydemon.py -O /usr/local/bin/solarushotkeydemon.py "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/solarus.sh | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/solarushotkeydemon.py | tee -a "$LOG_FILE"
	sudo tar --same-owner -zxvf /home/ark/solarus.tar.gz -C / | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/solarus.tar.gz | tee -a "$LOG_FILE"
fi
