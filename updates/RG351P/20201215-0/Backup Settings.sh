#!/bin/bash
clear

LOG_FILE="/roms/backup/arkosbackup.log"
printf "\033[0mCreating a backup.  Please wait...\n"
sleep 2

if [ ! -d "/roms/backup/" ]; then
	sudo mkdir -v /roms/backup
fi
if [ -f "/roms/backup/arkosbackup.tar.gz" ]; then
	sudo rm /roms/backup/arkosbackup.tar.gz
fi
if [ -f "$LOG_FILE" ]; then
	sudo rm "$LOG_FILE"
fi

touch $LOG_FILE
sudo chmod 666 /dev/tty1
tail -f $LOG_FILE >> /dev/tty1 &

sudo tar -zchvf /roms/backup/arkosbackup.tar.gz /etc/localtime /etc/NetworkManager/system-connections /home/ark/.config/retroarch/retroarch.cfg /home/ark/.config/retroarch/config /home/ark/.config/retroarch32/retroarch.cfg /home/ark/.config/retroarch32/config /home/ark/.emulationstation/collections /home/ark/.emulationstation/es_settings.cfg /opt/amiberry/savestates /opt/amiberry/whdboot /opt/mupen64plus/InputAutoCfg.ini /opt/drastic/config/drastic.cfg | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
	printf "\n\n\e[32mThe backup completed successfuly. \nYour settings backup is located in the backup folder on the easyroms partition and is named arkosbackup.tar.gz. \nKeep it somewhere safe! \n"  | tee -a "$LOG_FILE"
	printf "\033[0m"  | tee -a "$LOG_FILE"
	sleep 10
else
	printf "\n\n\e[31mThe backup did NOT complete successfully! \n\e[33mVerify you have at least 1GB of space available on your easyroms partition then try again.\n" | tee -a "$LOG_FILE"
	printf "\033[0m" | tee -a "$LOG_FILE"
	sleep 10
fi