#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update12032020" ]; then

	printf "\nRevert GBA(lr-mgba) core with rumble support to previous version...\n" | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12032020/mgba_libretro.so -O /home/ark/.config/retroarch/cores/mgba_libretro.so -a "$LOG_FILE"
	sudo chmod -v 775 /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"
	sudo chown -v ark:ark /home/ark/.config/retroarch/cores/mgba_libretro.so | tee -a "$LOG_FILE"

	printf "\nAdd Emulationstation menu translation for Portugal...\n" | tee -a "$LOG_FILE"
	sudo mkdir -v /usr/bin/emulationstation/resources/locale/pt/ | tee -a "$LOG_FILE"
	sudo wget https://github.com/christianhaitian/arkos/raw/main/12032020/pt/emulationstation2.po -O /usr/bin/emulationstation/resources/locale/pt/emulationstation2.po -a "$LOG_FILE"
fi
