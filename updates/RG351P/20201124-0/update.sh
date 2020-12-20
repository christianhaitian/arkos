#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update11242020" ]; then

	printf "\nAdd lr-parallel_n64 core with rumble support...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo touch .config/retroarch32/cores/parallel_n64_libretro.so.lck

	printf "\nAdd left analog stick support for pico-8...\n" | tee -a "$LOG_FILE"
	sudo cp -v /roms/bios/pico-8/sdl_controllers.txt /roms/bios/pico-8/sdl_controllers.txt.update$UPDATE_DATE.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/sdl_controllers.txt -O /roms/bios/pico-8/sdl_controllers.txt -a "$LOG_FILE"

	printf "\nAdd option to disable and enable wifi to options/Advanced section for those with internal wifi...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/Enable%20Wifi.sh -O /opt/system/Advanced/"Enable Wifi".sh -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11242020/Disable%20Wifi.sh -O /opt/system/Advanced/"Disable Wifi".sh -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Enable Wifi".sh | tee -a "$LOG_FILE"
	sudo chmod 777 -v /opt/system/Advanced/"Disable Wifi".sh | tee -a "$LOG_FILE"
	sudo chown -R -v ark:ark /opt/system/Advanced | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.3 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
fi
