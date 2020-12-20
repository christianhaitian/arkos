#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12012020" ]; then

	printf "\nRevert Dreamcast(lr-flycast-rumble), N64(lr-parallel-n64), and PSX (lr-pcsx-rearmed) cores to previous versions...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/pcsx_rearmed_libretro.so -O /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/flycast_rumble_libretro.so -O /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/parallel_n64_libretro.so -O /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/flycast_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/parallel_n64_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/pcsx_rearmed_libretro.so | tee -a "$LOG_FILE"

	printf "\nAdd support for Tic-80 emulator...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/tic80_libretro.so -O /home/ark/.config/retroarch/cores/tic80_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/tic80_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/tic80_libretro.so | tee -a "$LOG_FILE"	
	sudo mkdir -v /roms/tic80 | tee -a "$LOG_FILE"	

	printf "\nInstall updated themes from Jetup(nes-box, switch, epicnoir)..." | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es-theme-nes-box.zip -O /home/ark/es-theme-nes-box.zip -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es-theme-switch.zip -O /home/ark/es-theme-switch.zip -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es-theme-epicnoir.zip -O /home/ark/es-theme-epicnoir.zip -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-nes-box.zip -d /etc/emulationstation/themes/es-theme-nes-box/' | tee -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-switch.zip -d /etc/emulationstation/themes/es-theme-switch/' | tee -a "$LOG_FILE"
	sudo runuser -l ark -c 'unzip -o /home/ark/es-theme-epicnoir.zip -d /etc/emulationstation/themes/es-theme-epicnoir/' | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-nes-box.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-switch.zip | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/es-theme-epicnoir.zip | tee -a "$LOG_FILE"	

	printf "\nUpdate es_systems.cfg to address platform name for famicom to nes and sfc to snes to fix scraping and add tic-80 support...\n" | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12012020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12012020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"

	printf "\nEnsure NDS performance hasn't been impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
fi
