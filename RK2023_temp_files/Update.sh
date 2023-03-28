#!/bin/bash

if [[ "$(stat -c "%U" /home/ark)" != "ark" ]]; then
  printf "Fixing home folder permissions.  Please wait..."
  sudo chown -R ark:ark /home/ark
  sudo chmod -R 755 /home/ark
fi

printf "\nChecking for updates.  Please wait..."

LOG_FILE="/home/ark/esupdate.log"

if [ -f "$LOG_FILE" ]; then
  sudo rm "$LOG_FILE"
fi

sudo timedatectl set-ntp 1

LOCATION="https://raw.githubusercontent.com/christianhaitian/arkos/main"
#BLOCATION="https://raw.githack.com/christianhaitian/arkos/main"
CLOCATION="http://139.196.213.206/arkos"

ISITCHINA=$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | grep -Po '"country":.*?[^\\]"')
if [ -z "$ISITCHINA" ]; then
  ISITCHINA=$(curl -s --connect-timeout 30 -m 60 https://api.iplocation.net/?ip=$(curl -s --connect-timeout 30 -m 60 checkip.amazonaws.com) | grep -Po '"country_name":.*?[^\\]"')
fi

#if [[ "$ISITCHINA" == "\"country\":\"China\"" ]] || [[ "$ISITCHINA" == "\"country_name\":\"China\"" ]]; then
#  printf "\n\nSwitching to China server for updates.\n\n" | tee -a "$LOG_FILE"
#  LOCATION="$CLOCATION"
#fi

if [[ "$LOCATION" != "$CLOCATION" ]]; then
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/LICENSE -O /dev/shm/LICENSE -a "$LOG_FILE"
  if [ $? -ne 0 ]; then
    LOCATION="$CLOCATION"
    wget -t 3 -T 60 --no-check-certificate "$LOCATION"/LICENSE -O /dev/shm/LICENSE -a "$LOG_FILE"
	if [ $? -ne 0 ]; then
      sudo msgbox "Looks like OTA updating is currently down or your wifi or internet connection is not functioning correctly."
      printf "There was an error with attempting this update." | tee -a "$LOG_FILE"
	  exit 1
    fi
  fi
fi

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  if [[ -e "/boot/rk3326-rg351v-linux.dtb" ]]; then
    sudo rg351p-js2xbox --silent -t oga_joypad &
    sleep 0.5
    sudo ln -s /dev/input/event4 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    sleep 0.5
    sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    export LD_LIBRARY_PATH=/usr/local/bin
    wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RG351V.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
  else
    sudo rg351p-js2xbox --silent -t oga_joypad &
    sleep 0.5
    sudo ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    sleep 0.5
    sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RG351P.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
    if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
	  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RGB10.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
	else
	  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RK2020.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
	fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]] && [ "$(cat ~/.config/.DEVICE)" == "RGB10MAX" ]; then
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RGB10MAX.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RG351MP.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]] && [ "$(cat ~/.config/.DEVICE)" == "RG353V" ]; then
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RG353V.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]] && [ "$(cat ~/.config/.DEVICE)" == "RG353M" ]; then
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RG353M.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]] && [ "$(cat ~/.config/.DEVICE)" == "RK2023" ]; then
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RK2023.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
elif [[ -e "/dev/input/by-path/platform-singleadc-joypad-event-joystick" ]]; then
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-RG503.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
else
  wget -t 3 -T 60 --no-check-certificate "$LOCATION"/Update-CHI.sh -O /home/ark/ArkOSUpdate.sh -a "$LOG_FILE"
fi

sudo chmod -v 777 /home/ark/ArkOSUpdate.sh | tee -a "$LOG_FILE"
sed -i "/LOCATION\=\"http:\/\/gitcdn.link\/cdn\/christianhaitian\/arkos\/main\"/c\LOCATION\=\"$LOCATION\"" /home/ark/ArkOSUpdate.sh
sed -i -e '/ISITCHINA\=/,+5d' /home/ark/ArkOSUpdate.sh
sh /home/ark/ArkOSUpdate.sh

if [ $? -ne 187 ]; then
  sudo msgbox "There was an error with attempting this update.  Did you make sure to enable your wifi and connect to a wifi network?  If so, enable remote services in options and try to update again."
  printf "There was an error with attempting this update." | tee -a "$LOG_FILE"
fi

if [ ! -z $(pidof rg351p-js2xbox) ]; then
  sudo kill -9 $(pidof rg351p-js2xbox)
  sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
fi
