#!/bin/bash

wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/KernelandHeader/linux-headers-4.4.189_4.4.189-2_arm64.deb || rm -f linux-headers-4.4.189_4.4.189-2_arm64.deb

if [ ! -f "linux-headers-4.4.189_4.4.189-2_arm64.deb" ]; then
	printf "\nThe linux header deb did not download correctly or is missing. Either rerun this script or manually download it from the git and place it in this current folder then run this script again.\n"
	exit
fi

sudo dpkg -i linux-headers-4.4.189_4.4.189-2_arm64.deb
sudo apt update -y && sudo apt-get --reinstall install -y build-essential bc bison flex libssl-dev python linux-libc-dev libc6-dev
cd /usr/src/linux-headers-4.4.189/
wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/arkos/raw/main/KernelandHeader/headers-debian-byteshift.patch -O - | sudo patch -p1
sudo make scripts
cd ~
