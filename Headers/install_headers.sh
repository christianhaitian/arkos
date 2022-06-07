#!/bin/bash

sudo chmod 666 /dev/tty1
export TERM=linux

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  if [[ -e "/boot/rk3326-rg351v-linux.dtb" ]]; then
    sudo rg351p-js2xbox --silent -t oga_joypad &
    sleep 0.5
    sudo ln -s /dev/input/event4 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    sleep 0.5
    sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    export LD_LIBRARY_PATH=/usr/local/bin
  else
    sudo rg351p-js2xbox --silent -t oga_joypad &
    sleep 0.5
    sudo ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    sleep 0.5
    sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
fi

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
  msgbox "Don't run me with sudo or as root! \
  Run me with ./Enable Developer Mode.sh"
  exit
fi

GW=`ip route | awk '/default/ { print $3 }'`
if [ -z "$GW" ]; then
  msgbox "A stable internet connection is needed for this process. \
  Your network connection doesn't seem to be working. \
  Did you make sure to configure your wifi connection?"
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  exit
fi

if [ -f "/home/ark/.config/.devenabled" ]; then
  msgbox "Developer mode is already enabled on this installation."
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  exit
fi

sudo msgbox "IF YOU PROCEED WITH ENABLING DEVELOPER MODE, YOUR ROMS PARTITION AND \
IT'S CONTENTS WILL BE DELETED FROM THE MAIN SYSTEM SD!  THE ROMS FOLDER STRUCTURE WILL BE RECREATED ON THE \
EXT PARTITION BUT ALL GAME FILES WILL BE DELETED ON THE MAIN SYSTEM SD.  THE CURRENT ES THEME WILL BE CHANGED \
AS WELL.  DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT \
IN A STATE OF UNUSABILITY.  You've been warned!  Type GODEV in the next screen to proceed."
my_var=`osk "Enter GODEV here to proceed." | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

if [ "$my_var" != "GODEV" ] && [ "$my_var" != "godev" ]; then
  sudo msgbox "You didn't type GODEV.  This script will exit now and no changes have been made from this process."
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  exit
fi

cd ~

sudo apt -y update && sudo apt install -y cloud-guest-utils
if [ "$?" -ne "0" ]; then
  msgbox "Couldn't install an important package from apt.  Are you connected to the internet?"
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  exit
fi

wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/defaultromsfolderstructure.tar \
-O defaultromsfolderstructure.tar || rm -f defaultromsfolderstructure.tar

if [ ! -f "defaultromsfolderstructure.tar" ]; then
	msgbox "The defaultromsfolderstructure.tar did not download correctly or is missing."
    if [ ! -z $(pidof rg351p-js2xbox) ]; then
      sudo kill -9 $(pidof rg351p-js2xbox)
      sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    fi
	exit
fi

sudo umount /opt/system/Tools
sudo umount /roms

if [ "$unit" != "rg503" ]; then
  dev="/dev/mmcblk0"
  ext="/dev/mmcblk0p2"
else
  dev="/dev/mmcblk1"
  ext="/dev/mmcblk1p4"
fi
# Let's delete the existing exfat partition if it exists

if [ "$unit" != "rg503" ]; then
  if test ! -z "$(sudo fdisk -l | grep mmcblk0p3 | tr -d '\0')"
  then
    printf "d\n3\nw\nq\n" | sudo fdisk $dev
  fi
else
  if test ! -z "$(sudo fdisk -l | grep mmcblk1p5 | tr -d '\0')"
  then
    printf "d\n5\nw\nq\n" | sudo fdisk $dev
  fi
fi
if [ "$?" -ne "0" ]; then
  msgbox "Uh oh, something went wrong with trying to delete the exfat partition."
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
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
  sudo sed -i "/\/dev\/mmcblk1p5/d" /etc/fstab  
fi
# Let's recreate the default roms directory structure
mkdir /roms
sudo chown -Rv ark:ark /roms
tar -xvf defaultromsfolderstructure.tar -C /
rm -fv defaultromsfolderstructure.tar

if [ "$unit" != "rg503" ]; then
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb \
-O ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb || rm -f ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb
else
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb \
-O ${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb || rm -f ${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb
fi

if [ ! -f "${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb" ] && [ ! -f "${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb" ]; then
	msgbox "The ${unit} linux header deb file did not download correctly or is missing. \
	Either rerun this script or manually download it from the git and place \
	it in this current folder then run this script again."
    if [ ! -z $(pidof rg351p-js2xbox) ]; then
      sudo kill -9 $(pidof rg351p-js2xbox)
      sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
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
    msgbox "There was an error downloading and applying module.patch.  Please run Enable Developer Mode again."
    if [ ! -z $(pidof rg351p-js2xbox) ]; then
      sudo kill -9 $(pidof rg351p-js2xbox)
      sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    fi
    exit
  fi
fi

if [ "$unit" != "rg503" ]; then
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/Headers/compiler.patch -O - | sudo patch
  if [ $? != 0 ]; then
    msgbox "There was an error downloading and applying compiler.patch.  Please run Enable Developer Mode again."
    if [ ! -z $(pidof rg351p-js2xbox) ]; then
      sudo kill -9 $(pidof rg351p-js2xbox)
      sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
    fi
    exit
  fi
fi

if [ "$unit" != "rg503" ]; then
  # Fix vermagic description so it properly matches
  sudo sed -i "/#define UTS_RELEASE/c\#define UTS_RELEASE \"4.4.189\"" /usr/src/linux-headers-4.4.189/include/generated/utsrelease.h
fi

# Install some typically important and handy build tools
sudo apt update -y && sudo apt-get --reinstall install -y build-essential bc bison \
flex libssl-dev python linux-libc-dev libc6-dev python3-pip python3-setuptools python3-wheel
if [ $? != 0 ]; then
  msgbox "There was an updating and installing some build tools.  \
  Please make sure your internet is active and stable then run \
  Enable Developer Mode again."
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  exit
fi

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
  msgbox "There was an error downloading and applying headers-debian-byteshift.patch.  Please run Enable Developer Mode again."
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  exit
fi

# Let's recompile the header scripts to account for the byteshift change to the header files
sudo make scripts
if [ $? != 0 ]; then
  msgbox "There was an error making the header scripts."
  if [ ! -z $(pidof rg351p-js2xbox) ]; then
    sudo kill -9 $(pidof rg351p-js2xbox)
    sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
  fi
  exit
fi

cd ~

if [ "$unit" != "rg503" ]; then
  rm -f ${unit}-linux-headers-4.4.189_4.4.189-2_arm64.deb
else
  rm -f ${unit}-linux-headers-4.19.172_4.19.172-17_arm64.deb
fi

touch /home/ark/.config/.devenabled

msgbox "All done!"

if [ ! -z $(pidof rg351p-js2xbox) ]; then
  sudo kill -9 $(pidof rg351p-js2xbox)
  sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
fi
