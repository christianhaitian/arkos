#!/bin/bash
clear
UPDATE_DATE="07312025"
LOG_FILE="/home/ark/update$UPDATE_DATE.log"
UPDATE_DONE="/home/ark/.config/.update$UPDATE_DATE"

if [ -f "$UPDATE_DONE" ]; then
	msgbox "No more updates available.  Check back later."
	rm -- "$0"
	exit 187
fi

if [ -f "$LOG_FILE" ]; then
	sudo rm "$LOG_FILE"
fi

LOCATION="http://gitcdn.link/cdn/christianhaitian/arkos/main"
ISITCHINA="$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | grep -Po '"country":.*?[^\\]"')"

if [ "$ISITCHINA" = "\"country\":\"China\"" ]; then
  printf "\n\nSwitching to China server for updates.\n\n" | tee -a "$LOG_FILE"
  LOCATION="http://139.196.213.206/arkos"
fi

sudo msgbox "ONCE YOU PROCEED WITH THIS UPDATE SCRIPT, DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT IN A STATE OF UNUSABILITY.  Make sure you've created a backup of this sd card as a precaution in case something goes very wrong with this process.  You've been warned!  Type OK in the next screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

if [ "$my_var" != "OK" ] && [ "$my_var" != "ok" ]; then
  sudo msgbox "You didn't type OK.  This script will exit now and no changes have been made from this process."
  printf "You didn't type OK.  This script will exit now and no changes have been made from this process." | tee -a "$LOG_FILE"
  rm -- "$0"
  exit 187
fi

c_brightness="$(cat /sys/class/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/class/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update03302025" ]; then

	printf "\nUpdate retrorun.cfg to fix analog stick\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/03302025/arkosupdate03302025.zip -O /dev/shm/arkosupdate03302025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate03302025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate03302025.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate03302025.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate03302025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate03302025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nUpdate retrorun.cfg to default swapped triggers to true for rk3326 devices and false for rk3566 devices\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  sed -i "/retrorun_swap_l1r1_with_l2r2 \=/c\retrorun_swap_l1r1_with_l2r2 \= true" /home/ark/.config/retrorun.cfg
	else
	  sed -i "/retrorun_swap_l1r1_with_l2r2 \=/c\retrorun_swap_l1r1_with_l2r2 \= false" /home/ark/.config/retrorun.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update03302025"

fi

