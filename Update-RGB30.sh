#!/bin/bash
clear
UPDATE_DATE="10162023"
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
  exit 187
fi

c_brightness="$(cat /sys/class/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/class/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update09212023" ]; then

	printf "\nUpdate quickmode to fix emulationstation not loading when exiting from quick mode loaded game\nUpdate quickmode script with fixes for rk3326 devices and certain emulators\nUpdated to PPSSPP 1.16.2\nUpdate ES with ability to change the power button function and to enable optional rumble motor for the RGB30\nAdd ppsspp default controls script to options/advanced section\nUpdate Hypseus-singe to 2.11.1\nFix typo in Disable Quick Mode script\nUpdate 351Files for RGB30\nUpdate Drastic settings restore script\nAdd wasm4 and thomson libretro emulators\nAdd symlink for .asoundrc for rk3566 devices\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212023/arkosupdate09212023.zip -O /dev/shm/arkosupdate09212023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09212023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09212023.zip" ]; then
      sudo unzip -X -o /dev/shm/arkosupdate09212023.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09212023.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09212023.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCheck if quickboot mode is enabled and if it is, replace quickmode.sh script and update finish script\n" | tee -a "$LOG_FILE"
	if [ -f "/opt/system/Advanced/Disable Quick Mode.sh" ]; then
	  printf " quickmode.sh has been udpated" | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/finish.sh.qm /usr/local/bin/finish.sh | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/pause.sh.qm /usr/local/bin/pause.sh | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/Disable\ Quick\ Mode.sh /opt/system/Advanced/Disable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	else
	  sudo rm -fv /usr/local/bin/quickmode.sh | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/Enable\ Quick\ Mode.sh /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/finish.sh.orig /usr/local/bin/finish.sh | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/pause.sh.orig /usr/local/bin/pause.sh | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Hypseus-Singe for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
	  if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	    if [ -z "$(grep "\-x 720" /usr/local/bin/daphne.sh | tr -d '\0')" ]; then
		  sudo sed -i '/-framefile/s//-x 720 -y 600 -framefile/' /usr/local/bin/daphne.sh
		fi
	    if [ -z "$(grep "\-x 720" /usr/local/bin/singe.sh | tr -d '\0')" ]; then
		  sudo sed -i '/-sound_buffer 2048 \\/s//-x 720 \\\n-y 600 \\\n-sound_buffer 2048 \\/' /usr/local/bin/singe.sh
		fi
	  fi
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3310416" ]; then
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

	printf "\nCopy correct fake08 for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/fake08/fake08.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/fake08/fake08.rk3326 /opt/fake08/fake08 | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate 351Files only if this device is a RGB30\n" | tee -a "$LOG_FILE"
	if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  cp -fv /opt/351Files/351Files.rgb30 /opt/351Files/351Files | tee -a "$LOG_FILE"
	  cp -fv /opt/351Files/351Files-sd2.rgb30 /opt/351Files/351Files-sd2 | tee -a "$LOG_FILE"
	  rm -fv /opt/351Files/351Files.rgb30 | tee -a "$LOG_FILE"
	  rm -fv /opt/351Files/351Files-sd2.rgb30 | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/351Files/351Files.rgb30 | tee -a "$LOG_FILE"
	  rm -fv /opt/351Files/351Files-sd2.rgb30 | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate sleep script to check if unit is loaded in quick mode when coming out of sleep\n" | tee -a "$LOG_FILE"
	if [ -z "$(grep "QBMODE" /usr/lib/systemd/system-sleep/sleep | tr -d '\0')" ]; then
	  sudo sed -i "/systemctl is-active --quiet emulationstation.service && echo ok || systemctl start emulationstation/c\    if [ ! -f \"\/dev\/shm\/QBMODE\" ]\; then\n      systemctl is-active --quiet emulationstation.service && echo ok || systemctl start emulationstation\n    fi" /usr/lib/systemd/system-sleep/sleep
	fi
	if [ -z "$(grep "JUSTWOKEUP" /usr/lib/systemd/system-sleep/sleep | tr -d '\0')" ]; then
	  if [ ! -f "/boot/rk3566.dtb" ] || [ ! -f "/boot/rk3566-OC.dtb" ]; then
	    sudo sed -i "/\/usr\/sbin\/alsactl store -f \/var\/local\/asound.state/c\\\t\/usr\/sbin\/alsactl store -f \/var\/local\/asound.state\n\tif [ -f \"\/usr\/local\/bin\/quickmode.sh\" ]\; then\n\t  touch \/dev\/shm\/.JUSTWOKEUP\n\tfi" /usr/lib/systemd/system-sleep/sleep
	  else
	    sudo sed -i "/\/usr\/sbin\/alsactl store -f \/var\/local\/asound.state/c\    \/usr\/sbin\/alsactl store -f \/var\/local\/asound.state\n    if [ -f \"\/usr\/local\/bin\/quickmode.sh\" ]\; then\n      touch \/dev\/shm\/.JUSTWOKEUP\n    fi" /usr/lib/systemd/system-sleep/sleep
	  fi
	fi

	printf "\nAdd wasm4 libretro emulator\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'wasm4' | tr -d '\0')"
	then
	  sed -i -e '/<theme>pico-8<\/theme>/{r /home/ark/add_wasm4.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	fi
	if [ ! -d "/roms/wasm4" ]; then
	  mkdir -v /roms/wasm4 | tee -a "$LOG_FILE"
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		if [ ! -d "/roms2/wasm4" ]; then
		  mkdir -v /roms2/wasm4 | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\/wasm4/s//<path>\/roms2\/wasm4/g' /etc/emulationstation/es_systems.cfg
		fi
	  fi
	fi
	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep wasm4 | tr -d '\0')"
	  then
		sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/wasm4\/" ]\; then\n      sudo mkdir \/roms2\/wasm4\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\nwasm4 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep wasm4 | tr -d '\0')"
	  then
		sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/wasm4\/" ]\; then\n      sudo mkdir \/roms2\/wasm4\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\nwasm4 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	rm -fv /home/ark/add_wasm4.txt | tee -a "$LOG_FILE"

	printf "\nAdd thomson libretro emulator\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'thomson' | tr -d '\0')"
	then
	  sed -i -e '/<theme>pico-8<\/theme>/{r /home/ark/add_thomson.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	fi
	if [ ! -d "/roms/thomson" ]; then
	  mkdir -v /roms/thomson | tee -a "$LOG_FILE"
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		if [ ! -d "/roms2/thomson" ]; then
		  mkdir -v /roms2/thomson | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\/thomson/s//<path>\/roms2\/thomson/g' /etc/emulationstation/es_systems.cfg
		fi
	  fi
	fi
	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep thomson | tr -d '\0')"
	  then
		sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/thomson\/" ]\; then\n      sudo mkdir \/roms2\/thomson\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\nthomson is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep thomson | tr -d '\0')"
	  then
		sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/thomson\/" ]\; then\n      sudo mkdir \/roms2\/thomson\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\nthomson is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	rm -fv /home/ark/add_thomson.txt | tee -a "$LOG_FILE"
	if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  mv -fv /home/ark/thomson.png /roms/themes/es-theme-sagabox/_art/logos/. | tee -a "$LOG_FILE"
	else
	  rm -fv /home/ark/thomson.png | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nCreate symlink /etc/asound.conf to /home/ark/.asoundrc\n" | tee -a "$LOG_FILE"
	  ln -sfv /home/ark/.asoundrc /etc/asound.conf | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09212023"

