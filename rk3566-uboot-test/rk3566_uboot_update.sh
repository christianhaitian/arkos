#!/bin/bash

if [[ "$(tr -d '\0' < /proc/device-tree/compatible)" == *"rk3326"* ]]; then
  printf "\nThis uboot update is not compatible with rk3326 devices such as this.  Exiting..."
  sleep 3
  exit
fi


dtbm="https://github.com/christianhaitian/arkos/raw/main/rk3566-uboot-test/rk3566-OC.dtb.353m"
dtbv="https://github.com/christianhaitian/arkos/raw/main/rk3566-uboot-test/rk3566-OC.dtb.353v"

printf "\n"
printf "\n"

wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/rk3566-uboot-test/uboot.img -O /dev/shm/uboot.img || rm -f /dev/shm/uboot.img

if [ -f "/dev/shm/uboot.img" ]; then
  if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
    wget -t 3 -T 60 --no-check-certificate ${dtbm} -O /dev/shm/rk3566-OC.dtb || rm -f /dev/shm/rk3566-OC.dtb 
    if [ -f "/dev/shm/rk3566-OC.dtb" ]; then
	  sudo cp -fv /dev/shm/rk3566-OC.dtb /boot/rk3566-OC.dtb
	  sudo rm -fv /dev/shm/rk3566-OC.dtb
	else
      printf "Could not download the default rk3566-OC.dtb for your device.  \nPlease ensure your internet connection is on and reliable and try again."
	  sleep 3
      rm -f /dev/shm/uboot.img
	  exit
	fi
  elif [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
    wget -t 3 -T 60 --no-check-certificate ${dtbv} -O /dev/shm/rk3566-OC.dtb || rm -f /dev/shm/rk3566-OC.dtb
    if [ -f "/dev/shm/rk3566-OC.dtb" ]; then
	  sudo cp -fv /dev/shm/rk3566-OC.dtb /boot/rk3566-OC.dtb
	  sudo rm -fv /dev/shm/rk3566-OC.dtb
	else
      printf "Could not download the default rk3566-OC.dtb for your device.  \nPlease ensure your internet connection is on and reliable and try again."
	  sleep 3
      rm -f /dev/shm/uboot.img
	  exit
	fi
  fi
  sudo cp -fv /dev/shm/uboot.img /usr/local/bin/uboot.img.jelos
  sudo rm -fv /dev/shm/uboot.img
  printf "\nUpdating Uboot.  Please wait...\n"
  sudo dd if=/usr/local/bin/uboot.img.jelos of=/dev/mmcblk1 bs=512 count=8192 seek=16384 status=progress
  printf "\nUboot update completed.  Rebooting now...\n"
  sleep 3
  sudo reboot
else
  printf "\nThe Uboot download failed.  \nPlease retry the this again with reliable internet."
  sleep 3
  exit
fi