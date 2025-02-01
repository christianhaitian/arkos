#!/bin/bash
clear
UPDATE_DATE="02012025-2"
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

if [ ! -f "/home/ark/.config/.update01312025" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.20.0\nUpdate rk3566 kernel with battery reading fix and native rumble support\nUpdate Hypseus-singe to 2.11.4\nUpdate pico8.sh to fix offline carts play via splore\nFix bad freej2me-lr.jar and freej2me-plus-lr.jar files\nAdd vibration support for RK2023\nUpdate Emulationstation\nUpdate batt_life_verbal_warning.py\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01312025/arkosupdate01312025.zip -O /dev/shm/arkosupdate01312025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate01312025.zip | tee -a "$LOG_FILE"
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
	     sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/01312025/Kodi-21.2.tar.xz -O /dev/shm/Kodi-21.2.tar.xz -a "$LOG_FILE" || sudo rm -f /dev/shm/Kodi-21.2.tar.xz | tee -a "$LOG_FILE"
	     attempt=$((attempt+1))
		else
	     printf "\nCan't download older Kodi 21.2 for some reason.  Skipping this part of the update.  This can be applied in the future if wanted...\n" | tee -a "$LOG_FILE"
	     sudo rm -f /dev/shm/Kodi-21.2.tar.xz
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
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-rgb30.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-rgb30-v2.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
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

	touch "/home/ark/.config/.update01312025"

fi

if [ ! -f "/home/ark/.config/.update02012025" ]; then

	printf "\nFix controller issue from last update\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02012025/arkosupdate02012025.zip -O /dev/shm/arkosupdate02012025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02012025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate02012025.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate02012025.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate02012025.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate02012025.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	if [ -f "/boot/rk3566.dtb" ]; then
	    printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	    if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.353 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.353 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rgb30 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RGB20PRO" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rgb20pro /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RK2023" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rk2023 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG503" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rg503 /boot/Image | tee -a "$LOG_FILE"
		fi
		sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
	else
	  sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update02012025"

fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nFix potential battery reading issue from 01312025 update for rk3566 devices\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/02012025-2/arkosupdate02012025-2.zip -O /dev/shm/arkosupdate02012025-2.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate02012025-2.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate02012025-2.zip" ]; then
	  sudo unzip -X -o /dev/shm/arkosupdate02012025-2.zip -d / | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate02012025-2.zip | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate02012025-2.z* | tee -a "$LOG_FILE"
	  sleep 3
	  echo $c_brightness > /sys/class/backlight/backlight/brightness
	  exit 1
	fi

	printf "\nAdd Onscripter_Onsyuri libretro core to Onscripter system\n" | tee -a "$LOG_FILE"
	sed -i -e '/<command>sudo perfmax %GOVERNOR% %ROM%; nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/onscripter_libretro.so %ROM%; sudo perfnorm<\/command>/{r /home/ark/add_onsyuri_onscripter.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	sudo rm -fv /home/ark/add_onsyuri_onscripter.txt | tee -a "$LOG_FILE"

	if [ -f "/boot/rk3566.dtb" ]; then
	    printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	    if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.353 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG353M" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.353 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rgb30 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RGB20PRO" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rgb20pro /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RK2023" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rk2023 /boot/Image | tee -a "$LOG_FILE"
	    elif test ! -z "$(grep "RG503" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rg503 /boot/Image | tee -a "$LOG_FILE"
		fi
		sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
	else
	  sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
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