#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update11272020" ]; then

	printf "\nUpdate emulationstation adding timezone setting in start/advanced settings menu...\n" | tee -a "$LOG_FILE"
	sudo cp -v /usr/bin/emulationstation/emulationstation /usr/bin/emulationstation/emulationstation.update11272020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/emulationstation -O /home/ark/emulationstation -a "$LOG_FILE"
	sudo mv -fv /home/ark/emulationstation /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/timezones -O /usr/local/bin/timezones -a "$LOG_FILE"
	sudo chmod -v 777 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	sudo chmod -v 777 /usr/local/bin/timezones | tee -a "$LOG_FILE"

	printf "\nUpdate retroarch32 to fix loading remap issues...\n" | tee -a "$LOG_FILE"
	mv -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.update11272020.bak | tee -a "$LOG_FILE"
	wget https://github.com/christianhaitian/arkos/raw/main/11272020/retroarch32 -O /opt/retroarch/bin/retroarch32 -a "$LOG_FILE"
	sudo chown -v ark:ark /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	sudo chmod -v 777 /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"

	printf "\nInstall Atari ST...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/hatari_libretro.so -O /home/ark/.config/retroarch/cores/hatari_libretro.so -a "$LOG_FILE"
	if [ ! -d "/home/ark/.hatari/" ]; then
		sudo mkdir -v /home/ark/.hatari | tee -a "$LOG_FILE"
		sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/hatari.cfg -O /home/ark/.hatari/hatari.cfg -a "$LOG_FILE"
		sudo chown -R -v ark:ark /home/ark/.hatari/ | tee -a "$LOG_FILE"	
	fi
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11272020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/es_systems.cfg -O /etc/emulationstation/es_systems.cfg -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/hatari_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/hatari_libretro.so | tee -a "$LOG_FILE"	
	if [ ! -d "/roms/atarist/" ]; then
		sudo mkdir -v /roms/atarist | tee -a "$LOG_FILE"
	fi

	printf "\nInstall lr-vitaquake2 core...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/vitaquake2_libretro.so -O /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch32/cores/vitaquake2_libretro.so | tee -a "$LOG_FILE"
	if [ ! -d "/roms/ports/quake2" ]; then
		sudo mkdir -v /roms/ports/quake2 | tee -a "$LOG_FILE"
		sudo mkdir -v /roms/ports/quake2/baseq2 | tee -a "$LOG_FILE"
		sudo touch /roms/ports/quake2/baseq2/"PUT YOUR PAK FILES HERE" | tee -a "$LOG_FILE"
		sudo mkdir -v /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/ | tee -a "$LOG_FILE"
		sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/vitaQuakeII.rmp -O /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/vitaQuakeII.rmp -a "$LOG_FILE"
		sudo chown -R -v ark:ark /home/ark/.config/retroarch32/config/remaps/vitaQuakeII/ | tee -a "$LOG_FILE"
		sudo wget https://github.com/christianhaitian/arkos/raw/main/11272020/Quake%202.sh -O /roms/ports/"Quake 2".sh -a "$LOG_FILE"		
	fi
	
	printf "\nLet's ensure that Drastic's performance has not been negatively impacted by these updates...\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.3 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
fi
