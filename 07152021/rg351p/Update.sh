#!/bin/bash

sudo rg351p-js2xbox --silent -t oga_joypad &
sleep 1
sudo ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
sleep 1
sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick

LOG_FILE="/home/ark/esupdate.log"

if [ -f "$LOG_FILE" ]; then
  sudo rm "$LOG_FILE"
fi

sudo msgbox "ONCE YOU PROCEED WITH THIS UPDATE SCRIPT, DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT IN A STATE OF UNUSABILITY.  Make sure you've created a backup of this sd card as a precaution in case something goes very wrong with this process.  You've been warned!  Type OK in the next screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

if [[ $my_var = OK ]] || [[ $my_var = ok ]] ; then
  wget  https://raw.githubusercontent.com/wummle/arkos/main/Update-RG351P.sh -O /home/ark/TheraUpdate.sh -a "$LOG_FILE"
  sudo chmod -v 777 /home/ark/TheraUpdate.sh | tee -a "$LOG_FILE"
  sh /home/ark/TheraUpdate.sh
else
  sudo msgbox "You didn't type OK.  This script will exit now and no changes have been made from this process."
  printf "You didn't type OK.  This script will exit now and no changes have been made from this process." | tee -a "$LOG_FILE"
  sudo kill $(pidof rg351p-js2xbox)
  sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  exit 1
fi

if [ $? -ne 187 ]; then
  sudo msgbox "There was an error with attempting this update."
  printf "There was an error with attempting this update." | tee -a "$LOG_FILE"
fi

sudo kill $(pidof rg351p-js2xbox)
sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick