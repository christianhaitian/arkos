#!/bin/bash

sudo chmod 666 /dev/tty1
export TERM=linux

# Let's download the right header files depending on the supported unit
# Minor differences between the same kernel files between units
# will cause modules to not install. ¯\_(ツ)_/¯
if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-rg351p-linux.dtb" ]; then
  unit="rg351"
elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
  unit="chi"
elif [ -f "/boot/rk3566.dtb" ]; then
  unit="rg503"
else
  unit="goa"
fi

# Let's check and make sure this is not run with sudo or as root
isitroot=$(id -u)
if [ "$isitroot" == "0" ]; then
  echo "Don't run me with sudo or as root!"
  exit
fi

es_stopped="n"
if test ! -z "$(ps -a | grep pts | tr -d '\0')"
then
  if test ! -z "$(pidof emulationstation | tr -d '\0')"
  then
    sudo systemctl stop emulationstation
    es_stopped="y"
  fi
elif test ! -z "$(ps -a | grep tty | tr -d '\0')"
then
  if test ! -z "$(pidof emulationstation | tr -d '\0')"
  then
    sudo systemctl stop emulationstation
    es_stopped="y"
  fi
fi

GW=`ip route | awk '/default/ { print $3 }'`
if [ -z "$GW" ]; then
  echo "A stable internet connection is needed for this process. \
  Your network connection doesn't seem to be working. \
  Did you make sure to configure your wifi connection?"
  if [[ "$es_stopped" == "y" ]]; then
    sudo systemctl start emulationstation &
  fi
  exit
fi

if [ -f "/home/ark/.config/.devenabled" ]; then
  echo "Developer mode is already enabled on this installation."
  if [[ "$es_stopped" == "y" ]]; then
    sudo systemctl start emulationstation &
  fi
  exit
fi

echo "IF YOU PROCEED WITH ENABLING DEVELOPER MODE, YOUR ROMS PARTITION AND \
IT'S CONTENTS WILL BE DELETED FROM THE MAIN SYSTEM SD!  THE ROMS FOLDER STRUCTURE WILL BE RECREATED ON THE \
EXT PARTITION BUT ALL GAME FILES WILL BE DELETED ON THE MAIN SYSTEM SD.  THE CURRENT ES THEME WILL BE CHANGED \
AS WELL.  DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT \
IN A STATE OF UNUSABILITY.  You've been warned!  Type GODEV in the next screen to proceed."
echo ""
read -p "Enter GODEV here to proceed: " my_var

echo "$my_var"

if [ "$my_var" != "GODEV" ] && [ "$my_var" != "godev" ]; then
  echo "You didn't type GODEV.  This script will exit now and no changes have been made from this process."
  if [[ "$es_stopped" == "y" ]]; then
    sudo systemctl start emulationstation &
  fi
  exit
fi

cd ~

sudo apt -y update && sudo apt -y --fix-broken install && sudo apt -t eoan install -y cloud-guest-utils
if [ "$?" -ne "0" ]; then
  echo "Couldn't install an important package from apt.  Are you connected to the internet?"
  if [[ "$es_stopped" == "y" ]]; then
    sudo systemctl start emulationstation &
  fi
  exit
fi

if [ ! -f "/roms.tar" ]; then
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/defaultromsfolderstructure.tar \
  -O defaultromsfolderstructure.tar || rm -f defaultromsfolderstructure.tar

  if [ ! -f "defaultromsfolderstructure.tar" ]; then
	  echo "The defaultromsfolderstructure.tar did not download correctly or is missing."
      if [[ "$es_stopped" == "y" ]]; then
        sudo systemctl start emulationstation &
      fi
      exit
  fi
fi

sudo umount /opt/system/Tools
sudo umount /roms

if [ "$unit" != "rg503" ]; then
  dev="/dev/mmcblk0"
  ext="/dev/mmcblk0p2"
else
  testforemmc=`lsblk | grep mmcblk0`
  if [ ! -z "$testforemmc" ]; then
    dev="/dev/mmcblk0"
    ext="/dev/mmcblk0p4"
	digit="0"
  else
    dev="/dev/mmcblk1"
    ext="/dev/mmcblk1p4"
	digit="1"
  fi
