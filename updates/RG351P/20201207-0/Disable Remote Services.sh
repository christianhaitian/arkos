#!/bin/bash
#sudo systemctl disable smbd.service
sudo timedatectl set-ntp 0
sudo systemctl stop smbd
sudo systemctl stop nmbd
#sudo systemctl disable nmbd.service
#sudo systemctl disable ssh
sudo systemctl stop ssh.service
sudo pkill filebrowser
printf "\n\n\n\e[32mRemote Services have been disabled.\n"
sleep 2