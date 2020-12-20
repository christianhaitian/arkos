#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12092020" ]; then

	printf "\nAdded non rumble enabled GBA cores (MGBA, VBA-M, VBA-NExt)...\n" | tee -a "$LOG_FILE"
	sudo cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12092020.bak | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12092020/es_systems.cfg -O /home/ark/es_systems.cfg -a "$LOG_FILE"
	if [ -f "/home/ark/es_systems.cfg" ]; then
		sudo mv -v /home/ark/es_systems.cfg /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	fi
	sudo chmod -v 775 /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12092020/mgba_rumble_libretro.so -O /home/ark/.config/retroarch/cores/mgba_rumble_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12092020/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12092020/vbam_libretro.so -O /home/ark/.config/retroarch/cores/vbam_libretro.so -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12092020/vba_next_libretro.so -O /home/ark/.config/retroarch/cores/vba_next_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_rumble_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"	
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/vbam_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/vbam_libretro.so | tee -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/vba_next_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/vba_next_libretro.so | tee -a "$LOG_FILE"
	sudo rm -v /home/ark/.config/retroarch/cores/mgba_libretro.so.lck | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.4 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	printf "\nEnsure systemd-resolved has been reenabled...\n" | tee -a "$LOG_FILE"
	sudo systemctl enable systemd-resolved
	sudo systemctl start systemd-resolved
fi
