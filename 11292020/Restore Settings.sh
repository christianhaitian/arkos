#!/bin/bash
clear

LOG_FILE="/roms/backup/lastarkosrestore.log"

printf "\033[0mRestoring a backup.  Please wait...\n"
sleep 2

sudo chmod 666 /dev/tty1
tail -f $LOG_FILE >> /dev/tty1 &

sudo tar --same-owner -zxhvf /roms/backup/arkosbackup.tar.gz -C / | tee -a "$LOG_FILE"
if [ $? -eq 0 ]; then
	printf "\n\n\e[32mThe restore completed successfuly. \nYou will need to reboot your system in order for your restored settings to take effect! \n" | tee -a "$LOG_FILE"
	printf "\033[0m" | tee -a "$LOG_FILE"
	sleep 10
else
	printf "\n\n\e[31mThe restore did NOT complete successfully! \n\e[33mVerify a valid arkosbackup.tar.gz exist in \nyour easyroms/backup folder then try again.\n" | tee -a "$LOG_FILE"
	printf "\033[0m" | tee -a "$LOG_FILE"
	sleep 10
fi