fi

if [ ! -f "/home/ark/.config/.update09232023" ]; then

	printf "\nAdd support to use USB DAC for rk3566 devices\nFix slowdown of ES scanning ports folder\nUpdate Fix Global Hotkeys script\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09232023/arkosupdate09232023.zip -O /dev/shm/arkosupdate09232023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09232023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09232023.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
        sudo unzip -X -o /dev/shm/arkosupdate09232023.zip -d / | tee -a "$LOG_FILE"
	  else
        sudo unzip -X -o /dev/shm/arkosupdate09232023.zip -x usr/local/bin/checknswitchforusbdac.sh -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate09232023.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09232023.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  #printf "\nUpdate emulationstation.sh scripts to check for existence of usb dacs and adjust asoundrc accordingly\n" | tee -a "$LOG_FILE"
	  #if test -z "$(cat /usr/bin/emulationstation/emulationstation.sh | grep controlC7 | tr -d '\0')"
	  #then
	    #sudo sed -i '/cp \/home\/ark\/.asoundrcbak \/home\/ark\/.asoundrc/s//cp \/home\/ark\/.asoundrcbak \/home\/ark\/.asoundrc\nif [ \! -e "\/dev\/snd\/controlC7" ]; then\n  sed -i \x27\/hw:[0-9]\/s\/\/hw:0\/\x27 \/home\/ark\/.asoundrc \/home\/ark\/.asoundrcbak\n  sed -i \x27\/AudioUSB\/d\x27 .emulationstation\/es_settings.cfg\nfi\n/' /usr/bin/emulationstation/emulationstation.sh*
	  #fi
	  printf "\nCreating 20-usb-alsa.rules udev for usb dac support\n" | tee -a "$LOG_FILE"
	  echo 'KERNEL=="controlC[0-9]*", DRIVERS=="usb", SYMLINK="snd/controlC7"' | sudo tee /etc/udev/rules.d/20-usb-alsa.rules | tee -a "$LOG_FILE"
	  printf "\nAdd check on boot for a connected usb dac\n" | tee -a "$LOG_FILE"
	  if test -z "$(sudo cat /var/spool/cron/crontabs/root | grep 'checknswitchforusbdac' | tr -d '\0')"
	  then
	    echo "@reboot /usr/local/bin/checknswitchforusbdac.sh &" | sudo tee -a /var/spool/cron/crontabs/root | tee -a "$LOG_FILE"
	  else
	    printf " USB Dac check script has already been added to crontab.  No need to do it again." | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3318608" ]; then
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

	touch "/home/ark/.config/.update09232023"