if [ ! -f "/home/ark/.config/.update04302025" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.21.0\nUpdate Wifi.sh and importwifi.sh to support wpa3\nUpdate wifi_importer service\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04302025/arkosupdate04302025.zip -O /dev/shm/arkosupdate04302025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate04302025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate04302025.zip" ]; then
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04302025.bak
	  sudo unzip -X -o /dev/shm/arkosupdate04302025.zip -d / | tee -a "$LOG_FILE"
	  sudo systemctl daemon-reload
	  sudo rm -fv /dev/shm/arkosupdate04302025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate04302025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nMake sure the correct version of retrorun and retrorun32 are copied on the device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo rm -fv /usr/local/bin/retrorun-rk3326 | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/retrorun32-rk3326 | tee -a "$LOG_FILE"
	else
	  sudo cp -fv /usr/local/bin/retrorun-rk3326 /usr/local/bin/retrorun | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/retrorun32-rk3326 /usr/local/bin/retrorun32 | tee -a "$LOG_FILE"
	  sudo chmod 777 /usr/local/bin/retrorun*
	  sudo rm -fv /usr/local/bin/retrorun-rk3326 | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/retrorun32-rk3326 | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct es_systems.cfg depending on chipset\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  cp -fv /etc/emulationstation/es_systems.cfg.rk3326 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	else
	  rm -fv /etc/emulationstation/es_systems.cfg.rk3326 | tee -a "$LOG_FILE"
	fi

	if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
 	  printf "\nAccomodate for roms2 with new es_systems.cfg file...\n" | tee -a "$LOG_FILE"
	  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi
	chmod 777 /opt/retroarch/bin/*

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ] || [ -f "/boot/rk3326-batlexp-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3416928" ]; then
	    sudo cp -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  elif [ -f "/home/ark/.config/.DEVICE" ]; then
		sudo cp -fv /home/ark/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
	    sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  fi
	  if [ -f "/home/ark/.config/.DEVICE" ]; then
	    sudo cp -fv /home/ark/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  else
	    sudo cp -fv /home/ark/emulationstation.header /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  fi
	  sudo cp -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update04302025"

fi

if [ ! -f "/home/ark/.config/.update05312025" ]; then

	printf "\nUpdated ScummVM to version 2.9.1\nUpdated Hypseus-Singe 2.11.5\nUpdated Retrorun to version 2.7.7\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05312025/arkosupdate05312025.zip -O /dev/shm/arkosupdate05312025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate05312025.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05312025/arkosupdate05312025.z01 -O /dev/shm/arkosupdate05312025.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate05312025.z01 | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate05312025.zip" ] && [ -f "/dev/shm/arkosupdate05312025.z01" ]; then
	  zip -FF /dev/shm/arkosupdate05312025.zip --out /dev/shm/arkosupdate.zip -fz | tee -a "$LOG_FILE"
	  sudo unzip -X -o /dev/shm/arkosupdate.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate05312025.z* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate05312025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct scummvm for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/scummvm/scummvm.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/scummvm/scummvm.rk3326 /opt/scummvm/scummvm | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Hypseus-Singe for device and mv hypinput.ini to hypinput_gamepad.ini\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi
	if [ -f "/opt/hypseus-singe/hypinput.ini" ]; then
	  mv -fv /opt/hypseus-singe/hypinput.ini /opt/hypseus-singe/hypinput_gamepad.ini | tee -a "$LOG_FILE"
	fi

	printf "\nMake sure the correct version of retrorun and retrorun32 are copied on the device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo rm -fv /usr/local/bin/retrorun-rk3326 | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/retrorun32-rk3326 | tee -a "$LOG_FILE"
	else
	  sudo cp -fv /usr/local/bin/retrorun-rk3326 /usr/local/bin/retrorun | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/retrorun32-rk3326 /usr/local/bin/retrorun32 | tee -a "$LOG_FILE"
	  sudo chmod 777 /usr/local/bin/retrorun*
	  sudo rm -fv /usr/local/bin/retrorun-rk3326 | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/retrorun32-rk3326 | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update05312025"

fi

if [ ! -f "/home/ark/.config/.update06302025" ]; then

	printf "\nUpdate EasyRPG to 0.8.1.1\nUpdate liblcf to 0.8.1 for EasyRPG 0.8.1.1\nUpdate PPSSPP to 1.19.2\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06302025/arkosupdate06302025.zip -O /dev/shm/arkosupdate06302025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate06302025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate06302025.zip" ]; then
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06302025.bak
	  sudo unzip -X -o /dev/shm/arkosupdate06302025.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate06302025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate06302025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'bsnes' | tr -d '\0')"
	then
	  printf "\nAdd vbam and bsnes cores for Game Boy and Game boy color\n"
	  sed -i '/<core>tgbdual<\/core>/c\\t\t\t\t\t<core>tgbdual<\/core>\n\t\t\t\t\t<core>vbam<\/core>\n\t\t\t\t\t<core>bsnes<\/core>' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update06302025"

fi

if [ ! -f "/home/ark/.config/.update06302025-1" ]; then

	printf "\nFix PPSSPP 1.19.2\nRevert EasyRPG back to 0.8\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06302025-1/arkosupdate06302025-1.zip -O /dev/shm/arkosupdate06302025-1.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate06302025-1.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate06302025-1.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate06302025-1.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate06302025-1.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate06302025-1.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 (06302025)-1" /usr/share/plymouth/themes/text.plymouth
	echo "06302025" > /home/ark/.config/.VERSION

	touch "/home/ark/.config/.update06302025-1"

fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nAdd genesis_plus_gx_ex core for retroarch\nUpdate PPSSPP to 1.19.3\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07312025/arkosupdate07312025.zip -O /dev/shm/arkosupdate07312025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate07312025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate07312025.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate07312025.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate07312025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate07312025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'genesis_plus_gx_EX' | tr -d '\0')"
	then
	  printf "\nAdd genesis_plus_gx_EX retroarch core for Sega Genesis, Megadrive, Master System, GameGear and Sega CD\n"
	  sed -i '/<core>genesis_plus_gx<\/core>/c\\t\t\t\t\t<core>genesis_plus_gx<\/core>\n\t\t\t\t\t<core>genesis_plus_gx_EX<\/core>' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 (07312025)" /usr/share/plymouth/themes/text.plymouth
	echo "07312025" > /home/ark/.config/.VERSION

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187

fi