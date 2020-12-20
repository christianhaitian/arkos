#!/bin/bash
UPDATE_DATE="${1}"
LOG_FILE="${3}"

if [ ! -f "/home/ark/.config/.update11222020" ]; then

	printf "\nUpdate permissions on cheats and assets folder for retroarch and retroarch32 to fix cheats update\n" | tee -a "$LOG_FILE"
	sudo chown -R ark:ark /home/ark/.config/retroarch/cheats/*
	sudo chown -R ark:ark /home/ark/.config/retroarch32/cheats/*
	sudo chown -R ark:ark /home/ark/.config/retroarch/assets/*
	sudo chown -R ark:ark /home/ark/.config/retroarch32/assets/*
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.2 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth
fi