fi
# Let's delete the existing exfat partition if it exists

if [ "$unit" != "rg503" ]; then
  if test ! -z "$(sudo fdisk -l | grep mmcblkp3 | tr -d '\0')"
  then
    printf "d\n3\nw\nq\n" | sudo fdisk $dev
  fi
else
  if test ! -z "$(sudo fdisk -l | grep mmcblk${digit}p5 | tr -d '\0')"
  then
    printf "d\n5\nw\nq\n" | sudo fdisk $dev
  fi
fi
if [ "$?" -ne "0" ]; then
  echo "Uh oh, something went wrong with trying to delete the exfat partition."
  if [[ "$es_stopped" == "y" ]]; then
   sudo systemctl start emulationstation &
  fi
  exit
fi

# We'll resize the ext partition to take up the rest of the available space
if [ "$unit" != "rg503" ]; then
  sudo growpart -v $dev 2
else
  sudo growpart -v $dev 4
fi
sudo resize2fs $ext

# We'll update /etc/fstab to not try to mount a exfat partition on the main system sd card
if [ "$unit" != "rg503" ]; then
  sudo sed -i "/\/dev\/mmcblk0p3/d" /etc/fstab
else
  sudo sed -i "/\/dev\/mmcblk${digit}p5/d" /etc/fstab  
fi
# Let's recreate the default roms directory structure
mkdir /roms
sudo chown -Rv ark:ark /roms
if [ ! -f "/roms.tar" ]; then
  tar -xvf defaultromsfolderstructure.tar -C /
  rm -fv defaultromsfolderstructure.tar
else
  tar -xvf /roms.tar -C /
  git clone https://github.com/Jetup13/es-theme-freeplay.git /roms/themes/es-theme-freeplay
fi