fi

if [ ! -f "/home/ark/.config/.update09242023" ]; then

	printf "\nUpdated USB DAC support for rk3566 devices\nUpdate quickboot scripts\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09242023/arkosupdate09242023.zip -O /dev/shm/arkosupdate09242023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09242023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09242023.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
        sudo unzip -X -o /dev/shm/arkosupdate09242023.zip -d / | tee -a "$LOG_FILE"
	  else
        sudo unzip -X -o /dev/shm/arkosupdate09242023.zip -x usr/local/bin/checknswitchforusbdac.sh -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate09242023.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09242023.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCheck if quickboot mode is enabled and if it is, replace quickmode.sh script and update finish script\n" | tee -a "$LOG_FILE"
	if [ -f "/opt/system/Advanced/Disable Quick Mode.sh" ]; then
	  printf " quickmode.sh has been udpated" | tee -a "$LOG_FILE"
	else
	  sudo rm -fv /usr/local/bin/quickmode.sh | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/Enable\ Quick\ Mode.sh /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	  sudo chown -v ark:ark /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09242023"

fi

if [ ! -f "/home/ark/.config/.update09292023" ]; then

	printf "\nUpdated USB DAC support for rk3566 devices\nUpdate emulationstation for last played collection update in quick mode and set brightness to 0 when in black screen saver\nUpdated PPSSPP to 1.16.5\nUpdate Enable and Disable quickboot mode scripts to set settings in retroarch default backup settings as well\nUpdate gzdoom to 4.11.0\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09292023/arkosupdate09292023.zip -O /dev/shm/arkosupdate09292023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09292023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09292023.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
        sudo unzip -X -o /dev/shm/arkosupdate09292023.zip -d / | tee -a "$LOG_FILE"
	  else
        sudo unzip -X -o /dev/shm/arkosupdate09292023.zip -x usr/local/bin/checknswitchforusbdac.sh -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate09292023.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09292023.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	#printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	#if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	#  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	#  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	#  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	#  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	#elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	#  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	#  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	#  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	#  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	#else
	#  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	#  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	#fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation depending on device\nUpdate quick mode script to improve ps1 reliability\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3318608" ]; then
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

	printf "\nCheck if quickboot mode is enabled and if it is, replace quickmode.sh script and update finish script\n" | tee -a "$LOG_FILE"
	if [ -f "/opt/system/Advanced/Disable Quick Mode.sh" ]; then
	  printf " quickmode.sh has been udpated" | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/Disable\ Quick\ Mode.sh /opt/system/Advanced/Disable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	  sed -i '/savestate_auto_save \=/c\savestate_auto_save \= \"true\"' /home/ark/.config/retroarch/retroarch.cfg.bak
	  sed -i '/savestate_auto_save \=/c\savestate_auto_save \= \"true\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	  sed -i '/savestate_auto_load \=/c\savestate_auto_load \= \"true\"' /home/ark/.config/retroarch/retroarch.cfg.bak
	  sed -i '/savestate_auto_load \=/c\savestate_auto_load \= \"true\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	  sed -i '/network_cmd_enable \=/c\network_cmd_enable \= \"true\"' /home/ark/.config/retroarch/retroarch.cfg.bak
	  sed -i '/network_cmd_enable \=/c\network_cmd_enable \= \"true\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	  sudo chmod -v 777 /opt/system/Advanced/Disable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	  sudo chown -v ark:ark /opt/system/Advanced/Disable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	else
	  sudo rm -fv /usr/local/bin/quickmode.sh | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/Enable\ Quick\ Mode.sh /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	  sudo chown -v ark:ark /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct gzdoom depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo rm -fv /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/gzdoom/gzdoom.chi /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
	  sudo rm -fv /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
	  cp -fv /opt/gzdoom/gzdoom.351v /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
	  sudo rm -fv /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
	else
	  cp -fv /opt/gzdoom/gzdoom.rk3326 /opt/gzdoom/gzdoom | tee -a "$LOG_FILE"
	  sudo rm -fv /opt/gzdoom/gzdoom.* | tee -a "$LOG_FILE"
	fi

	printf "\nRename videos folder to movies\n" | tee -a "$LOG_FILE"
	sudo mv -v /roms/videos/ /roms/movies/ | tee -a "$LOG_FILE"
	if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
	  sudo mv -v /roms2/videos/ /roms2/movies/ | tee -a "$LOG_FILE"
	fi
	sed -i '/\/videos\//s//\/movies\//' /etc/emulationstation/es_systems.cfg

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nRemoving PowerSaverMode setting from es_settings.cfg file if it exist for rk3566 devices\n" | tee -a "$LOG_FILE"
	  sed -i "/<string name\=\"PowerSaverMode\"/d " /home/ark/.emulationstation/es_settings.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09292023"

