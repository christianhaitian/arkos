#!/bin/bash
clear
UPDATE_DATE="01312025"
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

if [ ! -f "/home/ark/.config/.update10162023" ]; then

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

	touch "/home/ark/.config/.update10162023"

fi

if [ ! -f "/home/ark/.config/.update11042023" ]; then

	printf "\nAdd ability to hide Kodi in emulationstation\nUpdate bluetooth script for rk3566 devices\nUpdate wifi script\nUpdate osk\nUpdate msgbox\nReplace wifi script, osk and msgbox on rk3326 devices\nUpdate ogage for rk3326 devices\nUpdated extlinux.conf file\nUpdate pico8.sh script\nUpdate volume.sh file for rk3566 devices\nUpdate spktoggle.sh for powkiddy rk3566 devices\nUpdate rk3566 kernel to support double buffering and disable some unneeded control groups\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11042023/arkosupdate11042023.zip -O /dev/shm/arkosupdate11042023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate11042023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate11042023.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	    if [ "$(cat ~/.config/.DEVICE)" = "RGB30" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ]; then
	      sudo unzip -X -o /dev/shm/arkosupdate11042023.zip -d / | tee -a "$LOG_FILE"
		else
	      sudo unzip -X -o /dev/shm/arkosupdate11042023.zip -x usr/local/bin/spktoggle.sh -d / | tee -a "$LOG_FILE"
		fi
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate11042023.zip -x home/ark/Image.* opt/system/Bluetooth.sh usr/bin/emulationstation/emulationstation boot/extlinux/extlinux.conf usr/local/bin/volume.sh -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
	  printf "\nRemoving second scummvm install\n" | tee -a "$LOG_FILE"
	  sed -i "/mv -fv \/opt\/scummvm/s//#mv -fv \/opt\/scummvm/" /opt/system/Advanced/"Enable Experimental Touch support".sh
	  sed -i "/mv -fv \/opt\/scummvm/s//#mv -fv \/opt\/scummvm/" /opt/system/Advanced/"Disable Experimental Touch support".sh
	  sudo sed -i "/mv -fv \/opt\/scummvm/s//#mv -fv \/opt\/scummvm/" /usr/local/bin/experimental/"Enable Experimental Touch support".sh
	  sudo sed -i "/mv -fv \/opt\/scummvm/s//#mv -fv \/opt\/scummvm/" /usr/local/bin/experimental/"Disable Experimental Touch support".sh
	  sed -i "/cp -fv \/opt\/retroarch\/bin\/retroarch/s//#cp -fv \/opt\/retroarch\/bin\/retroarch/" /opt/system/Advanced/"Enable Experimental Touch support".sh
	  sed -i "/cp -fv \/opt\/retroarch\/bin\/retroarch/s//#cp -fv \/opt\/retroarch\/bin\/retroarch/" /opt/system/Advanced/"Disable Experimental Touch support".sh
	  sudo sed -i "/cp -fv \/opt\/retroarch\/bin\/retroarch/s//#cp -fv \/opt\/retroarch\/bin\/retroarch/" /usr/local/bin/experimental/"Enable Experimental Touch support".sh
	  sudo sed -i "/cp -fv \/opt\/retroarch\/bin\/retroarch/s//#cp -fv \/opt\/retroarch\/bin\/retroarch/" /usr/local/bin/experimental/"Disable Experimental Touch support".sh
	  if [ -d "/opt/scummvm.orig" ]; then
	    sudo rm -rfv /opt/scummvm.orig | tee -a "$LOG_FILE"
	  elif [ -d "/opt/scummvm.touch" ]; then
	    sudo rm -rfv /opt/scummvm | tee -a "$LOG_FILE"
		sudo mv -fv /opt/scummvm.touch/ /opt/scummvm/ | tee -a "$LOG_FILE"
		sudo chown -Rv ark:ark /opt/scummvm/ | tee -a "$LOG_FILE"
	  fi
	fi

	if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
	  sudo rm -fv /usr/local/bin/msgbox | tee -a "$LOG_FILE"
	fi

	if [ -f "/opt/system/Advanced/Backup Settings.sh" ]; then
	  sudo rm -fv /opt/system/Advanced/"Backup Settings.sh" | tee -a "$LOG_FILE"
	  sudo rm -fv /opt/system/Advanced/"Restore Settings.sh" | tee -a "$LOG_FILE"
	fi

	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
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

	printf "\nCopy correct updated ogage depending on device\n" | tee -a "$LOG_FILE"
	sudo systemctl stop oga_events
	if [ "$(cat ~/.config/.DEVICE)" = "RGB30" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ]; then
	  sudo cp -fv /home/ark/ogage-rk2023 /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
	elif [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
	  sudo cp -fv /home/ark/ogage-rg353v /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
	elif [ "$(cat ~/.config/.DEVICE)" = "RG503" ]; then
	  sudo cp -fv /home/ark/ogage-rg503 /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
	elif [ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]; then
	  sudo cp -fv /home/ark/ogage-rg351v /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
	elif [ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]; then
		if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000" | tr -d '\0')" ]; then
			sudo cp -fv /home/ark/ogage-rgb10 /usr/local/bin/ogage | tee -a "$LOG_FILE"
			sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
		else
			sudo cp -fv /home/ark/ogage-rk2020 /usr/local/bin/ogage | tee -a "$LOG_FILE"
			sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
		fi
	elif [ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]; then
		if [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
			sudo cp -fv /home/ark/ogage-rgb10max /usr/local/bin/ogage | tee -a "$LOG_FILE"
			sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
		else
			sudo cp -fv /home/ark/ogage-rg351mp /usr/local/bin/ogage | tee -a "$LOG_FILE"
			sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
		fi
	elif [ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]; then
		sudo cp -fv /home/ark/ogage-gameforce-chi /usr/local/bin/ogage | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
	else
	    sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
	fi
	sudo systemctl start oga_events

	if [ "$(cat ~/.config/.DEVICE)" = "RGB30" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ]; then
	  printf "\nMaking sure this unit is not muted in case it was done accidently and user is unaware of the hotkey to unmute it\n" | tee -a "$LOG_FILE"
	  amixer -q sset 'Playback Path' HP
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	  if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
	    sudo mv -fv /home/ark/Image.353 /boot/Image | tee -a "$LOG_FILE"
	    sudo rm -fv /home/ark/Image.* | tee -a "$LOG_FILE"
	  elif [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
        sudo mv -fv /home/ark/Image.rgb30 /boot/Image | tee -a "$LOG_FILE"
	    sudo rm -fv /home/ark/Image.* | tee -a "$LOG_FILE"
	  elif [ "$(cat ~/.config/.DEVICE)" = "RK2023" ]; then
        sudo mv -fv /home/ark/Image.rk2023 /boot/Image | tee -a "$LOG_FILE"
	    sudo rm -fv /home/ark/Image.* | tee -a "$LOG_FILE"
	  else
        sudo mv -fv /home/ark/Image.503 /boot/Image | tee -a "$LOG_FILE"
	    sudo rm -fv /home/ark/Image.* | tee -a "$LOG_FILE"
	  fi
	fi

	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nInstall python3 urwid module\n" | tee -a "$LOG_FILE"
	  sudo apt -y update && sudo apt -y install -t eoan python3-urwid | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nVerify old abandoned bluetooth settings are deleted\n" | tee -a "$LOG_FILE"
	  sudo rm -rfv /var/lib/bluetooth/* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11042023"

fi

if [ ! -f "/home/ark/.config/.update12082023" ]; then

	printf "\nUpdate Emulationstation to add Update Games list option to gamelist menu\nUpdate Emulationstation to not show hidden folders\nFix restore default settings scripts for GZdoom and LZdoom\nUpdate NetworkManager to 1.44.2\nUpdate 8821cs.conf file\nAdd missing inputstream.adaptive addon for Kodi 20.2\nAdd workaround for possible audio disappearing issue\nUpdate buttonmon.sh to add r1,r2,l1,l2 buttons\nAdd ability to delete auto savestates during quick mode boot\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12082023/arkosupdate12082023.zip -O /dev/shm/arkosupdate12082023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate12082023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate12082023.zip" ]; then
	  if [ "$(cat ~/.config/.DEVICE)" = "RGB30" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ]; then
	    sudo unzip -X -o /dev/shm/arkosupdate12082023.zip -d / | tee -a "$LOG_FILE"
	  elif [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	    sudo unzip -X -o /dev/shm/arkosupdate12082023.zip -x usr/local/bin/volume.sh -d / | tee -a "$LOG_FILE"
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate12082023.zip -x usr/local/bin/volume.sh "opt/kodi/*" -d / | tee -a "$LOG_FILE"
	  fi
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12082023.bak | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nInstall some local netplay hosting needed services\n" | tee -a "$LOG_FILE"
	sudo apt update -y && sudo apt -y -o Dpkg::Options::="--force-confold" install dnsmasq ed hostapd sshpass | tee -a "$LOG_FILE"
	sudo systemctl unmask hostapd.service
	sudo systemctl disable hostapd.service
	sudo systemctl disable dnsmasq.service
	sudo systemctl daemon-reload

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

	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'sameboy' | tr -d '\0')"
	then
	  printf "\nAdd sameboy core for Game Boy and Game boy color\n"
	  sed -i '/<core>tgbdual<\/core>/c\\t\t\t  <core>sameboy<\/core>\n\t\t\t  <core>tgbdual<\/core>' /etc/emulationstation/es_systems.cfg
	fi

	#if test -z "$(grep "<manufacturer>" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	#then
	#  printf "\nBackup and update es_systems.cfg for new sorting and go to function\n"
	#  ed /etc/emulationstation/es_systems.cfg < /home/ark/es_man_year_hardware.txt | tee -a "$LOG_FILE"
	#  sudo rm -rf /home/ark/es_man_year_hardware.txt | tee -a "$LOG_FILE"
	#fi

	if test -z "$(cat /usr/bin/emulationstation/emulationstation.sh | grep 'Backup' | tr -d '\0')"
	then
	  printf "\nAdd Backup and Restore ArkOS settings to BaRT\n" | tee -a "$LOG_FILE"
	  sudo sed -i "/\"7)\"/s//\"9)\"/" /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.ra /usr/bin/emulationstation/emulationstation.sh.es
	  sudo sed -i "/\"6)\"/s//\"8)\"/" /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.ra /usr/bin/emulationstation/emulationstation.sh.es
	  sudo sed -i "/\"5)\" \"351Files\"/s//\"5)\" \"351Files\"\n                  \"6)\" \"Backup ArkOS Settings\"\n                  \"7)\" \"Restore ArkOS Settings\"/" /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.ra /usr/bin/emulationstation/emulationstation.sh.es
	  sudo sed -i "/\"8)\") sudo reboot/s//\"6)\") sudo kill -9 \$(pidof boot_controls)\n                                \/opt\/system\/Advanced\/\"Backup ArkOS Settings.sh\" 2>\&1 > \/dev\/tty1\n                                sudo .\/boot_controls none \$param_device \&\n                                ;;\n                          \"7)\") sudo kill -9 \$(pidof boot_controls)\n                                \/opt\/system\/Advanced\/\"Restore ArkOS Settings.sh\" 2>\&1 > \/dev\/tty1\n                                sudo .\/boot_controls none \$param_device \&\n                                ;;\n                          \"8)\") sudo reboot/" /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.ra /usr/bin/emulationstation/emulationstation.sh.es
	fi

	if [ ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')" ] || [ ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  if [ -z "$(grep 'event_num="4"' /usr/bin/emulationstation/emulationstation.sh | tr -d '\0')" ]; then
	    printf "\nFix access to BarT when touch support is enabled...\n" | tee -a "$LOG_FILE"
	    if [ -f "/opt/system/Advanced/Enable Experimental Touch support.sh" ]; then
	      cp -fv /usr/local/bin/experimental/Enable\ Experimental\ Touch\ support.sh /opt/system/Advanced/Enable\ Experimental\ Touch\ support.sh | tee -a "$LOG_FILE"
	    else
	      sudo sed -i "0,/event_num=\"3\"/s//event_num=\"4\"/" /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.ra /usr/bin/emulationstation/emulationstation.sh.es
	      cp -fv /usr/local/bin/experimental/Disable\ Experimental\ Touch\ support.sh /opt/system/Advanced/Disable\ Experimental\ Touch\ support.sh | tee -a "$LOG_FILE"
	    fi
	  fi
	else
	  if [ -d "/usr/local/bin/experimental" ]; then
	    sudo rm -rfv /usr/local/bin/experimental/
	  fi
	fi

	printf "\nRemoving settings in emulationstation.sh that can be impacting .asoundrc being inadvertently deleted\n" | tee -a "$LOG_FILE"
	sudo sed -i '/sudo chown ark:ark/d' /usr/bin/emulationstation/emulationstation.sh*
	sudo sed -i '/cp \/home\/ark\/.asoundrcbak/d' /usr/bin/emulationstation/emulationstation.sh*

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12082023"

fi

if [ ! -f "/home/ark/.config/.update12152023" ]; then

	printf "\nAdd ep128emu and update default theme\nFix emulationstation not showing folders containing dots within the name but not at the beginning\nFix osk, msgbox and Wifi.sh for 480x320 devices\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12152023/arkosupdate12152023.zip -O /dev/shm/arkosupdate12152023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate12152023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate12152023.zip" ]; then
	  if [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
	    sudo unzip -X -o /dev/shm/arkosupdate12152023.zip -x "roms/themes/es-theme-nes-box/*" -d / | tee -a "$LOG_FILE"
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate12152023.zip -x "roms/themes/es-theme-sagabox/*" -d / | tee -a "$LOG_FILE"
	  fi
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep ep128emu)"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12152023.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>pico-8<\/theme>/{r /home/ark/add_ep128emu.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/enterprise" ]; then
	    mkdir -v /roms/enterprise | tee -a "$LOG_FILE"
	  fi
	  if [ ! -d "/roms/tvc" ]; then
	    mkdir -v /roms/tvc | tee -a "$LOG_FILE"
	  fi
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
	    if [ ! -d "/roms2/enterprise" ]; then
	  	  mkdir -v /roms2/enterprise | tee -a "$LOG_FILE"
	  	  sed -i '/<path>\/roms\/enterprise/s//<path>\/roms2\/enterprise/g' /etc/emulationstation/es_systems.cfg
	    fi
	    if [ ! -d "/roms2/tvc" ]; then
	  	  mkdir -v /roms2/tvc | tee -a "$LOG_FILE"
	  	  sed -i '/<path>\/roms\/tvc/s//<path>\/roms2\/tvc/g' /etc/emulationstation/es_systems.cfg
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep enterprise | tr -d '\0')"
	    then
	  	  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
	  	  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/enterprise\/" ]\; then\n      sudo mkdir \/roms2\/enterprise\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
	  	  printf "\nEnterprise 64/128 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep tvc | tr -d '\0')"
	    then
	  	  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
	  	  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/tvc\/" ]\; then\n      sudo mkdir \/roms2\/tvc\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
	  	  printf "\nVideoton TV Computer is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep enterprise | tr -d '\0')"
	    then
	  	  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/enterprise\/" ]\; then\n      sudo mkdir \/roms2\/enterprise\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
	  	  printf "\nEnterprise 64/128 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep tvc | tr -d '\0')"
	    then
	  	  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/tvc\/" ]\; then\n      sudo mkdir \/roms2\/tvc\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
	  	  printf "\nVideoton TV Computer is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  sudo rm -fv /home/ark/add_ep128emu.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3339088" ]; then
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

	if test ! -z "$(cat /usr/bin/emulationstation/emulationstation.sh | grep 'setfont' | tr -d '\0')"
	then
	  printf "\nFix plymouth ArkOS version changing font during boot up\n"
	  sudo sed -i '/sudo setfont \/usr\/share\/consolefonts\/Lat7-Terminus20x10.psf.gz/c\' /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.es /usr/bin/emulationstation/emulationstation.sh.ra
	  if [ "$(cat /usr/bin/emulationstation/emulationstation.sh | grep '033c' | tr -d '\0' | wc -l)" = "3" ]; then
	    sudo sed -i '0,/printf \"\\033c\" > \/dev\/tty1/s///' /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.es /usr/bin/emulationstation/emulationstation.sh.ra
	    sudo sed -i '/sudo \/bin\/plymouth hide-splash/c\  sudo \/bin\/plymouth hide-splash\n  printf \"\\033c\" \> \/dev\/tty1\n  sudo setfont \/usr\/share\/consolefonts\/Lat7-Terminus20x10.psf.gz' /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.es /usr/bin/emulationstation/emulationstation.sh.ra
	  else
	    sudo sed -i '/sudo \/bin\/plymouth hide-splash/c\  sudo \/bin\/plymouth hide-splash\n  sudo setfont \/usr\/share\/consolefonts\/Lat7-Terminus20x10.psf.gz' /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.es /usr/bin/emulationstation/emulationstation.sh.ra
	  fi
	elif [ "$(cat /usr/bin/emulationstation/emulationstation.sh | grep '033c' | tr -d '\0' | wc -l)" = "3" ]; then
	  sudo sed -i '0,/printf \"\\033c\" > \/dev\/tty1/s///' /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.es /usr/bin/emulationstation/emulationstation.sh.ra
	  sudo sed -i '/sudo \/bin\/plymouth hide-splash/c\  sudo \/bin\/plymouth hide-splash\n  printf \"\\033c\" \> \/dev\/tty1' /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.es /usr/bin/emulationstation/emulationstation.sh.ra
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12152023"

fi

if [ ! -f "/home/ark/.config/.update12222023" ]; then

	printf "\nUpdate emulationstation to add performance governor control per system and game\nUpdated emulationstation to fix game counter for hidden games\nUpdate perfmax scripts\nUpdate Kodi script to fix OS volume controls\nUpdate sleep_governors script\nUpdate quick mode scripts\nUpdate wifioff, wifion, Wifi scripts\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12222023/arkosupdate12222023.zip -O /dev/shm/arkosupdate12222023.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate12222023.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate12222023.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	    sudo unzip -X -o /dev/shm/arkosupdate12222023.zip -d / | tee -a "$LOG_FILE"
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate12222023.zip -x usr/local/bin/sleep_governors.sh usr/local/bin/Kodi.sh opt/system/Advanced/wifioff.sh opt/system/Advanced/wifion.sh opt/system/Wifi.sh -d / | tee -a "$LOG_FILE"
	  fi
	  if test ! -z "$(grep "sudo perfmax %EMULATOR% %CORE%" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	  then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12222023.bak | tee -a "$LOG_FILE"
		sed -i 's/sudo perfmax \%EMULATOR\% \%CORE\%/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
		sed -i 's/sudo perfmax \%EMULATOR\% \%ROM\%/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
		sed -i 's/sudo perfmax On/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
		sed -i 's/sudo perfmax retroarch mametiger/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
		sed -i 's/sudo perfmax retroarch same_cdi/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
		sed -i 's/sudo perfmax retroarch opera/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
		sed -i 's/sudo perfmax mvem/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
		sed -i 's/<command>\%ROM\%<\/command>/<command>sudo perfmax \%GOVERNOR\%; \%ROM\%; sudo perfnorm<\/command>/' /etc/emulationstation/es_systems.cfg
		sed -i 's/sudo perfmax;/sudo perfmax \%GOVERNOR\%;/' /etc/emulationstation/es_systems.cfg
		sed -i 's/<name>Options<\/name>/<name>options<\/name>/' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ -f "/opt/system/Switch Launchimage to jpg.sh" ]; then
	    sudo cp -fv /usr/local/bin/perfmax.asc /usr/local/bin/perfmax | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3339088" ]; then
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

	printf "\nCheck if quickboot mode is enabled and if it is, replace quickmode.sh script\n" | tee -a "$LOG_FILE"
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

	touch "/home/ark/.config/.update12222023"

fi

if [ ! -f "/home/ark/.config/.update01272024" ]; then

	printf "\nWifi and Bluetooth scripts to fix screen corruption\nAdd Mu libretro core\nUpdate netplay script to fix screen corruption\nUpdate emulationstation\nAdded uae4arm for retroarch 64bit\nAdd missing stark_shader_fill shader files\nUpdate scummvm.sh and scan for new games for scummvm\nUpdated Amiberry to 5.6.5\nAdd files for libretro scummvm\nUpdate solarus.sh\nUpdate filebrowser to 2.26.0\nUpdate speak_bat_life.sh\nFix governor setting for virtualjaguar system\nAdd PPSSPP-2021 emulator\nUpdate Kodi to 20.3\nUpdate nes-box theme\nAdd TRS-80 support\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	tmp_mem_size=$(df -h /dev/shm | grep shm | awk '{print $2}' | cut -d 'M' -f1)
	if [ ${tmp_mem_size} -lt 450 ]; then
	  printf "\nTemporarily raising temp memory storage for this large update\n" | tee -a "$LOG_FILE"
	  sudo mount -o remount,size=450M /dev/shm
	fi
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01272024/arkosupdate01272024.zip -O /dev/shm/arkosupdate01272024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01272024.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01272024/arkosupdate01272024.z01 -O /dev/shm/arkosupdate01272024.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01272024.z01 | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate01272024.zip" ] && [ -f "/dev/shm/arkosupdate01272024.z01" ]; then
	  zip -FF /dev/shm/arkosupdate01272024.zip --out /dev/shm/arkosupdate.zip -fz | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate01272024.z* | tee -a "$LOG_FILE"
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	    rm -rfv /opt/kodi/lib/kodi/addons/* /opt/kodi/share/kodi/addons/* /opt/kodi/lib/addons/* /opt/kodi/lib/pkgconfig/* /opt/kodi/lib/libdumb.a | tee -a "$LOG_FILE"
	    if test ! -z "$(grep "RG353" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo unzip -X -o /dev/shm/arkosupdate.zip -x "opt/amiberry/*" "roms/themes/es-theme-sagabox/*" -d / | tee -a "$LOG_FILE"
	      printf "\nUpdating dtb files in the boot partition to support touchscreen and emmc if applicable\n" | tee -a "$LOG_FILE"
		  if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	      then
	           sudo cp -fv /home/ark/353/rk3566-353v.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	           sudo cp -fv /home/ark/353/rk3566-353v-notimingchange.dtb /boot/rk3566-OC.dtb.bright | tee -a "$LOG_FILE"
		  elif test ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')"
	      then
	           sudo cp -fv /home/ark/353/rk3566-353m.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	           sudo cp -fv /home/ark/353/rk3566-353m-notimingchange.dtb /boot/rk3566-OC.dtb.bright | tee -a "$LOG_FILE"
		  fi
	      sudo rm -rfv /home/ark/353/ | tee -a "$LOG_FILE"
		elif [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate.zip -x "opt/amiberry/*" "home/ark/353/*" "roms/themes/es-theme-nes-box/*" -d / | tee -a "$LOG_FILE"
		else
	      sudo unzip -X -o /dev/shm/arkosupdate.zip -x "opt/amiberry/*" "home/ark/353/*" "roms/themes/es-theme-sagabox/*" -d / | tee -a "$LOG_FILE"
		fi
	    #Remove experimental touch scripts as touch is enabled by default now
		if [ -f "/opt/system/Advanced/Enable Experimental Touch support.sh" ]; then
	      sudo rm -fv /opt/system/Advanced/Enable\ Experimental\ Touch\ support.sh | tee -a "$LOG_FILE"
		fi
		if [ -f "/opt/system/Advanced/Disable Experimental Touch support.sh" ]; then
	      sudo rm -fv /opt/system/Advanced/Disable\ Experimental\ Touch\ support.sh | tee -a "$LOG_FILE"
		fi
		if [ -d "/usr/local/bin/experimental" ]; then
	      sudo rm -Rfv /usr/local/bin/experimental/ | tee -a "$LOG_FILE"
		fi
	    if test -z "$(grep 'platform-fe5b0000.i2c-event' /usr/bin/emulationstation/emulationstation.sh | tr -d '\0')"
		then
	         #Fix BaRT
	         sudo sed -i 's/event_num=\"3\"/if [[ -e \"\/dev\/input\/by-path\/platform-fe5b0000.i2c-event\" ]]; then\n  event_num=\"4\"\nelse\n  event_num=\"3\"\nfi/g' /usr/bin/emulationstation/emulationstation.sh*
	    fi
		if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ] || [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
		  sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' /opt/kodi/share/kodi/addons/skin.estuary/addon.xml
		else
		  echo "  This is not a RG353M, RG353V/VS, RGB30 or RK2023 unit so no modification to the esturary skin ui element size will be done here." | tee -a "$LOG_FILE"
		fi
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate.zip -x opt/system/Bluetooth.sh "home/ark/353/*" "usr/local/bin/*keydemon.py" "opt/kodi/*" "roms/themes/es-theme-sagabox/*" -d / | tee -a "$LOG_FILE"
	  fi
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
	    install -Dv /roms/scummvm/Scan_for_new_games.scummvm /roms2/scummvm/Scan_for_new_games.scummvm | tee -a "$LOG_FILE"
	    install -Dv /roms/bios/scummvm/theme/gui-icons.dat /roms2/bios/scummvm/theme/gui-icons.dat | tee -a "$LOG_FILE"
	    install -Dv /roms/bios/scummvm/theme/residualvm.zip /roms2/bios/scummvm/theme/residualvm.zip | tee -a "$LOG_FILE"
	    install -Dv /roms/bios/scummvm/theme/shaders.dat /roms2/bios/scummvm/theme/shaders.dat | tee -a "$LOG_FILE"
	    install -Dv /roms/bios/scummvm/theme/translations.dat /roms2/bios/scummvm/theme/translations.dat | tee -a "$LOG_FILE"
	    install -Dv /roms/bios/mame/hash/coco* /roms2/bios/mame/hash/. | tee -a "$LOG_FILE"
	  fi
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01272024.bak | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'standalone-2021' | tr -d '\0')"
	  then
	    sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>psp<\/platform>)/   <emulator name=\"\standalone-2021\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
	  fi
	  printf "\nAdd palm libretro emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'palm' | tr -d '\0')"
	  then
	    sed -i -e '/<theme>pico-8<\/theme>/{r /home/ark/add_palm.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/palm" ]; then
	    mkdir -v /roms/palm | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/palm" ]; then
		    mkdir -v /roms2/palm | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/palm/s//<path>\/roms2\/palm/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep palm | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/palm\/" ]\; then\n      sudo mkdir \/roms2\/palm\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npalm is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep palm | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/palm\/" ]\; then\n      sudo mkdir \/roms2\/palm\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npalm is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  printf "\nAdd coco3 libretro emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'coco3' | tr -d '\0')"
	  then
	    sed -i -e '/<theme>thomson<\/theme>/{r /home/ark/add_coco3.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/coco3" ]; then
	    mkdir -pv /roms/coco3/controls | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/coco3" ]; then
		    mkdir -pv /roms2/coco3/controls | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/coco3/s//<path>\/roms2\/coco3/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep coco3 | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/coco3\/" ]\; then\n      sudo mkdir \/roms2\/coco3\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\ncoco3 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep coco3 | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/coco3\/" ]\; then\n      sudo mkdir \/roms2\/coco3\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\ncoco3 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/etc/emulationstation/es_systems.cfg.update01272024.bak" ]; then
		sed -i 's/<core>puae<\/core>/<core>puae<\/core>\n\t\t\t  <core>uae4arm<\/core>/' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ -f "/opt/system/Switch Launchimage to jpg.sh" ]; then
	    sudo cp -fv /usr/local/bin/perfmax.asc /usr/local/bin/perfmax | tee -a "$LOG_FILE"
	  fi
	  sed -i 's/sudo perfmax retroarch virtualjaguar/sudo perfmax \%GOVERNOR\%/' /etc/emulationstation/es_systems.cfg
	  rm -fv /home/ark/add_palm.txt | tee -a "$LOG_FILE"
	  rm -fv /home/ark/add_coco3.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3351376" ]; then
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

	printf "\nInstall libserialport0 and libportmidi0 for amiberry\n" | tee -a "$LOG_FILE"
	sudo apt -y update && sudo apt -y install libserialport0 libportmidi0 | tee -a "$LOG_FILE"

	printf "\nCopy correct uae4arm libretro core for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /home/ark/.config/retroarch/cores/uae4arm_libretro.so.rk3326 | tee -a "$LOG_FILE"
    else
	  rm -fv /home/ark/.config/retroarch/cores/uae4arm_libretro.so | tee -a "$LOG_FILE"
      mv -fv /home/ark/.config/retroarch/cores/uae4arm_libretro.so.rk3326 /home/ark/.config/retroarch/cores/uae4arm_libretro.so | tee -a "$LOG_FILE"
	fi

	printf "\nUpdated libretro scummvm.ini file to point to roms/bios/scummvm by default or roms2/bios/scummvm for 2 sd card setup\n" | tee -a "$LOG_FILE"
	sed -i 's/home\/ark\/.config\/retroarch\/system/roms\/bios/' /roms/bios/scummvm.ini
	sed -i '/gui_theme=builtin/s//gui_theme=residualvm/' /roms/bios/scummvm.ini
	sed -i '/gui_scale=125/s//gui_scale=150/' /roms/bios/scummvm.ini
	sed -i '/scummvm_mapper_a = "RETROK_ESCAPE"/s//scummvm_mapper_a = "RETROKE_RIGHT_BUTTON"/' /home/ark/.config/retroarch/retroarch-core-options.cfg /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	sed -i '/scummvm_mapper_b = "RETROK_RETURN"/s//scummvm_mapper_b = "RETROKE_LEFT_BUTTON"/' /home/ark/.config/retroarch/retroarch-core-options.cfg /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  cp -fv /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
	  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
	fi
	if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
	  sed -i 's/home\/ark\/.config\/retroarch\/system/roms2\/bios/' /roms2/bios/scummvm.ini
	  sed -i '/gui_theme=builtin/s//gui_theme=residualvm/' /roms2/bios/scummvm.ini
	  sed -i '/gui_scale=125/s//gui_scale=150/' /roms2/bios/scummvm.ini
	  mkdir -pv /roms2/bios/scummvm/theme/ | tee -a "$LOG_FILE"
	  mkdir -pv /roms2/bios/scummvm/extra/ | tee -a "$LOG_FILE"
	  install -Dv /roms/bios/scummvm/theme/gui-icons.dat /roms2/bios/scummvm/theme/gui-icons.dat | tee -a "$LOG_FILE"
	  install -Dv /roms/bios/scummvm/theme/residualvm.zip /roms2/bios/scummvm/theme/residualvm.zip | tee -a "$LOG_FILE"
	  install -Dv /roms/bios/scummvm/theme/shaders.dat /roms2/bios/scummvm/theme/shaders.dat | tee -a "$LOG_FILE"
	  install -Dv /roms/bios/scummvm/theme/translations.dat /roms2/bios/scummvm/theme/translations.dat | tee -a "$LOG_FILE"
	fi

	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
	    printf "\nUpdating amiberry.conf to look for kickstart bios files from roms2 instead of roms\n" | tee -a "$LOG_FILE"
	    sed -i '/roms\/bios/s//roms2\/bios/g' /opt/amiberry/conf/amiberry.conf
	  fi
	fi

	printf "\nAdd support for .chd and .CHD for PSP\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.iso .ISO .cso .CSO .pbp .PBP</s//<extension>.chd .CHD .cso .CSO .iso .ISO .pbp .PBP</' /etc/emulationstation/es_systems.cfg

	printf "\nAdd support for .7z and .7Z for Nintendo DS\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.zip .ZIP .nds .NDS</s//<extension>.7z .7Z .nds .NDS .zip .ZIP</' /etc/emulationstation/es_systems.cfg

	printf "\nCopy correct PPSSPPSDL-2021 for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      rm -fv /opt/ppsspp-2021/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
	  cp -fv /opt/ppsspp/assets/gamecontrollerdb.txt /opt/ppsspp-2021/assets/gamecontrollerdb.txt | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp-2021/PPSSPPSDL.rk3326 /opt/ppsspp-2021/PPSSPPSDL | tee -a "$LOG_FILE"
	  cp -fv /opt/ppsspp/assets/gamecontrollerdb.txt /opt/ppsspp-2021/assets/gamecontrollerdb.txt | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
	  printf "\nCopy updated updated dtb file with FN button activated for R35s units\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/rg351mp/rk3326-rg351mp* /boot/. | tee -a "$LOG_FILE"
	  if [ -f "/boot/rk3326-r35s-linux.dtb" ]; then
	    sudo cp -fv /home/ark/rg351mp/rk3326-r35s* /boot/. | tee -a "$LOG_FILE"
	  fi
	  sudo rm -Rfv /home/ark/rg351mp/ | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-r35s-linux.dtb" ]; then
	  printf "\nCopy updated updated dtb file with FN button activated for R35s units\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /home/ark/rg351mp/rk3326-r35s* /boot/. | tee -a "$LOG_FILE"
	  sudo rm -Rfv /home/ark/rg351mp/ | tee -a "$LOG_FILE"
	else
	  printf "\nThis does not seem to be a rg351mp or related clone.  Removing some unneeded files included with this update that are not needed.\n" | tee -a "$LOG_FILE"
	  sudo rm -Rfv /home/ark/rg351mp/ | tee -a "$LOG_FILE"
	fi

	if test -z "$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep 'palm_emu_use_joystick_as_mouse' | tr -d '\0')"
	then
	  printf "\nEnable the left joystick as mouse by default for Palm OS\n" | tee -a "$LOG_FILE"
	  sed -i -e '$a\\palm_emu_use_joystick_as_mouse \= \"enabled\"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  sed -i -e '$a\\palm_emu_use_joystick_as_mouse \= \"enabled\"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update01272024"

fi

if [ ! -f "/home/ark/.config/.update02232024" ]; then

	printf "\nFix PPSSPP exit hotkey demon from last update\nFixed left justification of ALG games\nUpdate PPSSPP to version 1.17.1\nUpdated XRoar emulator\nFix standalone-duckstation script\nUpdate retroarch and retroarch32 to 1.17\nUpdate retroarch and retroarch32 launch scripts\nUpdated USB DAC control script\nUpdate Emulationstation to fix crash with editing metadata for options\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02232024/arkosupdate02232024.zip -O /dev/shm/arkosupdate02232024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02232024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate02232024.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
            sudo unzip -X -o /dev/shm/arkosupdate02232024.zip -d / | tee -a "$LOG_FILE"
		  else
            sudo unzip -X -o /dev/shm/arkosupdate02232024.zip -x usr/local/bin/rgb30versioncheck.bat "usr/local/bin/rgb30dtbs/*" -d / | tee -a "$LOG_FILE"
		  fi
		else
          sudo unzip -X -o /dev/shm/arkosupdate02232024.zip -x usr/local/bin/ppssppkeydemon.py -d / | tee -a "$LOG_FILE"
		fi
	    sudo rm -fv /dev/shm/arkosupdate02232024.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate02232024.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'videopac' | tr -d '\0')"
	then
	  printf "\nAdd videopac libretro emulator\n" | tee -a "$LOG_FILE"
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update02232024.bak | tee -a "$LOG_FILE"
	  sed -i -e '/<theme>vic20<\/theme>/{r /home/ark/add_videopac.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	fi
	if [ ! -d "/roms/videopac" ]; then
	  mkdir -v /roms/videopac | tee -a "$LOG_FILE"
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		if [ ! -d "/roms2/videopac" ]; then
		  mkdir -v /roms2/videopac | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\/videopac/s//<path>\/roms2\/videopac/g' /etc/emulationstation/es_systems.cfg
		fi
	  fi
	fi
	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep videopac | tr -d '\0')"
	  then
		sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/videopac\/" ]\; then\n      sudo mkdir \/roms2\/videopac\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\nvideopac is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep videopac | tr -d '\0')"
	  then
		sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/videopac\/" ]\; then\n      sudo mkdir \/roms2\/videopac\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\nvideopac is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	rm -fv /home/ark/add_videopac.txt | tee -a "$LOG_FILE"

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate supported extensions for Commodore 8 bit systems\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.d64 .D64 .d71 .D71 .d80 .D80 .d81 .D81 .d82 .D82 .g64 .G64 .g41 .G41 .x64 .X64 .t64 .T64 .tap .TAP .prg .PRG .p00 .P00 .crt .CRT .bin .BIN .zip .ZIP .gz .GZ .d6z .D6Z .d7z .D7Z .d8z .D8Z .g6z .G6Z .g4z .G4Z .x6z .X6Z .cmd .CMD .m3u .M3U .vsf .VSF .nib .NIB .nbz .NBZ/s//<extension>.7z .7Z .bin .BIN .cmd .CMD .crt .CRT .d2m .D2M .d4m .D4M .d64 .D64 .d6z .D6Z .d71 .D71 .d7z .D7Z .d80 .D80 .d81 .D81 .d82 .D82 .d8z .D8Z .g41 .G41 .g4z .G4Z .g64 .G64 .g6z .G6Z .gz .GZ .m3u .M3U .nbz .NBZ .nib .NIB .p00 .P00 .prg .PRG .t64 .T64 .tap .TAP .tcrt .TCRT .vfl .VFL .vsf .VSF .x64 .X64 .x6z .X6Z .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.d64 .D64 .d71 .D71 .d81 .D81 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .prg .PRG .nib .NIB .tap .TAP .vsf .VSF/s//<extension>.7z .7Z .bin .BIN .cmd .CMD .crt .CRT .d2m .D2M .d4m .D4M .d64 .D64 .d6z .D6Z .d71 .D71 .d71 .D71 .d7z .D7Z .d80 .D80 .d81 .D81 .d81 .D81 .d82 .D82 .d8z .D8Z .g41 .G41 .g4z .G4Z .g64 .G64 .g6z .G6Z .gz .GZ .m3u .M3U .nbz .NBZ .nib .NIB .p00 .P00 .prg .PRG .t64 .T64 .tap .TAP .tcrt .TCRT .vfl .VFL .vsf .VSF .vsf .VSF .x64 .X64 .x6z .X6Z .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.d64 .D64 .d71 .D71 .d80 .D80 .d81 .D81 .d82 .D82 .g64 .G64 .g41 .G41 .x64 .X64 .t64 .T64 .tap .TAP .prg .PRG .p00 .P00 .crt .CRT .bin .BIN .zip .ZIP .gz .GZ .d6z .D6Z .d7z .D7Z .d8z .D8Z .g6z .G6Z .g4z .G4Z .x6z .X6Z .cmd .CMD .m3u .M3U .vsf .VSF .nib .NIB .nbz .NBZ/s//<extension>.7z .7Z .bin .BIN .cmd .CMD .crt .CRT .d2m .D2M .d4m .D4M .d64 .D64 .d6z .D6Z .d71 .D71 .d7z .D7Z .d80 .D80 .d81 .D81 .d82 .D82 .d8z .D8Z .g41 .G41 .g4z .G4Z .g64 .G64 .g6z .G6Z .gz .GZ .m3u .M3U .nbz .NBZ .nib .NIB .p00 .P00 .prg .PRG .t64 .T64 .tap .TAP .tcrt .TCRT .vfl .VFL .vsf .VSF .x64 .X64 .x6z .X6Z .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.20 .40 .60 .a0 .A0 .b0 .B0 .d64 .D64 .d71 .D71 .d80 .D80 .d81 .D81 .d82 .D82 .g64 .G64 .g41 .G41 .x64 .X64 .t64 .T64 .tap .TAP .prg .PRG .p00 .P00 .crt .CRT .bin .BIN .gz .GZ .d6z .D6Z .d7z .D7Z .d8z .D8Z .g6z .G6Z .g4z .G4Z .x6z .X6Z .cmd .CMD .m3u .M3U .vsf .VSF .nib .NIB .nbz .NBZ .zip .ZIP/s//<extension>.20 .40 .60 .7z .7Z .a0 .A0 .b0 .B0 .bin .BIN .cmd .CMD .crt .CRT .d2m .D2M .d4m .D4M .d64 .D64 .d6z .D6Z .d71 .D71 .d7z .D7Z .d80 .D80 .d81 .D81 .d82 .D82 .d8z .D8Z .g41 .G41 .g4z .G4Z .g64 .G64 .g6z .G6Z .gz .GZ .m3u .M3U .nbz .NBZ .nib .NIB .p00 .P00 .prg .PRG .rom .ROM .t64 .T64 .tap .TAP .tcrt .TCRT .vfl .VFL .vsf .VSF .x64 .X64 .x6z .X6Z .zip .ZIP/' /etc/emulationstation/es_systems.cfg

	printf "\nAdd ipf support extension for Amiga\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.lha .LHA .hdf .HDF .adf .ADF .zip .ZIP/s//<extension>.adf .ADF .hdf .HDF .ipf .IPF .lha .LHA .zip .ZIP/' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate launching of scripts in Options section to output stderr\n" | tee -a "$LOG_FILE"
	sed -i 's/sudo chmod 666 \/dev\/tty1; %ROM% > \/dev\/tty1; printf \"\\033c\" >> \/dev\/tty1/sudo chmod 666 \/dev\/tty1; %ROM% 2\>\&1 \> \/dev\/tty1; printf \"\\033c\" \>\> \/dev\/tty1/' /etc/emulationstation/es_systems.cfg

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nUpdate platform name for gamecube to fix scraping\n" | tee -a "$LOG_FILE"
	  sed -i 's/<platform>gamecube<\/platform>/<platform>gc<\/platform>/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	  cp -Rfv /home/ark/retroarch_filters/filters.rk3326/ /home/ark/.config/retroarch/
	  cp -Rfv /home/ark/retroarch_filters/filters32.rk3326/ /home/ark/.config/retroarch32/
	  rm -rfv /home/ark/retroarch_filters/ | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	  cp -Rfv /home/ark/retroarch_filters/filters.rk3326/ /home/ark/.config/retroarch/
	  cp -Rfv /home/ark/retroarch_filters/filters32.rk3326/ /home/ark/.config/retroarch32/
	  rm -rfv /home/ark/retroarch_filters/ | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	  cp -Rfv /home/ark/retroarch_filters/filters/ /home/ark/.config/retroarch/
	  cp -Rfv /home/ark/retroarch_filters/filters32/ /home/ark/.config/retroarch32/
	  rm -rfv /home/ark/retroarch_filters/ | tee -a "$LOG_FILE"
	fi

#	echo "\nUpdate glibc and libstdc++\n" | tee -a "$LOG_FILE"
#	echo 'deb http://ports.ubuntu.com/ubuntu-ports focal main universe' | sudo tee -a /etc/apt/sources.list
#	echo 'libc6 libraries/restart-without-asking boolean true' | sudo debconf-set-selections
#	sudo apt -y update && sudo apt -y install libc6 libstdc++6 | tee -a "$LOG_FILE"
#	sudo sed -i '/focal/d' /etc/apt/sources.list
#	echo 'deb http://ports.ubuntu.com/ubuntu-ports jammy main universe' | sudo tee -a /etc/apt/sources.list
#	sudo apt -y update && sudo apt -y install libc6 libstdc++6 | tee -a "$LOG_FILE"
#	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.2800.2 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
#	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.2800.2 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
#	sudo sed -i '/jammy/d' /etc/apt/sources.list
#	sudo apt -y update | tee -a "$LOG_FILE"

	if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  printf "\nAdd V1 and V2 detection to fix performance issues for the RGB30 units\n" | tee -a "$LOG_FILE"
	  if test -z "$(sudo crontab -l | grep 'rgb30versioncheck.sh' | tr -d '\0')"
	  then
	    echo "@reboot /usr/local/bin/rgb30versioncheck.sh &" | sudo tee -a /var/spool/cron/crontabs/root | tee -a "$LOG_FILE"
	    if test ! -z "$(dmesg | grep -Eo 'cpu[0-9] policy NULL' | head -n 1 | tr -d '\0')"
	    then
	      if [ ! -f "/home/ark/.config/.V2DTBLOADED" ]; then
		    sudo cp -f /usr/local/bin/rgb30dtbs/rk3566-rgb30.dtb.v2 /boot/rk3566-OC.dtb
	        touch /home/ark/.config/.V2DTBLOADED
	      else
		    sudo cp -f /usr/local/bin/rgb30dtbs/rk3566-rgb30.dtb.v1 /boot/rk3566-OC.dtb
		    rm -f /home/ark/.config/.V2DTBLOADED
	      fi
	    fi
	  else
	    printf "  No need to add this feature as it already exists.\n" | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nAdd exit hotkey daemon for ecwolf standalone\n" | tee -a "$LOG_FILE"
	sudo cp -fv /usr/local/bin/ti99keydemon.py /usr/local/bin/ecwolfsakeydemon.py | tee -a "$LOG_FILE"
	sudo chmod 777 /usr/local/bin/ecwolfsakeydemon.py
	sudo sed -i 's/ti99sim-sdl/ecwolf/' /usr/local/bin/ecwolfsakeydemon.py

	if test -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
	  if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ]; then
	    printf "\nFixing standalone-duckstation loading for single card setup\n" | tee -a "$LOG_FILE"
	    sed -i '/\/roms2\//s//\/roms\//g' /home/ark/.config/duckstation/settings.ini
	  else
	    printf "\nThis seems to be a RG351V unit so skipping standalone-duckstation fix since it's not available for this unit\n" | tee -a "$LOG_FILE"
	  fi
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nFix audio performance issues for the mednafen standalone emulator\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/share/alsa/alsa.conf /usr/share/alsa/alsa.conf.mednafen | tee -a "$LOG_FILE"
	  sudo sed -i '/\"\~\/.asoundrc\"/s//\"\~\/.asoundrc.mednafen\"/' /usr/share/alsa/alsa.conf.mednafen
	fi

	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
	  printf "\nFix mednafen standalone emulator controls\n" | tee -a "$LOG_FILE"
	  sed -i '/0x0019484b110001000004001000000000/s//0x0019484b110001000004001100000000/g' /home/ark/.mednafen/mednafen.cfg
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ "$test" = "3367776" ]; then
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

	if [ $(grep yabasanshiro es_systems.cfg | wc -l) -lt 2 ]; then
	  printf "\nAdd yabasanshiro as an additional emulator for retroarch\n" | tee -a "$LOG_FILE"
	  sed -i ':a;N;$!ba;s/<core>yabause<\/core>/<core>yabause<\/core>\n\t\t \t  <core>yabasanshiro<\/core>/2' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nCopy correct libretro yabasanshiro core for retroarch depending on device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  mv -fv /home/ark/.config/retroarch/cores/yabasanshiro_libretro.so.rk3326 /home/ark/.config/retroarch/cores/yabasanshiro_libretro.so | tee -a "$LOG_FILE"
	else
	  rm -fv /home/ark/.config/retroarch/cores/yabasanshiro_libretro.so.rk3326 | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02232024"

fi

if [ ! -f "/home/ark/.config/.update03292024" ]; then

	printf "\nAdd .neo and .NEO extension support for Neo Geo\nUpdate n64.sh launch script\nUpdate retroarches\nUpdate XRoar to 1.5.5\nUpdate Kodi to 20.5\nUpdate singe.sh launch script\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/03292024/arkosupdate-kodi03292024.zip -O /dev/shm/arkosupdate-kodi03292024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate-kodi03292024.zip | tee -a "$LOG_FILE"
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/03292024/arkosupdate-kodi03292024.z01 -O /dev/shm/arkosupdate-kodi03292024.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate-kodi03292024.z01 | tee -a "$LOG_FILE"
	  if [ -f "/dev/shm/arkosupdate-kodi03292024.zip" ] && [ -f "/dev/shm/arkosupdate-kodi03292024.z01" ]; then
	    zip -FF /dev/shm/arkosupdate-kodi03292024.zip --out /dev/shm/arkosupdate03292024.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate-kodi03292024.z* | tee -a "$LOG_FILE"
	  else
		printf "\nThe update couldn't complete because the packages did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	  fi
	else
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/03292024/arkosupdate03292024.zip -O /dev/shm/arkosupdate03292024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate03292024.zip | tee -a "$LOG_FILE"
	fi
	if [ -f "/dev/shm/arkosupdate03292024.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  rm -rfv /opt/kodi/lib/kodi/addons/* /opt/kodi/share/kodi/addons/* /opt/kodi/lib/addons/* /opt/kodi/lib/pkgconfig/* /opt/kodi/lib/libdumb.a | tee -a "$LOG_FILE"
		fi
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update03292024.bak
		sudo unzip -X -o /dev/shm/arkosupdate03292024.zip -d / | tee -a "$LOG_FILE"
		if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ] || [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
		  sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' /opt/kodi/share/kodi/addons/skin.estuary/addon.xml
		fi
		sudo rm -fv /dev/shm/arkosupdate03292024.zip | tee -a "$LOG_FILE"
	else
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate03292024.z* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'apple2' | tr -d '\0')"
	then
	  printf "\nAdd apple2 emulation support\n" | tee -a "$LOG_FILE"
	  sed -i -e '/<theme>amstradcpc<\/theme>/{r /home/ark/add_apple2.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	fi
	if [ ! -d "/roms/apple2" ]; then
	  mkdir -v /roms/apple2 | tee -a "$LOG_FILE"
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		if [ ! -d "/roms2/apple2" ]; then
		  mkdir -v /roms2/apple2 | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\/apple2/s//<path>\/roms2\/apple2/g' /etc/emulationstation/es_systems.cfg
		fi
	  fi
	fi
	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep apple2 | tr -d '\0')"
	  then
		sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/apple2\/" ]\; then\n      sudo mkdir \/roms2\/apple2\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\napple2 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep apple2 | tr -d '\0')"
	  then
		sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/apple2\/" ]\; then\n      sudo mkdir \/roms2\/apple2\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  else
		printf "\napple2 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	  fi
	fi
	rm -fv /home/ark/add_apple2.txt | tee -a "$LOG_FILE"

	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  printf "\nCopy updated Retroarch filters for rk3326 devices\n" | tee -a "$LOG_FILE"
	  cp -Rfv /home/ark/.config/retroarch/filters.rk3326/* /home/ark/.config/retroarch/filters/ | tee -a "$LOG_FILE"
	  cp -Rfv /home/ark/.config/retroarch32/filters32.rk3326/* /home/ark/.config/retroarch32/filters/ | tee -a "$LOG_FILE"
	  sudo rm -Rfv /home/ark/.config/retroarch32/filters32.rk3326/ | tee -a "$LOG_FILE"
	  sudo rm -Rfv /home/ark/.config/retroarch/filters.rk3326/ | tee -a "$LOG_FILE"
	  printf "\nRemove RGB30 related items accidentally added from the 02232024 update\n" | tee -a "$LOG_FILE"
	  sudo rm -rfv /usr/local/bin/rgb30versioncheck.sh /usr/local/bin/rgb30dtbs/ | tee -a "$LOG_FILE"
	fi

	if [ -f /home/ark/.config/.DEVICE ] && [ -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	  printf "\nRemove RGB30 related items accidentally added from the 02232024 update\n" | tee -a "$LOG_FILE"
	  sudo rm -rfv /usr/local/bin/rgb30versioncheck.sh | tee -a "$LOG_FILE"
	fi

	if test -z "$(grep 'geolith' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	then
	  printf "\nAdd geolith libretro core for Neo Geo\n" | tee -a "$LOG_FILE"
	  sed -i -r '/<name>neogeo<\/name>/,/<core>mame2003_plus<\/core>/ s|<core>mame2003_plus<\/core>|<core>mame2003_plus<\/core>\n\t\t\t  <core>geolith<\/core>|' /etc/emulationstation/es_systems.cfg
	  sed -i -r '/<name>neogeo<\/name>/,/<extension>.zip .ZIP .7z .7Z .cue .CUE/ s|<extension>.zip .ZIP .7z .7Z .cue .CUE|<extension>.7z .7Z .cue .CUE .neo .NEO .zip .ZIP|' /etc/emulationstation/es_systems.cfg
	  printf "\nCopy correct libretro geolith core depending on device\n" | tee -a "$LOG_FILE"
	  if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	    mv -fv /home/ark/.config/retroarch/cores/geolith_libretro.so.rk3326 /home/ark/.config/retroarch/cores/geolith_libretro.so | tee -a "$LOG_FILE"
	  else
	    rm -fv /home/ark/.config/retroarch/cores/geolith_libretro.so.rk3326 | tee -a "$LOG_FILE"
	  fi
	fi

	if test -z "$(grep 'DoubleCherryGB' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	then
	  printf "\nAdd DoubleCherryGB libretro core for GameBoy and GameBoy Color\n" | tee -a "$LOG_FILE"
	  sed -i '/<core>tgbdual<\/core>/c\\t\t\t  <core>DoubleCherryGB<\/core>\n\t\t\t  <core>tgbdual<\/core>' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd stella libretro emulator for Atari 2600\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -w 'stella' | tr -d '\0')"
	then
	  sed -i -e '/cores\/stella2014_libretro.so/{r /home/ark/add_stella.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  rm -fv /home/ark/add_stella.txt | tee -a "$LOG_FILE"
	else
	  rm -fv /home/ark/add_stella.txt | tee -a "$LOG_FILE"
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

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nUpdate older PortMaster install to address a possible update bug\n" | tee -a "$LOG_FILE"
	# Only update if our version is a possibly bugged version.
	chmod +x /home/ark/Install.PortMaster.sh
	touch /home/ark/no_es_restart
	/home/ark/Install.PortMaster.sh | tee -a "$LOG_FILE"
	# Delete the installer
	rm -fv /home/ark/Install.PortMaster.sh | tee -a "$LOG_FILE"

	touch "/home/ark/.config/.update03292024"

fi

if [ ! -f "/home/ark/.config/.update03302024" ]; then

	printf "\nFix retroarch32 rotation\nFix missing saves from last retroarch update\nFix PPSSPP 1.17.1 gui size\nUpdated apple2.sh script\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/03302024/arkosupdate03302024.zip -O /dev/shm/arkosupdate03302024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate03302024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate03302024.zip" ]; then
      sudo unzip -X -o /dev/shm/arkosupdate03302024.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate03302024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate03302024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
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

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nAdd .rvz as supported extension for gamecube\n" | tee -a "$LOG_FILE"
	  sed -i '/<extension>.elf .ELF .gcz .GCZ .iso .ISO .m3u .M3U .wad .WAD .wbfs .WBFS .wia .WIA/s//<extension>.elf .ELF .gcz .GCZ .iso .ISO .m3u .M3U .rvz .RVZ .wad .WAD .wbfs .WBFS .wia .WIA/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update03302024"

fi

if [ ! -f "/home/ark/.config/.update04242024" ]; then

	printf "\nUpdate apple2.sh script\nUpdate ppsspp-2021 to fix gui\nAdd fix audio tool for rk3566 devices only\nUpdate usbdac script for rk3566 devices\nAdd input tester tool\nUpdate Mednafen standalone to 1.32.1\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04242024/arkosupdate04242024.zip -O /dev/shm/arkosupdate04242024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate04242024.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/04242024/arkosupdate04242024.z01 -O /dev/shm/arkosupdate04242024.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate04242024.z01 | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate04242024.zip" ] && [ -f "/dev/shm/arkosupdate04242024.z01" ]; then
	  zip -FF /dev/shm/arkosupdate04242024.zip --out /dev/shm/arkosupdate.zip -fz | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate04242024.z* | tee -a "$LOG_FILE"
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
        sudo unzip -X -o /dev/shm/arkosupdate.zip -d / | tee -a "$LOG_FILE"
	  else
        sudo unzip -X -o /dev/shm/arkosupdate.zip -x opt/system/Advanced/Fix\ Audio.sh -d / | tee -a "$LOG_FILE"
	  fi
	  sudo rm -fv /dev/shm/arkosupdate.zip | tee -a "$LOG_FILE"
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04242024.bak
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate04242024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nInstall inputs python3 module via pip3\n" | tee -a "$LOG_FILE"
	sudo apt update -y | tee -a "$LOG_FILE"
	sudo apt -y install python3-pip | tee -a "$LOG_FILE"
	pip3 --retries 10 -v install inputs | tee -a "$LOG_FILE"
	if [ $? != 0 ]; then
	  printf "\nThe update couldn't complete because the inputs python package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sleep 3
	  exit 1
	fi
	sudo systemctl daemon-reload

	printf "\nAdd MESS core as additional core for Apple2\n" | tee -a "$LOG_FILE"
	sed -i '/<core>applewin<\/core>/s//<core>applewin<\/core>\n\t           <core>mess<\/core>/' /etc/emulationstation/es_systems.cfg
	if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	then
	  mkdir -pv /roms2/bios/mame/hash | tee -a "$LOG_FILE"
	  cp -fv /roms/bios/mame/hash/apple2* /roms2/bios/mame/hash/ | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct PPSSPPSDL-2021 for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp-2021/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp-2021/PPSSPPSDL.rk3326 /opt/ppsspp-2021/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct scummvm for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/scummvm/scummvm.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/scummvm/scummvm.rk3326 /opt/scummvm/scummvm | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	touch "/home/ark/.config/.update04242024"

fi

if [ ! -f "/home/ark/.config/.update05242024" ]; then

	printf "\nUpdate RGB30 v2 dtb file to fix potential reboot after shutdown issue\nUpdate Mupen64plus Standalone\nUpdate Fix Audio tool\nUpdate Wifi.sh\nUpdate gamecontrollerdb.txt for inttools\nFix SD2 when used with JELOS and ROCKNIX\nUpdated filebrowser to 2.30.0\nUpdate Xbox Series X Controller profile\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/05242024/arkosupdate05242024.zip -O /dev/shm/arkosupdate05242024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate05242024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate05242024.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	    if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
          sudo unzip -X -o /dev/shm/arkosupdate05242024.zip -d / | tee -a "$LOG_FILE"
	      if [ -f "/home/ark/.config/.V2DTBLOADED" ]; then
	        printf "\nThis seems to be a RGB30 V2 unit.  Copying the updated V2 dtb to the boot partition.\n" | tee -a "$LOG_FILE"
		    sudo cp -fv /usr/local/bin/rgb30dtbs/rk3566-rgb30.dtb.v2 /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  fi
	    else
		  sudo unzip -X -o /dev/shm/arkosupdate05242024.zip -x usr/local/bin/rgb30dtbs/rk3566-rgb30.dtb.v2 -d / | tee -a "$LOG_FILE"
	    fi
	  else
		sudo unzip -X -o /dev/shm/arkosupdate05242024.zip -x usr/local/bin/rgb30dtbs/rk3566-rgb30.dtb.v2 opt/system/Advanced/Fix\ Audio.sh usr/local/bin/round_end.wav home/ark/.config/retroarch32/autoconfig/udev/Xbox\ Series\ X\ Controller.cfg home/ark/.config/retroarch/autoconfig/udev/Xbox\ Series\ X\ Controller.cfg -d / | tee -a "$LOG_FILE"
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    printf "\nFix Switch to SD2 for Roms script in /usr/local/bin\n" | tee -a "$LOG_FILE"
	    sudo sed -i '/sudo rm -rf/s//#sudo rm -rf/g' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    sudo sed -i '/sudo tar -xvkf/s//sudo tar --strip-components=1 -xvkf/g' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    sudo sed -i '/sudo mv -v -f -n/s//#sudo mv -v -f -n/g' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    printf "\nFix Switch to SD2 for Roms script in /opt/system/Advanced\n" | tee -a "$LOG_FILE"
	    sudo sed -i '/sudo rm -rf/s//#sudo rm -rf/g' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    sudo sed -i '/sudo tar -xvkf/s//sudo tar --strip-components=1 -xvkf/g' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    sudo sed -i '/sudo mv -v -f -n/s//#sudo mv -v -f -n/g' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	  fi
	  sudo rm -fv /dev/shm/arkosupdate05242024.zip | tee -a "$LOG_FILE"
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update04242024.bak
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate05242024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nUpdate port launching in es_systems.cfg to support alternate SDL versions\n" | tee -a "$LOG_FILE"
	sed -i '/nice -n -19 %ROM%/s//nice -n -19 \/usr\/local\/bin\/AltSDL.sh %ROM%/g' /etc/emulationstation/es_systems.cfg

	printf "\nAdd support for game launch images using scraped images\n" | tee -a "$LOG_FILE"
	sed -i 's/sudo perfmax \%GOVERNOR\%;/sudo perfmax \%GOVERNOR\% \%ROM\%;/' /etc/emulationstation/es_systems.cfg
	if [ -f "/opt/system/Switch Launchimage to ascii.sh" ]; then
	  touch /home/ark/.config/.GameLoadingIModePIC
	  echo "<string name=\"GameLoadingIMode\" value=\"pic\" />" >> /home/ark/.emulationstation/es_settings.cfg
	else
	  touch /home/ark/.config/.GameLoadingIModeASCII
	  echo "<string name=\"GameLoadingIMode\" value=\"ascii\" />" >> /home/ark/.emulationstation/es_settings.cfg
	fi
	rm -fv /opt/system/Switch\ Launchimage\ to* | tee -a "$LOG_FILE"

	printf "\nInstall and link new SDL 2.0.3000.3 (aka SDL 2.0.30.3)\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.3.rk3566 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.3 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.3.rk3566 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.3 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.3 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.3 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.3.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.3 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.3.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.3 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.3 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.3 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.3.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.3 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.3.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.3 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.3 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.3 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct mupen64plus standalone for the chipset and adjust some GlideN64 related settings\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  cp -fv /opt/mupen64plus/mupen64plus-video-GLideN64.so.rk3326 /opt/mupen64plus/mupen64plus-video-GLideN64.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-glide64mk2.so.rk3326 /opt/mupen64plus/mupen64plus-video-glide64mk2.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-rice.so.rk3326 /opt/mupen64plus/mupen64plus-video-rice.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-audio-sdl.so.rk3326 /opt/mupen64plus/mupen64plus-audio-sdl.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus.rk3326 /opt/mupen64plus/mupen64plus | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/libmupen64plus.so.2.0.0.rk3326 /opt/mupen64plus/libmupen64plus.so.2.0.0 | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-rsp-hle.so.rk3326 /opt/mupen64plus/mupen64plus-rsp-hle.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-input-sdl.so.rk3326 /opt/mupen64plus/mupen64plus-input-sdl.so | tee -a "$LOG_FILE"
	  rm -fv /opt/mupen64plus/*.rk3326 | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/mupen64plus/*.rk3326 | tee -a "$LOG_FILE"
	  echo "  Correct Mupen64plus standalone files are already in place for this rk3566 device" | tee -a "$LOG_FILE"
	fi
	sed -i "/ThreadedVideo \=/c\ThreadedVideo \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg
	sed -i "/UseNativeResolutionFactor \=/c\UseNativeResolutionFactor \= 1" /home/ark/.config/mupen64plus/mupen64plus.cfg

	printf "\nCopy correct Hypseus-Singe for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	touch "/home/ark/.config/.update05242024"

fi

if [ ! -f "/home/ark/.config/.update06272024" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.19.1\nUpdate Emulationstation\nUpdate Ondemand cpu governor threshold and sampling factor\nFix ALG no longer launching since last update\nAdd Ardens libreto core for Arduboy\nAdd japanese translation for ES\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06272024/arkosupdate06272024.zip -O /dev/shm/arkosupdate06272024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate06272024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate06272024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate06272024.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate06272024.zip | tee -a "$LOG_FILE"
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06272024.bak
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate06272024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
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

	printf "\nRemove MS-DOS and PS1 extension changing scripts\n" | tee -a "$LOG_FILE"
	if [ -f "/opt/system/PS1 - Show only m3u games.sh" ]; then
	  sudo rm -fv /opt/system/PS1\ -\ Show\ only\ m3u\ games.sh | tee -a "$LOG_FILE"
	  sudo rm -rf /usr/local/bin/PS1\ -\ Show\ only\ m3u\ games.sh | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/PS1\ -\ Show\ all\ games.sh | tee -a "$LOG_FILE"
	else
	  sed -i '/<extension>.m3u .M3U<\/extension>/s//<extension>.cue .CUE .img .IMG .mdf .MDF .pbp .PBP .toc .TOC .cbn .CBN .m3u .M3U .ccd .CCD .chd .CHD .zip .ZIP .7z .7Z .iso .ISO<\/extension>/' /etc/emulationstation/es_systems.cfg
	  sudo rm -fv /opt/system/PS1\ -\ Show\ all\ games.sh | tee -a "$LOG_FILE"
	  sudo rm -rf /usr/local/bin/PS1\ -\ Show\ only\ m3u\ games.sh | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/PS1\ -\ Show\ all\ games.sh | tee -a "$LOG_FILE"
	fi
	if [ -f "/opt/system/MSDOS - Hide zip games.sh" ]; then
	  sudo rm -fv /opt/system/MSDOS\ -\ Hide\ zip\ games.sh | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/MSDOS\ -\ Show\ zip\ games.sh | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/MSDOS\ -\ Hide\ zip\ games.sh | tee -a "$LOG_FILE"
	else
	  sed -i '/<extension>.exe .EXE .com .COM .bat .BAT .conf .CONF .cue .CUE .iso .ISO .m3u .M3U .dosz .DOSZ<\/extension>/s//<extension>.exe .EXE .com .COM .bat .BAT .conf .CONF .cue .CUE .iso .ISO .zip .ZIP .m3u .M3U .dosz .DOSZ<\/extension>/' /etc/emulationstation/es_systems.cfg
	  sudo rm -fv /opt/system/MSDOS\ -\ Show\ zip\ games.sh
	  sudo rm -fv /usr/local/bin/MSDOS\ -\ Show\ zip\ games.sh | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/MSDOS\ -\ Hide\ zip\ games.sh | tee -a "$LOG_FILE"
	fi

	printf "\nAdd .7z .7Z .zip and .ZIP as supported extensions for N64\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.z64 .Z64 .n64 .N64 .v64 .V64<\/extension>/s//<extension>.7z .7Z .n64 .N64 .v64 .V64 .z64 .Z64 .zip .ZIP<\/extension>/' /etc/emulationstation/es_systems.cfg
	sudo apt -y update && sudo apt -y install p7zip-full | tee -a "$LOG_FILE"

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nInstall Pillow python 3 module for rk3566 devices only\n" | tee -a "$LOG_FILE"
	  sudo apt -y install python3-pil | tee -a "$LOG_FILE"
	fi

	printf "\nAdd ardens as additional emulator for arduboy\n" | tee -a "$LOG_FILE"
	sed -i 's/<command>sudo perfmax \%GOVERNOR\% \%ROM\%; nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/arduous_libretro.so \%ROM\%; sudo perfnorm<\/command>/<command>sudo perfmax \%GOVERNOR\% \%ROM\%; nice -n -19 \/usr\/local\/bin\/\%EMULATOR\% -L \/home\/ark\/.config\/\%EMULATOR\%\/cores\/\%CORE\%_libretro.so \%ROM\%; sudo perfnorm<\/command>\n\t\t   <emulators>\n\t\t      <emulator name=\"retroarch\">\n\t\t \t<cores>\n\t\t \t  <core>ardens<\/core>\n\t\t \t  <core>arduous<\/core>\n\t\t \t<\/cores>\n\t\t      <\/emulator>\n\t\t   <\/emulators>/' /etc/emulationstation/es_systems.cfg

	printf "\nFix governor setting for Atari ST\n" | tee -a "$LOG_FILE"
	sed -i '/<command>nice/s//<command>sudo perfmax \%GOVERNOR\% \%ROM\%; nice/' /etc/emulationstation/es_systems.cfg

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	touch "/home/ark/.config/.update06272024"

fi

if [ ! -f "/home/ark/.config/.update07042024" ]; then

	printf "\nFix slow loading of ES when many ports are loaded and game count when filtering extensions\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07042024/arkosupdate07042024.zip -O /dev/shm/arkosupdate07042024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate07042024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate07042024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate07042024.zip -d / | tee -a "$LOG_FILE"
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07042024.bak
	  sudo rm -fv /dev/shm/arkosupdate07042024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate07042024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'km_fbneo_xtreme_amped' | tr -d '\0')"
	then
	  printf "\nAdd fbneo xtreme core as an optional core wherever fbneo is currently available\n" | tee -a "$LOG_FILE"
	  sed -i '/<core>fbneo<\/core>/c\\t\t\t  <core>fbneo<\/core>\n\t\t\t  <core>km_fbneo_xtreme_amped<\/core>' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	touch "/home/ark/.config/.update07042024"

fi

if [ ! -f "/home/ark/.config/.update07312024" ]; then

	printf "\nUpdate French translation for Emulationstation\nUpdate Korean translation for Emulationstation\nUpdate Spanish translation for Emulationstation\nUpdate Portuguese translation for Emulationstation\nUpdate emulationstation to fix translation for gamelist option video\nAdd Sharp-Shimmerless-Shader for retroarch and retroarch32\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07312024/arkosupdate07312024.zip -O /dev/shm/arkosupdate07312024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate07312024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate07312024.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate07312024.zip -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /dev/shm/arkosupdate07312024.zip -x opt/mupen64plus/mupen64plus-video-rice.so -d / | tee -a "$LOG_FILE"
		fi
	  sudo rm -fv /dev/shm/arkosupdate07312024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate07312024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	
	if test -z "$(grep "chimerasnes" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	then
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07312024.bak | tee -a "$LOG_FILE"
		sed -i '/<core>snes9x2010<\/core>/c\\t\t\t  <core>snes9x2010<\/core>\n\t\t\t  <core>chimerasnes<\/core>' /etc/emulationstation/es_systems.cfg
	fi

	if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
		if test -z "$(grep "VerticalOffset" /home/ark/.config/mupen64plus/mupen64plus.cfg | tr -d '\0')"
		then
		  printf "\nAdd vertical offset setting for Mupen64plus standalone for RGB30\n" | tee -a "$LOG_FILE"
		  sed -i "/\[Video-Rice\]/c\\[Video-Rice\]\n\n\# Hack to adjust vertical offset for screens like on the RGB30\nVerticalOffset \= \"125\"" /home/ark/.config/mupen64plus/mupen64plus.cfg
		fi
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000" | tr -d '\0')" ]; then
		printf "\nUpdate option 9 description in BaRT to include V10\n" | tee -a "$LOG_FILE"
		sudo sed -i "/RGB10 mode/s//RGB10\/V10 mode/" /usr/bin/emulationstation/emulationstation.sh*
	fi

	if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000" | tr -d '\0')" ]; then
		printf "\nUpdate ogage for the RGB10\n" | tee -a "$LOG_FILE"
		sudo systemctl stop oga_events
		sudo cp -fv /home/ark/ogage-rgb10 /usr/local/bin/ogage | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
		sudo systemctl start oga_events
	else
		sudo rm -fv /home/ark/ogage-* | tee -a "$LOG_FILE"
	fi

	#printf "\nInstall and link new SDL 2.0.3000.5 (aka SDL 2.0.30.5)\n" | tee -a "$LOG_FILE"
#	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
#	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.5.rk3566 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.5 | tee -a "$LOG_FILE"
#	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.5.rk3566 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.5 | tee -a "$LOG_FILE"
#	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
#	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.5 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.5 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
#	elif [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
#	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.5.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.5 | tee -a "$LOG_FILE"
#	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.5.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.5 | tee -a "$LOG_FILE"
#	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
#	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.5 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.5 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
#	else
#	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.5.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.5 | tee -a "$LOG_FILE"
#	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.5.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.5 | tee -a "$LOG_FILE"
#	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
#	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.5 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
#	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.5 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
#	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07312024"

fi

if [ ! -f "/home/ark/.config/.update08232024" ]; then

	printf "\nUpdate Kodi to 21.1 Omega\nAdd vmac emulator\nAdd emuscv emulator\nAdd piemu emulator\nAdd minivmac emulator\nUpdate nes-box theme\nUpdate singe.sh file to support reading game.commands file\nUpdate Fake-08 emulator\nAdd smsplus-gx libretro core\nAdd hatarib libretro core\nUpdate nes-box theme\nUpdate wifi script\nFix Backup and Restore ArkOS settings funciton in BaRT\nUpdated apple2.sh script to support .hdv and .HDV\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08232024/arkosupdate-kodi08232024.zip -O /dev/shm/arkosupdate-kodi08232024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate-kodi08232024.zip | tee -a "$LOG_FILE"
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08232024/arkosupdate-kodi08232024.z01 -O /dev/shm/arkosupdate-kodi08232024.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate-kodi08232024.z01 | tee -a "$LOG_FILE"
	  if [ -f "/dev/shm/arkosupdate-kodi08232024.zip" ] && [ -f "/dev/shm/arkosupdate-kodi08232024.z01" ]; then
	    zip -FF /dev/shm/arkosupdate-kodi08232024.zip --out /dev/shm/arkosupdate08232024.zip -fz > /dev/null
		sudo rm -fv /dev/shm/arkosupdate-kodi08232024.z* | tee -a "$LOG_FILE"
	  else
		printf "\nThe update couldn't complete because the packages did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sudo rm -fv /dev/shm/arkosupdate* | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	  fi
	else
	  sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08232024/arkosupdate08232024.zip -O /dev/shm/arkosupdate08232024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate08232024.zip | tee -a "$LOG_FILE"
	fi
	if [ -f "/dev/shm/arkosupdate08232024.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	    rm -rf /opt/kodi/lib/kodi/addons/* /opt/kodi/share/kodi/addons/* /opt/kodi/lib/addons/* /opt/kodi/lib/pkgconfig/* /opt/kodi/lib/libdumb.a | tee -a "$LOG_FILE"
	    sudo unzip -qq -X -o /dev/shm/arkosupdate08232024.zip -d /
		if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RK2023" ] || [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
		  sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' /opt/kodi/share/kodi/addons/skin.estuary/addon.xml
		fi
		sed -i '/skin.estouchy/d' /opt/kodi/share/kodi/system/addon-manifest.xml
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate08232024.zip -d / | tee -a "$LOG_FILE"
	  fi
	  printf "\nAdd piece emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'piece' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08232024.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>palm<\/theme>/{r /home/ark/add_piece.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/piece" ]; then
	    mkdir -v /roms/piece | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/piece" ]; then
		    mkdir -v /roms2/piece | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/piece/s//<path>\/roms2\/piece/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep piece | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/piece\/" ]\; then\n      sudo mkdir \/roms2\/piece\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npiece is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep piece | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/piece\/" ]\; then\n      sudo mkdir \/roms2\/piece\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npiece is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  printf "\nAdd Super Cassette Vision emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'emuscv' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08232024-1.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>easyrpg<\/theme>/{r /home/ark/add_emuscv.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/scv" ]; then
	    mkdir -v /roms/scv | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/scv" ]; then
		    mkdir -v /roms2/scv | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/scv/s//<path>\/roms2\/scv/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep scv | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/scv\/" ]\; then\n      sudo mkdir \/roms2\/scv\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nSuper Cassette Vision is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep scv | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/scv\/" ]\; then\n      sudo mkdir \/roms2\/scv\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nSuper Cassette Vision is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  printf "\nAdd Macintosh emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'vmac' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08232024-2.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>apple2<\/theme>/{r /home/ark/add_vmac.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/vmac" ]; then
	    mkdir -v /roms/vmac | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/vmac" ]; then
		    mkdir -v /roms2/vmac | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/vmac/s//<path>\/roms2\/vmac/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep vmac | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vmac\/" ]\; then\n      sudo mkdir \/roms2\/vmac\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nvmac is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep vmac | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vmac\/" ]\; then\n      sudo mkdir \/roms2\/vmac\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nvmac is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  sudo rm -fv /dev/shm/arkosupdate08232024.zip | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/add_piece.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/add_emuscv.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/add_vmac.txt | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate08232024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if test -z "$(grep 'smsplus' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	then
	  printf "\nAdd smsplus-gx libreto for mastersystem and gamegear to ES\n" | tee -a "$LOG_FILE"
	  sed -i '/<core>gearsystem<\/core>/c\\t\t\t  <core>gearsystem<\/core>\n\t\t\t  <core>smsplus<\/core>' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd hatarib libretro emulator for Atari ST\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -w 'hatarib' | tr -d '\0')"
	then
	  sed -i -e '/cores\/hatari_libretro.so/{r /home/ark/add_hatarib.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  rm -fv /home/ark/add_hatarib.txt | tee -a "$LOG_FILE"
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
	    sudo cp -fv /roms/bios/etos192us.img /roms2/bios/etos192us.img | tee -a "$LOG_FILE"
	  fi
	  echo 'hatarib_borders = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_pad1_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_pad2_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_pad3_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_pad4_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_pause_osk = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_samplerate = "44100"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_statusbar = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_tos = "<etos192us>"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	  echo 'hatarib_borders = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_pad1_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_pad2_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_pad3_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_pad4_select = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_pause_osk = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_samplerate = "44100"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_statusbar = "0"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	  echo 'hatarib_tos = "<etos192us>"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	else
	  rm -fv /home/ark/add_hatarib.txt | tee -a "$LOG_FILE"
	fi

	printf "\nAdd quit hotkey daemon configuration for piemu\n" | tee -a "$LOG_FILE"
	sudo cp -fv /usr/local/bin/ti99keydemon.py /usr/local/bin/piemukeydemon.py | tee -a "$LOG_FILE"
	sudo chmod 777 /usr/local/bin/piemukeydemon.py
	sudo sed -i 's/pkill ti99sim-sdl/sudo kill -9 \$(pidof piemu)/' /usr/local/bin/piemukeydemon.py

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nUpdate Emulationstation to add CPU undervolting setting\n" | tee -a "$LOG_FILE"
	  sudo mv -fv /home/ark/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.* | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct fake08 for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      mv -fv /opt/fake08/fake08.rk3566 /opt/fake08/fake08 | tee -a "$LOG_FILE"
      rm -fv /opt/fake08/fake08.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/fake08/fake08.rk3326 /opt/fake08/fake08 | tee -a "$LOG_FILE"
      rm -fv /opt/fake08/fake08.rk3566 | tee -a "$LOG_FILE"
	fi

	if [ "$(cat ~/.config/.DEVICE)" = "RGB30" ]; then
	  printf "\nUpdate sagabox theme\n" | tee -a "$LOG_FILE"
	  cd /roms/themes/es-theme-sagabox
	  git pull
	  cd /home/ark
	fi

	if test -z "$(cat /usr/bin/emulationstation/emulationstation.sh | grep '/opt/system/Advanced/"Backup ArkOS Settings.sh' | tr -d '\0')"
	then
	  printf "\nFix Backup and Restore ArkOS settings function in BaRT\n" | tee -a "$LOG_FILE"
	  sudo sed -i "/\"8)\") sudo reboot/s//\"6)\") sudo kill -9 \$(pidof boot_controls)\n                                \/opt\/system\/Advanced\/\"Backup ArkOS Settings.sh\" 2>\&1 > \/dev\/tty1\n                                sudo .\/boot_controls none \$param_device \&\n                                ;;\n                          \"7)\") sudo kill -9 \$(pidof boot_controls)\n                                \/opt\/system\/Advanced\/\"Restore ArkOS Settings.sh\" 2>\&1 > \/dev\/tty1\n                                sudo .\/boot_controls none \$param_device \&\n                                ;;\n                          \"8)\") sudo reboot/" /usr/bin/emulationstation/emulationstation.sh /usr/bin/emulationstation/emulationstation.sh.ra /usr/bin/emulationstation/emulationstation.sh.es
	fi

	printf "\nAdd support for .hdv and .HDV to Apple II\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.dsk .DSK .sh .SH .do .DO .po .PO .apple2 .APPLE2 .zip .ZIP/s//<extension>.apple2 .APPLE2 .do .DO .dsk .DSK .hdv .HDV .po .PO .sh .SH .zip .ZIP/' /etc/emulationstation/es_systems.cfg

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08232024"

fi

if [ ! -f "/home/ark/.config/.update09272024" ]; then

	printf "\nChange netplay check frame setting to 10 for rk3326 devices\nUpdate singe.sh to include -texturestream setting\nUpdate daphne.sh to include -texturestream setting\nUpdate netplay.sh\nOptimize hostapd.conf\nAdd Restore ECWolf joystick control tool\nUpdate Backup and Restore ArkOS Settings tools\nUpdate ES to add scraping for vircon32\nUpdate XRoar emulator to version 1.6.5\nFix Kodi 21 crash playing large movies\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09272024/arkosupdate09272024.zip -O /dev/shm/arkosupdate09272024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09272024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09272024.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		sudo unzip -X -o /dev/shm/arkosupdate09272024.zip -d / | tee -a "$LOG_FILE"
	    sudo rm -f /usr/lib/aarch64-linux-gnu/libass.so.9
	    sudo ln -sfv /usr/lib/aarch64-linux-gnu/libass.so.9.2.1 /usr/lib/aarch64-linux-gnu/libass.so.9
	  else
		sudo unzip -X -o /dev/shm/arkosupdate09272024.zip -x usr/lib/aarch64-linux-gnu/libass.so.9.2.1 -d / | tee -a "$LOG_FILE"
	  fi
	  printf "\nAdd PuzzleScript emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'puzzlescript' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09272024.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>piece<\/theme>/{r /home/ark/add_puzzlescript.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/puzzlescript" ]; then
	    mkdir -v /roms/puzzlescript | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/puzzlescript" ]; then
		    mkdir -v /roms2/puzzlescript | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/puzzlescript/s//<path>\/roms2\/puzzlescript/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep puzzlescript | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/puzzlescript\/" ]\; then\n      sudo mkdir \/roms2\/puzzlescript\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npuzzlescript is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep puzzlescript | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/puzzlescript\/" ]\; then\n      sudo mkdir \/roms2\/puzzlescript\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\npuzzlescript is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  printf "\nAdd Vircon32 emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'vircon32' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09272024.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>tvc<\/theme>/{r /home/ark/add_vircon32.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/vircon32" ]; then
	    mkdir -v /roms/vircon32 | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/vircon32" ]; then
		    mkdir -v /roms2/vircon32 | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/vircon32/s//<path>\/roms2\/vircon32/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep vircon32 | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vircon32\/" ]\; then\n      sudo mkdir \/roms2\/vircon32\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nVircon32 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep vircon32 | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/vircon32\/" ]\; then\n      sudo mkdir \/roms2\/vircon32\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nVircon32 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  sudo rm -fv /home/ark/add_vircon32.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/add_puzzlescript.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09272024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09272024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nAdd .m3u and .M3U to supported extensions for Amiga and Amiga CD32\n" | tee -a "$LOG_FILE"
	sed -i '/<extension>.adf .ADF .hdf .HDF .ipf .IPF .lha .LHA .zip .ZIP/s//<extension>.adf .ADF .hdf .HDF .ipf .IPF .lha .LHA .m3u .M3U .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.chd .CHD .cue .CUE .ccd .CCD .lha .LHA .nrg .NRG .mds .MDS .iso .ISO/s//<extension>.ccd .CCD .chd .CHD .cue .CUE .iso .ISO .lha .LHA .m3u .M3U .mds .MDS .nrg .NRG/' /etc/emulationstation/es_systems.cfg

	printf "\nCopy correct libretro puzzlescript core depending on device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  mv -fv /home/ark/.config/retroarch/cores/puzzlescript_libretro.so.rk3326 /home/ark/.config/retroarch/cores/puzzlescript_libretro.so | tee -a "$LOG_FILE"
	else
	  rm -fv /home/ark/.config/retroarch/cores/puzzlescript_libretro.so.rk3326 | tee -a "$LOG_FILE"
	fi

	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  printf "\nChange default netplay check frame setting to 10\n" | tee -a "$LOG_FILE"
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch/retroarch.cfg
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch32/retroarch.cfg
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch/retroarch.cfg.bak
	  sed -i '/netplay_check_frames \=/c\netplay_check_frames \= "10"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	printf "\nInstall and link new SDL 2.0.3000.7 (aka SDL 2.0.30.7)\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.7.rk3566 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.7.rk3566 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.7.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.7.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.7.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.7.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09272024"

fi

if [ ! -f "/home/ark/.config/.update09292024" ]; then

	printf "\nFix SDL 2.30.7 builtin joystick detection issue\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09292024/arkosupdate09292024.zip -O /dev/shm/arkosupdate09292024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate09292024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate09292024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate09292024.zip -x home/ark/ogage-gameforce-chi -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09292024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate09292024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nInstall and link new SDL 2.0.3000.7 (aka SDL 2.0.30.7)\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.7.rk3566 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.7.rk3566 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.7.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.7.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.7.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.7.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.7 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.7 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09292024"

fi

if [ ! -f "/home/ark/.config/.update10252024" ]; then

	printf "\nUpdate emulationstation to exclude menu.scummvm from scraping\nUpdate DS4 Controller config for retroarches\nUpdate Hypseus-Singe to 2.11.3\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10252024/arkosupdate10252024.zip -O /dev/shm/arkosupdate10252024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate10252024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate10252024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate10252024.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate10252024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate10252024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nCopy correct Hypseus-Singe for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi

	# printf "\nCopy correct libretro mednafen psx core depending on device\n" | tee -a "$LOG_FILE"
	# if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  # mv -fv /home/ark/.config/retroarch/cores/mednafen_psx_hw_libretro.so.rk3326 /home/ark/.config/retroarch/cores/mednafen_psx_hw_libretro.so | tee -a "$LOG_FILE"
	# else
	  # rm -fv /home/ark/.config/retroarch/cores/mednafen_psx_hw_libretro.so.rk3326 | tee -a "$LOG_FILE"
	# fi

	# printf "\nAdd mednafen (beetle) psx core as additional core for PSX\n" | tee -a "$LOG_FILE"
	# sed -i '/<core>duckstation<\/core>/s//<core>mednafen_psx_hw<\/core>\n\t          <core>duckstation<\/core>/' /etc/emulationstation/es_systems.cfg

	# printf "\nUpdate openborkeydemon.py\n" | tee -a "$LOG_FILE"
	# sudo sed -i '/pkill OpenBOR/s//sudo kill -9 \$(pgrep -f OpenBOR)/g' /usr/local/bin/openborkeydemon.py

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	touch "/home/ark/.config/.update10252024"

fi

if [ ! -f "/home/ark/.config/.update11272024" ]; then

	printf "\nUpdate GZDoom to 4.13.1\nUpdate PPSSPP to 1.18.1\nUpdated Mupen64plus standalone\nUpdate XRoar to 1.7.1\nFix ScummVM single sd card setup\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11272024/arkosupdate11272024.zip -O /dev/shm/arkosupdate11272024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate11272024.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate11272024.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate11272024.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate11272024.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate11272024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
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

	printf "\nCopy correct mupen64plus standalone for the chipset\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  cp -fv /opt/mupen64plus/mupen64plus-video-GLideN64.so.rk3326 /opt/mupen64plus/mupen64plus-video-GLideN64.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-glide64mk2.so.rk3326 /opt/mupen64plus/mupen64plus-video-glide64mk2.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-video-rice.so.rk3326 /opt/mupen64plus/mupen64plus-video-rice.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-audio-sdl.so.rk3326 /opt/mupen64plus/mupen64plus-audio-sdl.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus.rk3326 /opt/mupen64plus/mupen64plus | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/libmupen64plus.so.2.0.0.rk3326 /opt/mupen64plus/libmupen64plus.so.2.0.0 | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-rsp-hle.so.rk3326 /opt/mupen64plus/mupen64plus-rsp-hle.so | tee -a "$LOG_FILE"
	  cp -fv /opt/mupen64plus/mupen64plus-input-sdl.so.rk3326 /opt/mupen64plus/mupen64plus-input-sdl.so | tee -a "$LOG_FILE"
	  rm -fv /opt/mupen64plus/*.rk3326 | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/mupen64plus/*.rk3326 | tee -a "$LOG_FILE"
	  echo "  Correct Mupen64plus standalone files are already in place for this rk3566 device" | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate exfat kernel module\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo install -m644 -b -D -v /home/ark/exfat.ko.rk3566 /lib/modules/4.19.172/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
	  sudo install -m644 -b -D -v /home/ark/exfat.ko.351 /lib/modules/4.4.189/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo install -m644 -b -D -v /home/ark/exfat.ko.chi /lib/modules/4.4.189/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	else
	  sudo install -m644 -b -D -v /home/ark/exfat.ko.oga /lib/modules/4.4.189/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	fi
	sudo depmod -a
	sudo modprobe -v exfat | tee -a "$LOG_FILE"
	sudo rm -fv /home/ark/exfat.ko.* | tee -a "$LOG_FILE"

	if [ -f "/boot/rk3326-rg351mp-linux.dtb" ]; then
	  printf "\nUpdate emulationstation to add swapping volume button for RGB10X\n" | tee -a "$LOG_FILE"
	  sudo systemctl stop oga_events
	  sudo mv -fv /home/ark/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.351v | tee -a "$LOG_FILE"
	  sudo chmod -v 777 /usr/bin/emulationstation/emulationstation* | tee -a "$LOG_FILE"
	  sudo cp -fv /usr/local/bin/ogage.351mp /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/ogage.351mp | tee -a "$LOG_FILE"
	  sudo systemctl start oga_events
	else
	  printf "\nRemove some unneeded files since this is not a RG351MP/RGB10X unit\n" | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/emulationstation.351v | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/ogage.351mp | tee -a "$LOG_FILE"
	fi

	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  printf "\nFix ScummVM saving issue for Single card SD setup\n" | tee -a "$LOG_FILE"
	  sed -i '/roms2\//s//roms\//g' /home/ark/.config/scummvm/scummvm.ini
	fi

	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  if test -z "$(cat /boot/boot.ini | grep 'vt.global_cursor_default')"
	  then
	    printf "\nDisabling blinking cursor when entering and exiting Emulationstation\n" | tee -a "$LOG_FILE"
		sudo sed -i '/consoleblank\=0/s//consoleblank\=0 vt.global_cursor_default\=0/g' /boot/boot.ini
	  fi
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11272024"

fi

if [ ! -f "/home/ark/.config/.update12242024" ]; then

	printf "\nRevert exfat kernel module update to previous version\nUpdate ScummVM to 2.9.0\nUpdate SDL to 2.30.10\nUpdate Change Ports SDL tool\nUpdate Filebrowser to 2.31.2\nUpdate enable_vibration script\nUpdate daphne.sh and single.sh scripts for RGB30 Unit\nAdd j2me to nes-box and sagabox themes\nUpdate coco.sh to accomodate alternate default controls\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12242024/arkosupdate12242024.zip -O /dev/shm/arkosupdate12242024.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate12242024.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12242024/arkosupdate12242024.z01 -O /dev/shm/arkosupdate12242024.z01 -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate12242024.z01 | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate12242024.zip" ] && [ -f "/dev/shm/arkosupdate12242024.z01" ]; then
	  zip -FF /dev/shm/arkosupdate12242024.zip --out /dev/shm/arkosupdate.zip -fz | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate12242024.z* | tee -a "$LOG_FILE"
	  if test ! -z $(tr -d '\0' < /proc/device-tree/compatible | grep rk3566)
	  then
	    if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
	      sudo unzip -X -o /dev/shm/arkosupdate.zip -x home/ark/sd_fuse/* roms/themes/es-theme-nes-box/* -d / | tee -a "$LOG_FILE"
		else
	      sudo unzip -X -o /dev/shm/arkosupdate.zip -x home/ark/sd_fuse/* roms/themes/es-theme-sagabox/* -d / | tee -a "$LOG_FILE"
		fi
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate.zip -x usr/local/bin/enable_vibration.sh roms/themes/es-theme-sagabox/* -d / | tee -a "$LOG_FILE"
	  fi
	  printf "\nAdd j2me emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'j2me' | tr -d '\0')"
	  then
	    cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09272024.bak | tee -a "$LOG_FILE"
	    sed -i -e '/<theme>puzzlescript<\/theme>/{r /home/ark/add_j2me.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/j2me" ]; then
	    mkdir -v /roms/j2me | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/j2me" ]; then
		    mkdir -v /roms2/j2me | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/j2me/s//<path>\/roms2\/j2me/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep j2me | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/j2me\/" ]\; then\n      sudo mkdir \/roms2\/j2me\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nj2me is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep j2me | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/j2me\/" ]\; then\n      sudo mkdir \/roms2\/j2me\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\nj2me is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  sudo rm -fv /home/ark/add_j2me.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate12242024.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi


	if test ! -z $(tr -d '\0' < /proc/device-tree/compatible | grep rk3566)
	then
      kernel_ver="4.19.172"
	else
      kernel_ver="4.4.189"
	fi
	if [ ! -f "/lib/modules/${kernel_ver}/kernel/fs/exfat/exfat.ko.newer" ]; then
	  printf "\nReverting to previous exfat kernel module\n" | tee -a "$LOG_FILE"
	  sudo cp -fv /lib/modules/${kernel_ver}/kernel/fs/exfat/exfat.ko /lib/modules/${kernel_ver}/kernel/fs/exfat/exfat.ko.newer | tee -a "$LOG_FILE"
	  sudo cp -fv /lib/modules/${kernel_ver}/kernel/fs/exfat/exfat.ko~ /lib/modules/${kernel_ver}/kernel/fs/exfat/exfat.ko | tee -a "$LOG_FILE"
	  sudo depmod -a
	  sudo modprobe -v exfat | tee -a "$LOG_FILE"
	fi

	if test ! -z $(tr -d '\0' < /proc/device-tree/compatible | grep rk3566)
	then
	  printf "\nDownloading Kodi 20.5 to revert Kodi 21.1 to older version to fix streaming addon issues\n" | tee -a "$LOG_FILE"
	  attempt=0
	  while [ ! -f "/dev/shm/Kodi-20.5.tar.xz" ]; do
	    if [ $attempt != 2 ]; then
	     sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12242024/Kodi-20.5.tar.xz -O /dev/shm/Kodi-20.5.tar.xz -a "$LOG_FILE" || sudo rm -f /dev/shm/Kodi-20.5.tar.xz | tee -a "$LOG_FILE"
	     attempt=$((attempt+1))
		else
	     printf "\nCan't download older Kodi 20.5 for some reason.  Skipping this part of the update.  This can be applied in the future if wanted...\n" | tee -a "$LOG_FILE"
	     sudo rm -f /dev/shm/Kodi-20.5.tar.xz
	     break
		fi
	  done
	  if [ -f "/dev/shm/Kodi-20.5.tar.xz" ]; then
	    printf "  Removing existing Kodi version installed but keeping existing addons and settings in place.\n" | tee -a "$LOG_FILE"
	    rm -rf /opt/kodi/lib/kodi/addons/* /opt/kodi/share/kodi/addons/*
	    printf "  Installing Kodi 20.5.  Please wait...\n" | tee -a "$LOG_FILE"
	    tar xf /dev/shm/Kodi-20.5.tar.xz -C /
	    if [ "$(cat ~/.config/.DEVICE)" != "RG503" ]; then
	      sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' /opt/kodi/share/kodi/addons/skin.estuary/addon.xml
	    fi
	    printf "  Done!\n" | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nInstall and link new SDL 2.0.3000.10 (aka SDL 2.0.30.10)\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.10.rk3566 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.10.rk3566 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.10.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.10.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3000.10.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3000.10.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3000.10 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3000.10 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct scummvm for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/scummvm/scummvm.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/scummvm/scummvm.rk3326 /opt/scummvm/scummvm | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ]; then
	  printf "\nFixing fail booting when second sd card is not found or not in the expected format.\n" | tee -a "$LOG_FILE"
	  if [ -f "/opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		sudo chown -R ark:ark /opt
	    sed -i '/noatime,uid\=1002/s//noatime,nofail,x-systemd.device-timeout\=7,uid\=1002/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    sed -i '/defaults 0 1/s//defaults,nofail,x-systemd.device-timeout\=7 0 1/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    sudo sed -i '/none bind/s//none nofail,x-systemd.device-timeout\=7,bind/' /etc/fstab
	  else
        sudo sed -i '/noatime,uid\=1002/s//noatime,nofail,x-systemd.device-timeout\=7,uid\=1002/' /etc/fstab
	    sudo sed -i '/defaults 0 1/s//defaults,nofail,x-systemd.device-timeout\=7 0 1/' /etc/fstab
	    sudo sed -i '/none bind/s//none nofail,x-systemd.device-timeout\=7,bind/' /etc/fstab
	    sudo systemctl daemon-reload && sudo systemctl restart local-fs.target
	  fi
	  sudo sed -i '/noatime,uid\=1002/s//noatime,nofail,x-systemd.device-timeout\=7,uid\=1002/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  sudo sed -i '/defaults 0 1/s//defaults,nofail,x-systemd.device-timeout\=7 0 1/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	  printf "  Done.\n" | tee -a "$LOG_FILE"
	fi

	if [ -e "/dev/input/by-path/platform-odroidgo2-joypad-joystick" ] && [ ! -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]; then
	  printf "\nUpdating uboot to remove uboot version info drawing over boot logo\n" | tee -a "$LOG_FILE"
	  cd /home/ark/sd_fuse
	  sudo dd if=idbloader.img of=/dev/mmcblk0 conv=notrunc bs=512 seek=64 | tee -a "$LOG_FILE"
	  sudo dd if=uboot.img of=/dev/mmcblk0 conv=notrunc bs=512 seek=16384 | tee -a "$LOG_FILE"
	  sudo dd if=trust.img of=/dev/mmcblk0 conv=notrunc bs=512 seek=24576 | tee -a "$LOG_FILE"
	  sync
	  cd /home/ark
	  rm -rfv /home/ark/sd_fuse | tee -a "$LOG_FILE"
	else
	  printf "\nThis is not an oga1.1/rgb10/v10 unit.  No uboot flash needed.\n" | tee -a "$LOG_FILE"
	  if [ -d "/home/ark/sd_fuse" ]; then
	    rm -rfv /home/ark/sd_fuse | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update12242024"

fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.20.0\nUpdate rk3566 kernel with battery reading fix and native rumble support\nUpdate Hypseus-singe to 2.11.4\nUpdate pico8.sh to fix offline carts play via splore\nFix bad freej2me-lr.jar and freej2me-plus-lr.jar files\nAdd vibration support for RK2023\nUpdate Emulationstation\nUpdate batt_life_verbal_warning.py\n" | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate01312025.zip" ]; then
		if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		  if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ] || [ ! -z "$(grep "RK2023" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
			if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
		      sudo unzip -X -o /dev/shm/arkosupdate01312025.zip -x roms/themes/es-theme-nes-box/* -d / | tee -a "$LOG_FILE"
			else
		      sudo unzip -X -o /dev/shm/arkosupdate01312025.zip -x roms/themes/es-theme-sagabox/* -d / | tee -a "$LOG_FILE"
			fi
		  else
		    sudo unzip -X -o /dev/shm/arkosupdate01312025.zip -x usr/local/bin/enable_vibration.sh roms/themes/es-theme-sagabox/* -d / | tee -a "$LOG_FILE"
		  fi
		else
		  sudo unzip -X -o /dev/shm/arkosupdate01312025.zip -x usr/local/bin/enable_vibration.sh roms/themes/es-theme-sagabox/* home/ark/.kodi/addons/script.module.urllib3/* home/ark/rk3566-kernel/* -d / | tee -a "$LOG_FILE"
		fi
	    printf "\nAdd Cave Story emulator\n" | tee -a "$LOG_FILE"
	    if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'cavestory' | tr -d '\0')"
	    then
	      cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update01312025.bak | tee -a "$LOG_FILE"
	      sed -i -e '/<theme>apple2<\/theme>/{r /home/ark/add_cavestory.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	    fi
	    if [ ! -d "/roms/cavestory" ]; then
	      mkdir -v /roms/cavestory | tee -a "$LOG_FILE"
	      if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	      then
		    if [ ! -d "/roms2/cavestory" ]; then
		      mkdir -v /roms2/cavestory | tee -a "$LOG_FILE"
		      sed -i '/<path>\/roms\/cavestory/s//<path>\/roms2\/cavestory/g' /etc/emulationstation/es_systems.cfg
		    fi
	      fi
	    fi
	    if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	      if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep cavestory | tr -d '\0')"
	      then
		    sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/cavestory\/" ]\; then\n      sudo mkdir \/roms2\/cavestory\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	      else
		    printf "\ncavestory is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	      fi
	    fi
	    if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	      if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep cavestory | tr -d '\0')"
	      then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/cavestory\/" ]\; then\n      sudo mkdir \/roms2\/cavestory\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	      else
		    printf "\ncavestory is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	      fi
	    fi
	    sudo rm -fv /home/ark/add_cavestory.txt | tee -a "$LOG_FILE"
	    sudo rm -fv /dev/shm/arkosupdate01312025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate01312025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

    if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
      sudo rm -rf roms/themes/es-theme-nes-box/cavestory/ -d / | tee -a "$LOG_FILE"
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

	if test ! -z $(tr -d '\0' < /proc/device-tree/compatible | grep rk3566)
	then
	  printf "\nDownloading Kodi 21.2 package to update Kodi to 21.1 with streaming addon fixed\n" | tee -a "$LOG_FILE"
	  attempt=0
	  while [ ! -f "/dev/shm/Kodi-21.2.tar.xz" ]; do
	    if [ $attempt != 2 ]; then
	     attempt=$((attempt+1))
		else
	     printf "\nCan't download older Kodi 21.2 for some reason.  Skipping this part of the update.  This can be applied in the future if wanted...\n" | tee -a "$LOG_FILE"
	     break
		fi
	  done
	  if [ -f "/dev/shm/Kodi-21.2.tar.xz" ]; then
	    pip3 install importlib.metadata
	    printf "  Removing existing Kodi version installed but keeping existing addons and settings in place.\n" | tee -a "$LOG_FILE"
	    rm -rf /opt/kodi/lib/kodi/addons/* /opt/kodi/share/kodi/addons/*
	    printf "  Installing Kodi 21.2.  Please wait...\n" | tee -a "$LOG_FILE"
	    tar xf /dev/shm/Kodi-21.2.tar.xz -C /
	    if [ "$(cat ~/.config/.DEVICE)" != "RG503" ]; then
	      sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' /opt/kodi/share/kodi/addons/skin.estuary/addon.xml
	    fi
	    printf "  Done!\n" | tee -a "$LOG_FILE"
	  fi
	fi

	printf "\nCopy correct Hypseus-Singe for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/hypseus-singe/hypseus-singe.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/hypseus-singe/hypseus-singe.rk3326 /opt/hypseus-singe/hypseus-singe | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3566.dtb" ]; then
	    printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	    if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.353 /boot/Image | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-353v.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-353v.dtb.bright /boot/rk3566-OC.dtb.bright | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.353 /boot/Image | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-353m.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-353m.dtb.bright /boot/rk3566-OC.dtb.bright | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rgb30 /boot/Image | tee -a "$LOG_FILE"
	      sudo cp -fv /home/ark/rk3566-kernel/rk3566-rgb30.dtb /usr/local/bin/rgb30dtbs/rk3566-rgb30.dtb.v1 | tee -a "$LOG_FILE"
	      sudo cp -fv /home/ark/rk3566-kernel/rk3566-rgb30-v2.dtb /usr/local/bin/rgb30dtbs/rk3566-rgb30.dtb.v2 | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-rgb30.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RGB20PRO" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rgb20pro /boot/Image | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-rgb20pro.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RK2023" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rk2023 /boot/Image | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-rk2023.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG503" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rg503 /boot/Image | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-rg503.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		fi
		sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
		CURRENT_DTB="$(grep FDT /boot/extlinux/extlinux.conf | cut -c 8-)"
		if [ -f "/home/ark/.config/.BRIGHTDTB" ]; then
		  BASE_DTB_NAME="rk3566-OC.dtb.bright"
		else
		  BASE_DTB_NAME="rk3566-OC.dtb"
		fi
		sudo sed -i "/  FDT \/$CURRENT_DTB/c\  FDT \/${BASE_DTB_NAME}" /boot/extlinux/extlinux.conf
	else
	  sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
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

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187

fi