#!/bin/bash

export TERM=linux

if (( $(cat /sys/class/power_supply/battery/capacity) < 60 )); then
  msgbox "You have less than 60 percent battery life.  Please \
  charge your device to at least 60 percent battery life then \
  launch this tool again."
  exit
fi

msgbox "ONCE YOU PROCEED WITH THIS process, DO NOT STOP THIS PROCESS UNTIL IT IS COMPLETED OR YOUR INTERNAL EMMC MAY BE LEFT IN AN UNUSUABLE STATE.  This process will remove Android from your device and replace it with ArkOS.  You've been warned!  Type OK in the next screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

if [ "$my_var" != "OK" ] && [ "$my_var" != "ok" ]; then
  sudo msgbox "You didn't type OK.  This process will exit now and no changes have been made from this process."
  exit
fi

if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
  unit="353v"
elif [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
  unit="353m"
else
  msgbox "This doesn't seem to be a 353V or 353M unit."
  exit
fi

testforemmc=`lsblk | grep mmcblk0`
if [ -z "$testforemmc" ]; then
  if [ -f "/home/ark/.config/.newdtb" ]; then
    msgbox "I can't seem to locate an emmc on this device. \
	Either this device does not have one or the one in this device \
	may be damaged."
    exit
  fi
  GW=`ip route | awk '/default/ { print $3 }'`
  if [ -z "$GW" ]; then
    msgbox "A stable internet connection is needed for this process. \
    Your network connection doesn't seem to be working. \
    Did you make sure to configure your wifi connection?"
    exit
  fi
  printf "\nInstalling updated dtb to be able to access the emmc.  Please wait...\n"
  dialog --clear
  dialog --infobox "Installing updated dtb to be able to access the emmc, please wait..." 10 50
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/353_emmc/rk3566-OC.dtb.${unit} -O /dev/shm/rk3566-OC.dtb.${unit} || rm -f /dev/shm/rk3566-OC.dtb.${unit}
  if [ -f "/dev/shm/rk3566-OC.dtb.${unit}" ]; then
    sudo cp -f /dev/shm/rk3566-OC.dtb.${unit} /boot/rk3566-OC.dtb
    touch /home/ark/.config/.newdtb
    dialog --clear
    msgbox "An udpated dtb file from the ArkOS github was successfully downloaded. \
	For the change to take effect, your unit must be rebooted.  Please run this script \
	again when the unit has been rebooted and you have a stable internet connection."
	sudo reboot
  else
    dialog --clear
    msgbox "Couldn't download an updated dtb file from the ArkOS github.  Please verify your \
	internet connection is stable and run this script again."
	exit
  fi
fi

dpkg -s "pv" &> /dev/null
if [ "$?" != "0" ]; then
  GW=`ip route | awk '/default/ { print $3 }'`
  if [ -z "$GW" ]; then
    msgbox "A stable internet connection is needed for this process. \
    Your network connection doesn't seem to be working. \
    Did you make sure to configure your wifi connection?"
    exit
  fi
  printf "\nInstalling pv.  Please wait...\n"
  dialog --infobox "Installing pv, please wait..." 10 50
  sudo apt -y update && sudo apt -t eoan install -y pv
fi

image=`find /roms/backup/ -name "*_emmc.img" | head -n 1`
if [ -z "$image" ]; then
  image=`find /roms2/backup/ -name "*_emmc.img" | head -n 1`
fi
if [ -z "$image" ]; then
  dialog --clear
  msgbox "An image to flash to your emmc couldn't be found. \
  Make you've copied one to your backup folder on your sd \
  card."
  exit
fi

printf "\nGrabing the md5sum info for authentication purposes.  Please wait...\n"
dialog --clear
dialog --infobox "Grabing the md5sum info for authentication purposes, please wait..." 10 50
rm -f /dev/shm/md5sum
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/353_emmc/md5sum -O /dev/shm/md5sum || rm -f /dev/shm/md5sum
if [ -f "/dev/shm/md5sum" ]; then
  short_rgm="$(grep -i 353m /dev/shm/md5sum | awk '{ print $3 }')"
  short_rgv="$(grep -i 353v /dev/shm/md5sum | awk '{ print $3 }')"
  complete_rgm="$(grep -i 353m /dev/shm/md5sum | awk '{ print $2 }')"
  complete_rgv="$(grep -i 353v /dev/shm/md5sum | awk '{ print $2 }')"
else
  dialog --clear
  msgbox "Could not download the md5sum from the ArkOS github.  Please verify your \
  internet connection is stable and run this script again."
  exit
fi

if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
  if [ "$(head -c 1M $image | md5sum | awk '{ print $1 }')" != "$short_rgv" ]; then
    dialog --clear
    msgbox "The md5sum of the emmc image found is not correct for this unit. \
	Please download and copy the correct emmc image for this unit. \
    The correct md5sum should be: $complete_rgv"
    exit
  fi
else
  if [ "$(head -c 1M $image | md5sum | awk '{ print $1 }')" != "$short_rgm" ]; then
    dialog --clear
    msgbox "The md5sum of the emmc image found is not correct for this unit. \
	Please download and copy the correct emmc image for this unit. \
    The correct md5sum should be: $complete_rgm"
    exit
  fi
fi

printf "\nWriting the ArkOS image to emmc, please wait...\n"
dialog --clear
(pv -n "$image" | sudo dd of=/dev/mmcblk0 bs=1M) 2>&1 | dialog --gauge "Writing the ArkOS image to emmc, please wait..." 10 50 0
dialog --clear
dialog --infobox "Updating some scripts and copying some settings to the linux partition of the internal emmc, please wait..." 10 50
sudo mount /dev/mmcblk0p4 /mnt/usbdrive
# Fix light and deep sleep scripts
sudo sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/usr/local/bin/Sleep\ -\ Switch\ to\ *
sed -i 's/mmcblk1/mmcblk0/' /mnt/usbdrive/opt/system/Advanced/Sleep\ -\ Switch\ to\ *
# Fix BaRT
sudo sed -i 's/event_num=\"3\"/if [[ -e \"\/dev\/input\/by-path\/platform-fe5b0000.i2c-event\" ]]; then\n  event_num=\"4\"\nelse\n  event_num=\"3\"\nfi/g' /mnt/usbdrive/usr/bin/emulationstation/emulationstation.sh*
# Fix some exit hotkeys
sudo sed -i '/\/dev\/input\/event3/s//\/dev\/input\/event4/g' /mnt/usbdrive/usr/local/bin/*.py
# Remove experimental touch scripts as touch is enabled by default now
sudo rm -f /mnt/usbdrive/opt/system/Advanced/Enable\ Experimental\ Touch\ support.sh
sudo rm -Rf /mnt/usbdrive/usr/local/bin/experimental/
# Copy some settings over that shouldn't intefere with the intial setup process
cp -f /home/ark/.config/panel_settings.txt /mnt/usbdrive/home/ark/.config/panel_settings.txt
cp -Rf /home/ark/.kodi/* /mnt/usbdrive/home/ark/.kodi/
cp -f /opt/drastic/config/drastic.cfg /mnt/usbdrive/opt/drastic/config/drastic.cfg 
cp -f /home/ark/.emulationstation/es_settings.cfg /mnt/usbdrive/home/ark/.emulationstation/es_settings.cfg
cp -Rf /home/ark/.emulationstation/collections/* /mnt/usbdrive/home/ark/.emulationstation/collections/
sudo cp -f /etc/localtime /mnt/usbdrive/etc/localtime
sudo cp -Rf /etc/NetworkManager/system-connections/* /mnt/usbdrive/etc/NetworkManager/system-connections/
sudo umount /mnt/usbdrive/
dialog --clear
msgbox "Done.  Please reboot without a SD card in slot 1 to boot into ArkOS from emmc.  If you'd like to \
load Android back onto the internal memory, check out GammaOS-RK3566 by TheGammaSqueeze.  If you'd like to load the original stock \
Android OS, check out the GammaOS-RK3566 github page for information on how to reinstall the stock Android OS."