fi

if [ ! -f "/home/ark/.config/.update10062023" ]; then

	printf "\nUpdate wpa_supplicant to version 2.10\nUpdate Wifi script for rk3566 devices\nUpdated emulationstation for rk3566 devices\nUpdate Kodi to 20.2 for rk3566 devices\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10062023/arkosupdate10062023.zip -O /dev/shm/arkosupdate10062023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate10062023.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10062023/arkosupdate10062023.z01 -O /dev/shm/arkosupdate10062023.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate10062023.z01 | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate10062023.zip" ] && [ -f "/dev/shm/arkosupdate10062023.z01" ]; then
	  zip -FF /dev/shm/arkosupdate10062023.zip --out /dev/shm/arkosupdate.zip -fz | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate10062023.z* | tee -a "$LOG_FILE"
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
        sudo unzip -X -o /dev/shm/arkosupdate.zip -x home/ark/sdl2-64/libSDL2-2.0.so.0.2800.2.rk3326 home/ark/sdl2-32/libSDL2-2.0.so.0.2800.2.rk3326 -d / | tee -a "$LOG_FILE"
		if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ] || [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
		  sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' /opt/kodi/share/kodi/addons/skin.estuary/addon.xml
		else
		  echo "  This is not a RG353M, RG353V/VS, RGB30 or RK2023 unit so no modification to the esturary skin ui element size will be done here." | tee -a "$LOG_FILE"
		fi
	  else
        sudo unzip -X -o /dev/shm/arkosupdate.zip -x opt/system/Wifi.sh usr/bin/emulationstation/emulationstation "opt/kodi/*" -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if [ -f "/boot/rk3326-r35s-linux.dtb" ]; then
	  printf "\nInstall correct SDL 2.0.2800.2 (aka SDL 2.0.28.2) for R35s stock OS to fix rotated screen\n" | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.2800.2.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.2 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.2800.2.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2800.2 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.2 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2800.2 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	else
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	printf "\nUpdate NetworkManager\nDisable continous time syncing\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/apt/sources.list | grep 'deb http://ports.ubuntu.com/ubuntu-ports focal' | tr -d '\0')"
	then
	  echo 'deb http://ports.ubuntu.com/ubuntu-ports focal main universe' | sudo tee -a /etc/apt/sources.list
	fi
	sudo apt -y update | tee -a "$LOG_FILE"
	sudo apt -y install -t focal network-manager | tee -a "$LOG_FILE"
	sudo systemctl stop networkwatchdaemon
	sudo systemctl disable networkwatchdaemon
	sudo systemctl enable NetworkManager
	sudo systemctl start NetworkManager
	sudo systemctl disable systemd-timesyncd
	sudo systemctl disable apt-daily.timer
	sudo systemctl stop systemd-timesyncd
	sudo systemctl stop apt-daily.timer
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10062023"

fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate bluetooth watch script\nUpdate Wifi script and OSK\nUpdated wifion script\nUpdated PPSSPP to 1.16.6\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162023/arkosupdate10162023.zip -O /dev/shm/arkosupdate10162023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate10162023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate10162023.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
        if [ "$(cat ~/.config/.DEVICE)" = "RG503" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate10162023.zip -d / | tee -a "$LOG_FILE"
		  printf "\nCheck if quickboot mode is enabled and if it is, replace quickmode.sh script and update finish script\n" | tee -a "$LOG_FILE"
		  if [ -f "/opt/system/Advanced/Disable Quick Mode.sh" ]; then
		    printf " quickmode.sh has been udpated" | tee -a "$LOG_FILE"
		    sudo cp -fv /usr/local/bin/Disable\ Quick\ Mode.sh /opt/system/Advanced/Disable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
		    sed -i '/savestate_auto_save \=/c\savestate_auto_save \= \"true\"' /home/ark/.config/retroarch/retroarch.cfg.bak
		    sed -i '/savestate_auto_save \=/c\savestate_auto_save \= \"true\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
		    sed -i '/savestate_auto_load \=/c\savestate_auto_load \= \"true\"' /home/ark/.config/retroarch/retroarch.cfg.bak
		    sed -i '/savestate_auto_load \=/c\savestate_auto_load \= \"true\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
		    sed -i '/network_cmd_enable \=/c\network_cmd_enable \= \"true\"' /home/ark/.config/retroarch/retroarch.cfg.bak
		    sed -i '/network_cmd_enable \=/c\network_cmd_enable \= \"true\"' /home/ark/.config/retroarch32/retroarch.cfg.bak
		    sudo chmod -v 777 /opt/system/Advanced/Disable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
		    sudo chown -v ark:ark /opt/system/Advanced/Disable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
		  else
		    sudo rm -fv /usr/local/bin/quickmode.sh | tee -a "$LOG_FILE"
		    sudo cp -fv /usr/local/bin/Enable\ Quick\ Mode.sh /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
		    sudo chmod -v 777 /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
		    sudo chown -v ark:ark /opt/system/Advanced/Enable\ Quick\ Mode.sh | tee -a "$LOG_FILE"
		  fi
		else
		  sudo unzip -X -o /dev/shm/arkosupdate10162023.zip -x usr/local/bin/checknswitchforusbdac.sh usr/local/bin/quickmode.sh usr/local/bin/Enable\ Quick\ Mode.sh -d / | tee -a "$LOG_FILE"
		fi
	  else
        sudo unzip -X -o /dev/shm/arkosupdate10162023.zip -x opt/system/Wifi.sh opt/system/Advanced/wifion.sh usr/bin/osk usr/bin/msgbox usr/local/bin/watchforbtaudio.sh "opt/inttools/*" usr/local/bin/checknswitchforusbdac.sh usr/local/bin/quickmode.sh usr/local/bin/Enable\ Quick\ Mode.sh -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nClean up unneeded left over files in the Kodi folder from last udpate\n" | tee -a "$LOG_FILE"
	  find /opt/kodi/ -name *.19.* -exec rm {} \;
	  printf "\nInstall python3 urwid module\n" | tee -a "$LOG_FILE"
	  sudo apt -y update && sudo apt -y install -t eoan python3-urwid | tee -a "$LOG_FILE"
	fi

	printf "\nRemove Developer mode script from options>advanced section\n" | tee -a "$LOG_FILE"
	if [ -f /opt/system/Advanced/Enable\ Developer\ Mode.sh ]; then
	  sudo rm -fv /opt/system/Advanced/Enable\ Developer\ Mode.sh | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nRemove bionic and focal repositories to prevent future update issues\n" | tee -a "$LOG_FILE"
	sudo sed -i '/focal/d' /etc/apt/sources.list
	sudo sed -i '/bionic/d' /etc/apt/sources.list
	sudo apt -y update | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
	  LD_LIBRARY_PATH=/usr/local/bin msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	else
	  msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	fi
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187
fi