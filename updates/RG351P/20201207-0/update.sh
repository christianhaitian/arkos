#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

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
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"

	printf "\nAdd support for the right analog stick to standalone ppsspp emulator and permission fix...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/PPSSPPSDL -O /opt/ppsspp/PPSSPPSDL -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/gamecontrollerdb.txt -O /opt/ppsspp/assets/gamecontrollerdb.txt -a "$LOG_FILE"
	sudo chmod -v 777 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/ppsspp/assets/gamecontrollerdb.txt | tee -a "$LOG_FILE"

	printf "\nAdd filebrowser web server...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/filebrowser -O /usr/local/bin/filebrowser -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/filebrowser.db -O /home/ark/.config/filebrowser.db -a "$LOG_FILE"
	sudo mkdir -v /home/ark/.config/img | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/logo.svg -O /home/ark/.config/img/logo.svg -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/filebrowser | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/filebrowser.db | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/img/logo.svg | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/Disable%20Remote%20Services.sh -O /opt/system/"Disable Remote Services".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/Enable%20Remote%20Services.sh -O /opt/system/"Enable Remote Services".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12072020/filebrowser -O /usr/local/bin/filebrowser -a "$LOG_FILE"
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
fi
