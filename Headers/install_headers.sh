#!/bin/bash

cd ~

if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-rg351p-linux.dtb" ]; then
  unit="rg351"
elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
  unit="chi"
else
  unit="goa"
fi

wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb || rm -f ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb

if [ ! -f "${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb" ]; then
	printf "\nThe ${unit} linux header deb did not download correctly or is missing. Either rerun this script or manually download it from the git and place it in this current folder then run this script again.\n"
	exit
fi

sudo dpkg -i ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb

# Apply some patches to fix some possible compile issues with gcc 9
cd /usr/src/linux-headers-4.4.189/include/linux/
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/module.patch -O - | sudo patch
if [ $? != 0 ]; then
  echo "There was an error downloading and applying module.patch.  Please run ./install.sh again."
  exit
fi
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/compiler.patch -O - | sudo patch
if [ $? != 0 ]; then
  echo "There was an error downloading and applying compiler.patch.  Please run ./install.sh again."
  exit
fi

# Fix vermagic description so it properly matches
sudo sed -i "/#define UTS_RELEASE/c\#define UTS_RELEASE \"4.4.189\"" /usr/src/linux-headers-4.4.189/include/generated/utsrelease.h

# Install some typically important and handy build tools
sudo apt update -y && sudo apt-get --reinstall install -y build-essential bc bison flex libssl-dev python linux-libc-dev libc6-dev
if [ $? != 0 ]; then
  echo "There was an updating and installing some build tools.  Please make sure your internet is active and stable then run ./install.sh again."
  exit
fi
cd /usr/src/linux-headers-4.4.189/

# This fix dkms Exec format errors
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/headers-debian-byteshift.patch -O - | sudo patch -p1
if [ $? != 0 ]; then
  echo "There was an error downloading and applying headers-debian-byteshift.patch.  Please run ./install.sh again."
  exit
fi
sudo make scripts
if [ $? != 0 ]; then
  echo "There was an error making the header scripts."
  exit
fi
cd ~
rm -f *linux-headers-4.4.189_4.4.189-2_arm64.deb*
echo "All done!"