if [ "$unit" != "rg503" ]; then
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb \
-O ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb || rm -f ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb
else
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb \
-O ${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb || rm -f ${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb
fi

if [ ! -f "${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb" ] && [ ! -f "${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb" ]; then
	echo "The ${unit} linux header deb file did not download correctly or is missing. \
	Either rerun this script or manually download it from the git and place \
	it in this current folder then run this script again."
    if [[ "$es_stopped" == "y" ]]; then
      sudo systemctl start emulationstation &
    fi
    exit
fi

# If a linux header install already exists, get rid of it
dpkg -s "linux-headers-4.4.189"
if [ "$?" == "0" ]; then
  sudo dpkg -P linux-headers-4.4.189
  sudo rm -rf /usr/src/linux-headers-4.4.189
fi

dpkg -s "linux-headers-4.19.172"
if [ "$?" == "0" ]; then
  sudo dpkg -P linux-headers-4.19.172
  sudo rm -rf /usr/src/linux-headers-4.19.172
fi

# Now we install the header files
if [ "$unit" != "rg503" ]; then
  sudo dpkg -i --force-all ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb
else
  sudo dpkg -i --force-all ${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb
fi

# Apply some patches to fix some possible compile issues with gcc 9
if [ "$unit" != "rg503" ]; then
  cd /usr/src/linux-headers-4.4.189/include/linux/
else
  cd /usr/src/linux-headers-4.19.172/include/linux/
fi

if [ "$unit" != "rg503" ]; then
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/module.patch -O - | sudo patch
  if [ $? != 0 ]; then
    echo "There was an error downloading and applying module.patch.  Please run Enable Developer Mode again."
    if [[ "$es_stopped" == "y" ]]; then
      sudo systemctl start emulationstation &
    fi
    exit
  fi
fi

if [ "$unit" != "rg503" ]; then
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/compiler.patch -O - | sudo patch
  if [ $? != 0 ]; then
    echo "There was an error downloading and applying compiler.patch.  Please run Enable Developer Mode again."
    if [[ "$es_stopped" == "y" ]]; then
      sudo systemctl start emulationstation &
    fi
    exit
  fi
fi

if [ "$unit" != "rg503" ]; then
  # Fix vermagic description so it properly matches
  sudo sed -i "/#define UTS_RELEASE/c\#define UTS_RELEASE \"4.4.189\"" /usr/src/linux-headers-4.4.189/include/generated/utsrelease.h
fi

# Install some typically important and handy build tools
sudo apt update -y && sudo apt remove -y build-essential bc bison curl libcurl4-openssl-dev libdrm-dev libsdl2-dev \
flex libssl-dev python linux-libc-dev libc6-dev python3-pip python3-setuptools python3-wheel libasound2-dev \
libsdl2-ttf-2.0-0 libsdl2-ttf-dev libsdl2-mixer-dev libfreeimage-dev

sudo apt -t eoan install -y build-essential bc bison curl libcurl4-openssl-dev libdrm-dev libsdl2-dev flex libssl-dev python \
linux-libc-dev libc6-dev python3-pip python3-setuptools python3-wheel screen libasound2-dev libsdl2-ttf-2.0-0 \
libsdl2-ttf-dev libsdl2-mixer-dev libfreeimage-dev
if [ $? != 0 ]; then
  echo "There was an error updating and installing some build tools.  \
  Please make sure your internet is active and stable then run \
  Enable Developer Mode again."
  if [[ "$es_stopped" == "y" ]]; then
    sudo systemctl start emulationstation &
  fi
  exit
fi
sudo ln -sf /usr/include/libdrm/ /usr/include/drm

cd ~
#Install librga headers
git clone https://github.com/christianhaitian/linux-rga.git
cd linux-rga
git checkout 1fc02d56d97041c86f01bc1284b7971c6098c5fb
sudo mkdir -p /usr/local/include/rga
sudo cp drmrga.h /usr/local/include/rga/
sudo cp rga.h /usr/local/include/rga/
sudo cp RgaApi.h /usr/local/include/rga/
sudo cp RockchipRgaMacro.h /usr/local/include/rga/
cd ~
rm -rf linux-rga

#Install libgo2 development headers
git clone https://github.com/christianhaitian/libgo2.git
sudo mkdir -p /usr/include/go2
sudo cp -L libgo2/src/*.h /usr/include/go2/
rm -rf libgo2

if [ "$unit" != "rg503" ]; then
  cd /usr/src/linux-headers-4.4.189/
else
  cd /usr/src/linux-headers-4.19.172/
fi

# This fixes dkms Exec format errors due to deb-pkg packing the
# build host executables instead of the target executables
# Credit to loverpi (https://forum.loverpi.com/discussion/555/how-to-fix-dkms-error-bin-sh-1-scripts-basic-fixdep-exec-format-error)
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/headers-debian-byteshift.patch -O - | sudo patch -p1
if [ $? != 0 ]; then
  echo "There was an error downloading and applying headers-debian-byteshift.patch.  Please run Enable Developer Mode again."
  if [[ "$es_stopped" == "y" ]]; then
    sudo systemctl start emulationstation &
  fi
  exit
fi

# Let's recompile the header scripts to account for the byteshift change to the header files
sudo make scripts
if [ $? != 0 ]; then
  echo "There was an error making the header scripts."
  if [[ "$es_stopped" == "y" ]]; then
    sudo systemctl start emulationstation &
  fi
  exit
fi

cd ~

# Set the ES Theme to Freeplay in case other themes are no longer available
sed -i "/<string name\=\"ThemeSet\"/c\<string name\=\"ThemeSet\" value\=\"es-theme-freeplay\" \/>" /home/ark/.emulationstation/es_settings.cfg

# Point libSDL2.so back to latest available sdl2 lib
cd /lib/aarch64-linux-gnu/
sudo ln -sf libSDL2-2.0.so.0.2800.2 libSDL2.so
cd ~

if [ "$unit" != "rg503" ]; then
  rm -f ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb
else
  rm -f ${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb
fi

touch /home/ark/.config/.devenabled

echo "All done!"

if [[ "$es_stopped" == "y" ]]; then
  sudo systemctl start emulationstation &
fi
