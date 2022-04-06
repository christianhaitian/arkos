#!/bin/bash

# Let's check and make sure this is not run with sudo or as root
isitroot=$(id -u)
if [ "$isitroot" == "0" ]; then
  printf "\nDon't run me with sudo or as root!"
  printf "  Run me with ./install_headers.sh\n\n"
  exit
fi

cd ~

# Let's download the right header files depending on the supported unit
# Minor differences between the same kernel files between units
# will cause modules to not install. ¯\_(ツ)_/¯
if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-rg351p-linux.dtb" ]; then
  unit="rg351"
elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
  unit="chi"
else
  unit="goa"
fi

wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb \
-O ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb || rm -f ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb

if [ ! -f "${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb" ]; then
	printf "\nThe ${unit} linux header deb did not download correctly or is missing.  "
        printf "Either rerun this script or manually download it from the git and place "
        printf "it in this current folder then run this script again.\n"
	exit
fi

# If a linux header install already exists, get rid of it
dpkg -s "linux-headers-4.4.189"
if [ "$?" == "0" ]; then
  sudo dpkg -P linux-headers-4.4.189
  sudo rm -rf /usr/src/linux-headers-4.4.189
fi

# Now we install the header files
sudo dpkg -i --force-all ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb

# Apply some patches to fix some possible compile issues with gcc 9
cd /usr/src/linux-headers-4.4.189/include/linux/
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/module.patch -O - | sudo patch
if [ $? != 0 ]; then
  printf "\nThere was an error downloading and applying module.patch.  Please run ./install.sh again.\n"
  exit
fi
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/compiler.patch -O - | sudo patch
if [ $? != 0 ]; then
  printf "\nThere was an error downloading and applying compiler.patch.  Please run ./install.sh again.\n"
  exit
fi

# Fix vermagic description so it properly matches
sudo sed -i "/#define UTS_RELEASE/c\#define UTS_RELEASE \"4.4.189\"" /usr/src/linux-headers-4.4.189/include/generated/utsrelease.h

# Install some typically important and handy build tools
sudo apt update -y && sudo apt-get --reinstall install -y build-essential bc bison flex libssl-dev python linux-libc-dev libc6-dev
if [ $? != 0 ]; then
  printf "\nThere was an updating and installing some build tools.  Please make sure your internet is active and stable then run "
  printf "./install.sh again.\n"
  exit
fi
cd /usr/src/linux-headers-4.4.189/

# This fixes dkms Exec format errors due to deb-pkg packing the
# build host executables instead of the target executables
# Credit to loverpi (https://forum.loverpi.com/discussion/555/how-to-fix-dkms-error-bin-sh-1-scripts-basic-fixdep-exec-format-error)
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/headers-debian-byteshift.patch -O - | sudo patch -p1
if [ $? != 0 ]; then
  printf "\nThere was an error downloading and applying headers-debian-byteshift.patch.  Please run ./install.sh again.\n"
  exit
fi

# Let's recompile the header scripts to account for the byteshift change to the header files
sudo make scripts
if [ $? != 0 ]; then
  printf "\nThere was an error making the header scripts.\n"
  exit
fi

cd ~
rm -f ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb
printf "\nAll done!\n"
