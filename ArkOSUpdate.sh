#!/bin/bash
clear
UPDATE_DATE="03292025"
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

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nFix Favorites and Last Played not keeping updates between power on and power off of devices\nUpdate Kodi.sh\nUpdate Russian and add UK translations for ES\nAdd Swedish translations for ES\nUpdate Korean translations\nUpdate NetworkManager to 1.52.0\nFix missing RG503 native rumble support\nAdd retrorun and retrorun32 emulators\nAdd new update script\nAdd Dragon32 and Dragon64 emulation\nAdd Flycast standalone emulator\nUpdate gzdoom\n" | tee -a "$LOG_FILE"
	sudo rm -rf /dev/shm/*
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/03292025/arkosupdate03292025.zip -O /dev/shm/arkosupdate03292025.zip -a "$LOG_FILE" || sudo rm -f /dev/shm/arkosupdate03292025.zip | tee -a "$LOG_FILE"
	if [ -f "/dev/shm/arkosupdate03292025.zip" ]; then
	  if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
		if [ ! -z "$(grep "RGB30" /home/ark/.config/.DEVICE | tr -d '\0')" ]; then
		  sudo unzip -X -o /dev/shm/arkosupdate03292025.zip -x roms/themes/es-theme-nes-box/* -d / | tee -a "$LOG_FILE"
		else
		  sudo unzip -X -o /dev/shm/arkosupdate03292025.zip -x roms/themes/es-theme-sagabox/* -d / | tee -a "$LOG_FILE"
		fi
	  else
	    sudo unzip -X -o /dev/shm/arkosupdate03292025.zip -x usr/local/bin/Kodi.sh -d / | tee -a "$LOG_FILE"
	  fi
	  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update03292025.bak | tee -a "$LOG_FILE"
	  printf "\nAdd dragon32 libretro emulator\n" | tee -a "$LOG_FILE"
	  if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'dragon32' | tr -d '\0')"
	  then
	    sed -i -e '/<theme>thomson<\/theme>/{r /home/ark/add_dragon.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  fi
	  if [ ! -d "/roms/dragon32" ]; then
	    mkdir -pv /roms/dragon32/controls | tee -a "$LOG_FILE"
	    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	    then
		  if [ ! -d "/roms2/dragon32" ]; then
		    mkdir -pv /roms2/dragon32/controls | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/dragon32/s//<path>\/roms2\/dragon32/g' /etc/emulationstation/es_systems.cfg
		  fi
	    fi
	  fi
	  if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep dragon32 | tr -d '\0')"
	    then
		  sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		  sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/dragon32\/" ]\; then\n      sudo mkdir \/roms2\/dragon32\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\ndragon32 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  if [ -f "/usr/local/bin/Switch to SD2 for Roms.sh" ]; then
	    if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep dragon32 | tr -d '\0')"
	    then
		  sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/dragon32\/" ]\; then\n      sudo mkdir \/roms2\/dragon32\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
	    else
		  printf "\ndragon32 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
	    fi
	  fi
	  sed -i '/<name>dreamcast<\/name>/,/<platform>dreamcast<\/platform>/{//!d}' /etc/emulationstation/es_systems.cfg
	  sed -i -e '/<name>dreamcast<\/name>/{r /home/ark/update_dreamcast_retrorun.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		sed -i '/<path>\/roms\/dreamcast/s//<path>\/roms2\/dreamcast/g' /etc/emulationstation/es_systems.cfg
	  fi
	  sed -i '/<name>Sega Atomiswave<\/name>/,/<theme>atomiswave<\/theme>/{//!d}' /etc/emulationstation/es_systems.cfg
	  sed -i -e '/<name>Sega Atomiswave<\/name>/{r /home/ark/update_atomiswave_retrorun.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		sed -i '/<path>\/roms\/atomiswave/s//<path>\/roms2\/atomiswave/g' /etc/emulationstation/es_systems.cfg
	  fi
	  sed -i '/<name>Sega Naomi<\/name>/,/<theme>naomi<\/theme>/{//!d}' /etc/emulationstation/es_systems.cfg
	  sed -i -e '/<name>Sega Naomi<\/name>/{r /home/ark/update_naomi_retrorun.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		sed -i '/<path>\/roms\/naomi/s//<path>\/roms2\/naomi/g' /etc/emulationstation/es_systems.cfg
	  fi
	  sed -i '/<name>Sega Saturn<\/name>/,/<platform>saturn<\/platform>/{//!d}' /etc/emulationstation/es_systems.cfg
	  sed -i -e '/<name>Sega Saturn<\/name>/{r /home/ark/update_saturn_retrorun.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
	  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
	  then
		sed -i '/<path>\/roms\/saturn/s//<path>\/roms2\/saturn/g' /etc/emulationstation/es_systems.cfg
	  fi
	  sudo rm -fv /dev/shm/arkosupdate03292025.zip | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/add_dragon.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/update_atomiswave_retrorun.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/update_dreamcast_retrorun.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/update_naomi_retrorun.txt | tee -a "$LOG_FILE"
	  sudo rm -fv /home/ark/update_saturn_retrorun.txt | tee -a "$LOG_FILE"
	else
	  printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
	  sudo rm -fv /dev/shm/arkosupdate03292025.z* | tee -a "$LOG_FILE"
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

	printf "\nUpdate retrorun.cfg to default swapped triggers to true for rk3326 devices and false for rk3566 devices\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
	  sed -i "/retrorun_swap_l1r1_with_l2r2 \=/c\retrorun_swap_l1r1_with_l2r2 \= true" /home/ark/.config/retrorun.cfg
	else
	  sed -i "/retrorun_swap_l1r1_with_l2r2 \=/c\retrorun_swap_l1r1_with_l2r2 \= false" /home/ark/.config/retrorun.cfg
	fi

	printf "\nCopy correct Flycast standalone emulator for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
      rm -fv /opt/flycastsa/flycast-rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/flycastsa/flycast-rk3326 /opt/flycastsa/flycast | tee -a "$LOG_FILE"
	fi

	if [ -f "/boot/rk3566.dtb" ]; then
	    printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	    if test ! -z "$(grep "RG503" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /home/ark/rk3566-kernel/Image.rg503 /boot/Image | tee -a "$LOG_FILE"
	      sudo mv -fv /home/ark/rk3566-kernel/rk3566-rg503.dtb /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
		  CURRENT_DTB="$(grep FDT /boot/extlinux/extlinux.conf | cut -c 8-)"
	      BASE_DTB_NAME="rk3566-OC.dtb"
		  sudo sed -i "/  FDT \/$CURRENT_DTB/c\  FDT \/${BASE_DTB_NAME}" /boot/extlinux/extlinux.conf
		fi
		sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
	else
	    sudo rm -rfv /home/ark/rk3566-kernel/ | tee -a "$LOG_FILE"
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

	#printf "\nInstall and link new SDL 2.0.3200.0 (aka SDL 2.0.32.0)\n" | tee -a "$LOG_FILE"
	#if [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
	  #sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3200.0.rk3566 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3200.0 | tee -a "$LOG_FILE"
	  #sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3200.0.rk3566 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3200.0 | tee -a "$LOG_FILE"
	  #sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  #sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3200.0 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3200.0 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	#elif [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-r33s-linux.dtb" ] || [ -f "/boot/rk3326-r35s-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  #sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3200.0.rk3326 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3200.0 | tee -a "$LOG_FILE"
	  #sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3200.0.rk3326 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3200.0 | tee -a "$LOG_FILE"
	  #sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  #sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3200.0 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3200.0 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	#else
	  #sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.3200.0.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3200.0 | tee -a "$LOG_FILE"
	  #sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.3200.0.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3200.0 | tee -a "$LOG_FILE"
	  #sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  #sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.3200.0 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  #sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.3200.0 /usr/lib/arm-linux-gnueabihf/libSDL2.so | tee -a "$LOG_FILE"
	#fi

	printf "\nLet's update NetworkManager to 1.52.0\n" | tee -a "$LOG_FILE"
	cd /home/ark/netman
	sudo dpkg -i --force-all *.deb | tee -a "$LOG_FILE"
	cd /home/ark
	sudo rm -rfv /home/ark/netman | tee -a "$LOG_FILE"
	sudo sed -i "/Depends: libaudit1 (>\= 1:2.2.1), libbluetooth3 (>\= 4.91), libc6 (>\= 2.28), libcurl3-gnutls (>\= 7.16.3), libglib2.0-0 (>\= 2.57.2), libgnutls30 (>\= 3.6.5), libjansson4 (>\= 2.0.1), libmm-glib0 (>\= 1.10.0), libndp0 (>\= 1.2), libnewt0.52 (>\= 0.52.20), libnm0 (= 1.52.0-1ubuntu1), libpsl5 (>\= 0.13.0), libreadline7 (>\= 6.0), libselinux1 (>\= 2.0.65), libsystemd0 (>\= 209), libteamdctl0 (>\= 1.9), libudev1 (>\= 183), netplan.io (>\= 1.0~), default-dbus-system-bus | dbus-system-bus, adduser/c\Depends: libaudit1 (>\= 1:2.2.1), libbluetooth3 (>\= 4.91), libc6 (>\= 2.28), libcurl3-gnutls (>\= 7.16.3), libglib2.0-0 (>\= 2.57.2), libgnutls30 (>\= 3.6.5), libjansson4 (>\= 2.0.1), libmm-glib0 (>\= 1.10.0), libndp0 (>\= 1.2), libnewt0.52 (>\= 0.52.20), libnm0 (= 1.52.0-1ubuntu1), libpsl5 (>\= 0.13.0), libselinux1 (>\= 2.0.65), libsystemd0 (>\= 209), libteamdctl0 (>\= 1.9), libudev1 (>\= 183), default-dbus-system-bus | dbus-system-bus, adduser" /var/lib/dpkg/status
	sudo sed -i "/Recommends: ppp, dnsmasq-base, modemmanager, network-manager-pptp, wireless-regdb, wpasupplicant, libpam-systemd, polkitd, udev/c\Recommends: ppp, dnsmasq-base, modemmanager, network-manager-pptp, wireless-regdb, wpasupplicant, libpam-systemd, udev"  /var/lib/dpkg/status

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
	echo "$UPDATE_DATE" > /home/ark/.config/.VERSION

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187

fi