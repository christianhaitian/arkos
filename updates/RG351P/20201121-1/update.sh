#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update11212020-1" ]; then

	printf "\nUpdate platform name for SMS to mastersystem in es_systems.cfg to fix scraping...\n" | tee -a "$LOG_FILE"
	sudo sed -i '/platform>sms/c\\t\t<platform>mastersystem<\/platform>' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate retroarch to fix loading remap issues...\n" | tee -a "$LOG_FILE"
	mv -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	wget https://github.com/christianhaitian/arkos/raw/main/11212020-1/retroarch -O /opt/retroarch/bin/retroarch -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
fi
