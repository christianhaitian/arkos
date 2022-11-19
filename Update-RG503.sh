#!/bin/bash
clear
UPDATE_DATE="11182022"
LOG_FILE="/home/ark/update$UPDATE_DATE.log"
UPDATE_DONE="/home/ark/.config/.update$UPDATE_DATE"

if [ -f "$UPDATE_DONE" ]; then
	msgbox "No more updates available.  Check back later."
	rm -- "$0"
	exit 187
fi

if [ -f "$LOG_FILE" ]; then
	sudo rm "$LOG_FILE"
fi

LOCATION="http://gitcdn.link/cdn/christianhaitian/arkos/main"
ISITCHINA="$(curl -s --connect-timeout 30 -m 60 http://demo.ip-api.com/json | grep -Po '"country":.*?[^\\]"')"

if [ "$ISITCHINA" = "\"country\":\"China\"" ]; then
  printf "\n\nSwitching to China server for updates.\n\n" | tee -a "$LOG_FILE"
  LOCATION="http://139.196.213.206/arkos"
fi

sudo msgbox "ONCE YOU PROCEED WITH THIS UPDATE SCRIPT, DO NOT STOP THIS SCRIPT UNTIL IT IS COMPLETED OR THIS DISTRIBUTION MAY BE LEFT IN A STATE OF UNUSABILITY.  Make sure you've created a backup of this sd card as a precaution in case something goes very wrong with this process.  You've been warned!  Type OK in the next screen to proceed."
my_var=`osk "Enter OK here to proceed." | tail -n 1`

echo "$my_var" | tee -a "$LOG_FILE"

if [ "$my_var" != "OK" ] && [ "$my_var" != "ok" ]; then
  sudo msgbox "You didn't type OK.  This script will exit now and no changes have been made from this process."
  printf "You didn't type OK.  This script will exit now and no changes have been made from this process." | tee -a "$LOG_FILE"
  exit 187
fi

c_brightness="$(cat /sys/class/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/class/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update06012022" ]; then

	printf "\nAdd Bluetooth Manager\nBluetooth fixes\nFix Neo Geo Pocket and Neo Geo Pocket Color not launching\nAdd Bluetooth identification to Emulationstation start menu\nAdd Bluetooth trigger to F button at bottom of device\nFix exfat permissions issue\nFix .ecwolf files not recognized for Wolfenstein\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06012022/arkosupdate06012022.zip -O /home/ark/arkosupdate06012022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06012022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06012022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06012022.zip -d / | tee -a "$LOG_FILE"
		sudo mv /etc/systemd/system/bluetooth.service /etc/systemd/system/enable_bluetooth.service
		sudo systemctl daemon-reload
		sudo systemctl restart enable_bluetooth
		sudo systemctl enable enable_bluetooth
		sudo apt update -y | tee -a "$LOG_FILE"
		sudo apt remove -y bluez | tee -a "$LOG_FILE"
		sudo apt install -y bluez | tee -a "$LOG_FILE"
		sudo systemctl restart bluetooth
		sudo systemctl enable bluetooth
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06012022.bak | tee -a "$LOG_FILE"
		if test ! -z "$(grep "mednafen_ngp_libretro.so" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		then
			cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06012022.bak | tee -a "$LOG_FILE"
			sed -i 's/<core>mednafen_ngp_libretro.so<\/core>/<core>mednafen_ngp<\/core>/' /etc/emulationstation/es_systems.cfg
		fi
		sed -i '/<extension>.wolf .WOLF/s//<extension>.wolf .WOLF .ecwolf .ECWOLF/' /etc/emulationstation/es_systems.cfg
		sudo sed -i 's/exfat defaults,auto,umask=000,noatime 0 0/exfat defaults,auto,umask=000,uid=1002,gid=1002,noatime 0 0/' /etc/fstab
		sudo sed -i 's/exfat umask=0000,iocharset=utf8,noatime 0 0/exfat umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /etc/fstab
		sudo sed -i 's/umask=0000,iocharset=utf8,noatime 0 0/umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		sudo sed -i 's/umask=0000,iocharset=utf8,noatime 0 0/umask=0000,iocharset=utf8,uid=1002,gid=1002,noatime 0 0/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		sudo rm -v /home/ark/arkosupdate06012022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06012022"
fi

if [ ! -f "/home/ark/.config/.update06032022" ]; then

	printf "\nFix ES user decides on conflicts crash\nUpdate Emulationstation gui menus to be full screen via hdmi\nUpdate enable_rumble script\nAdd Rumble for gba,psx,pokemini and parallel-n64\nRemove ppsspp-stock\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06032022/arkosupdate06032022.zip -O /home/ark/arkosupdate06032022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06032022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06032022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06032022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06032022.bak | tee -a "$LOG_FILE"
		sed -i '/<emulator name="standalone-stock">/{N;d;}' /etc/emulationstation/es_systems.cfg
		sudo rm -f -v /opt/ppsspp/PPSSPPSDL-STOCK | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate06032022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nAdd widescreen mode support for mupen64plus-glide64mk2\n" | tee -a "$LOG_FILE"
	if test -z "$(grep '<core>Default_Aspect' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	then
	  sed -i '/<emulator name="standalone-Glide64mk2">/c\              <emulator name="standalone-Glide64mk2">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06032022"
fi

if [ ! -f "/home/ark/.config/.update06082022" ]; then

	printf "\nPython fixes\nFix volume control for Kodi\nAdd Select and Start to kill Kodi\nAdd retroarch-tate for Arcade\nAdd mame2003_plus to Arcade in ES\nRebuild retroarch and retroarch32 1.10.3\nMove Kodi to ES start menu\nUpdate Backup Settings.sh\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06082022/arkosupdate06082022.zip -O /home/ark/arkosupdate06082022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06082022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06082022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06082022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06082022.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'name="retroarch-tate"' | tr -d '\0')"
		then
		  sed -i '/<core>fbalpha2018<\/core>/c\\t\t \t  <core>fbalpha2018<\/core>\n\t\t \t<\/cores>\n\t\t      <\/emulator>\n\t\t      <emulator name\=\"retroarch-tate\">\n\t\t \t<cores>\n\t\t \t  <core>fbneo<\/core>\n\t\t \t  <core>mame2003_plus<\/core>' /etc/emulationstation/es_systems.cfg
		  sed -i '/<core>fbalpha2012<\/core>/c\\t\t\t  <core>fbalpha2012<\/core>\n\t\t\t  <core>mame2003_plus<\/core>' /etc/emulationstation/es_systems.cfg
		fi
		sed -i '/mame2003-plus_skip_disclaimer \=/c\mame2003-plus_skip_disclaimer \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/mame2003-plus_skip_disclaimer \=/c\mame2003-plus_skip_disclaimer \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/mame2003-plus_skip_warnings \=/c\mame2003-plus_skip_warnings \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/mame2003-plus_skip_warnings \=/c\mame2003-plus_skip_warnings \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/reicast_anisotropic_filtering \=/c\reicast_anisotropic_filtering \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/reicast_anisotropic_filtering \=/c\reicast_anisotropic_filtering \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/reicast_anisotropic_filtering \=/c\reicast_anisotropic_filtering \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
		sed -i '/reicast_anisotropic_filtering \=/c\reicast_anisotropic_filtering \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg.bak
		sed -i '/reicast_enable_dsp \=/c\reicast_enable_dsp \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/reicast_enable_dsp \=/c\reicast_enable_dsp \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/reicast_enable_dsp \=/c\reicast_enable_dsp \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
		sed -i '/reicast_enable_dsp \=/c\reicast_enable_dsp \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg.bak
		sed -i '/reicast_enable_rtt \=/c\reicast_enable_rtt \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/reicast_enable_rtt \=/c\reicast_enable_rtt \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/reicast_enable_rtt \=/c\reicast_enable_rtt \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
		sed -i '/reicast_enable_rtt \=/c\reicast_enable_rtt \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg.bak
		sed -i '/reicast_frame_skipping \=/c\reicast_frame_skipping \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/reicast_frame_skipping \=/c\reicast_frame_skipping \= "disabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/reicast_frame_skipping \=/c\reicast_frame_skipping \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
		sed -i '/reicast_frame_skipping \=/c\reicast_frame_skipping \= "disabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg.bak
		sed -i '/reicast_internal_resolution \=/c\reicast_internal_resolution \= "640x480"' /home/ark/.config/retroarch/retroarch-core-options.cfg
		sed -i '/reicast_internal_resolution \=/c\reicast_internal_resolution \= "640x480"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
		sed -i '/reicast_internal_resolution \=/c\reicast_internal_resolution \= "640x480"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
		sed -i '/reicast_internal_resolution \=/c\reicast_internal_resolution \= "640x480"' /home/ark/.config/retroarch32/retroarch-core-options.cfg.bak
		sudo rm -v /roms2/tools/Kodi.sh /roms/tools/Kodi.sh | tee -a "$LOG_FILE"
		sudo tar -v --delete -f /roms.tar "roms/tools/Kodi.sh" | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate06082022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate retroarch and retroarch32 core repo locations for rg503\n" | tee -a "$LOG_FILE"
	sed -i '/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= "https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503/arm7hf\/"' /home/ark/.config/retroarch32/retroarch.cfg
	sed -i '/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= "https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503/arm7hf\/"' /home/ark/.config/retroarch32/retroarch.cfg.bak
	sed -i '/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= "https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503/aarch64\/"' /home/ark/.config/retroarch/retroarch.cfg
	sed -i '/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= "https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503/aarch64\/"' /home/ark/.config/retroarch/retroarch.cfg.bak

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06082022"
fi

if [ ! -f "/home/ark/.config/.update06092022" ]; then

	printf "\nCorrect tigerlcd theme name in ES\nUpdated ThemeMaster\nUpdated nes-box theme to include cdi and tigerlcd\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06092022/arkosupdate06092022.zip -O /home/ark/arkosupdate06092022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06092022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06092022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06092022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06092022.bak | tee -a "$LOG_FILE"
		sed -i 's/<theme>tiger<\/theme>/<theme>tigerlcd<\/theme>/' /etc/emulationstation/es_systems.cfg
		sudo tar -v --delete -f /roms.tar "roms/tools/ThemeMaster/"
		sudo tar -v --delete -f /roms.tar "roms/tools/ThemeMaster.sh"
		sudo tar -v --append -f /roms.tar "/roms/tools/ThemeMaster/"
		sudo tar -v --append -f /roms.tar "/roms/tools/ThemeMaster.sh"
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  cp -R -f -v /roms/tools/ThemeMaster/ /roms2/tools/ | tee -a "$LOG_FILE"
		  cp -f -v /roms/tools/ThemeMaster.sh /roms2/tools/  | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/arkosupdate06092022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06092022"
fi

if [ ! -f "/home/ark/.config/.update06102022" ]; then

	printf "\nFix virtual boy retroarch not loading from ES\nChanged default for NDS dual screen to horizontal\nUpdate ES for display settings icon\nUpdated ArkOS Carbon theme display settings icon\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06102022/arkosupdate06102022.zip -O /home/ark/arkosupdate06102022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06102022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06102022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06102022.zip -d / | tee -a "$LOG_FILE"
		if test ! -z "$(grep "mednafen_vb_libretro.so" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		then
			cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06102022.bak | tee -a "$LOG_FILE"
			sed -i 's/<core>mednafen_vb_libretro.so<\/core>/<core>mednafen_vb<\/core>/' /etc/emulationstation/es_systems.cfg
		fi
		if test ! -z "$(grep "screen_orientation = 2" /opt/drastic/config/drastic.cfg | tr -d '\0')"
		then
			sed -i 's/screen_orientation \= 2/screen_orientation \= 1/' /opt/drastic/config/drastic.cfg
		fi
		sudo rm -v /home/ark/arkosupdate06102022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06102022"
fi

if [ ! -f "/home/ark/.config/.update06172022" ]; then

	printf "\nUpdate bluetooth script\nFix wifi script activate existing connection error\nFix Solarus\nAdd controller_setup.sh script\nAdd stanadalone-stock\nFix SGB in ES\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06172022/arkosupdate06172022.zip -O /home/ark/arkosupdate06172022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06172022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06172022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06172022.zip -d / | tee -a "$LOG_FILE"
		if test -z "$(grep "mgba_libretro.so" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		then
		  sed -i -zE 's/<\/extension>([^\n]*\n[^\n]*<platform>sgb<\/platform>)/<\/extension>\n\t\t<command>sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/mgba_libretro.so %ROM%; sudo perfnorm<\/command>\1/' /etc/emulationstation/es_systems.cfg
		fi
		#if test -z "$(grep "standalone-stock" /etc/emulationstation/es_systems.cfg | tr -d '\0')"
		#then
		#  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update06172022.bak | tee -a "$LOG_FILE"
		#  sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>psp<\/platform>)/   <emulator name=\"\standalone-stock\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		#  sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>psp<\/platform>[^\n]*\n[^\n]*<theme>pspminis<\/theme>)/   <emulator name=\"\standalone-stock\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		#fi
		sudo apt -y update && sudo apt -y install inotify-tools | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate06172022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06172022"
fi

if [ ! -f "/home/ark/.config/.update06182022" ]; then

	printf "\nFix mupen64plus standalone glide64mk2 default aspect ratio\nAdd Italian language for ES\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06182022/arkosupdate06182022.zip -O /home/ark/arkosupdate06182022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06182022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06182022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06182022.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate06182022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06182022"
fi

if [ ! -f "/home/ark/.config/.update06232022" ]; then

	printf "\nUpdate volume control\nUpdate Kodi launch script\nAdjusted poll interval for timesync\nFixed retroarch32 script for ext controllers\nUpdate gamecontrollerdb files\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06232022/arkosupdate06232022.zip -O /home/ark/arkosupdate06232022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06232022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06232022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06232022.zip -d / | tee -a "$LOG_FILE"
		if test -z "$(grep "PollIntervalMinSec=60" /etc/systemd/timesyncd.conf | tr -d '\0')"
		then
		  sudo sed -i '$aPollIntervalMinSec=60' /etc/systemd/timesyncd.conf
		  sudo sed -i '$aPollIntervalMaxSec=3600' /etc/systemd/timesyncd.conf
		fi
		sudo rm -v /home/ark/arkosupdate06232022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06232022"
fi

if [ ! -f "/home/ark/.config/.update06242022" ]; then

	printf "\nUpdate yabasanshiro standalone to 1.9.0\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06242022/arkosupdate06242022.zip -O /home/ark/arkosupdate06242022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06242022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06242022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate06242022.zip -d / | tee -a "$LOG_FILE"
		sudo sed -i 's/oga_controls yabasanshiro/oga_controls yaba/' /usr/local/bin/saturn.sh
		sudo rm -v /home/ark/arkosupdate06242022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct yabasanshiro for device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ] && [ ! -f "/boot/rk3566.dtb" ]; then
	  if [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
	    cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  else
	    cp -fv /opt/yabasanshiro/yabasanshiro.oga /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	    rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	  fi
	else
	  cp -fv /opt/yabasanshiro/yabasanshiro.640 /opt/yabasanshiro/yabasanshiro | tee -a "$LOG_FILE"
	  rm -fv /opt/yabasanshiro/yabasanshiro.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06242022"
fi

if [ ! -f "/home/ark/.config/.update06262022" ]; then

	printf "\nUpdate Kodi to Kodi19 64bit\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06262022/arkosupdate06262022.zip -O /home/ark/arkosupdate06262022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06262022.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/06262022/arkosupdate06262022.z01 -O /home/ark/arkosupdate06262022.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate06262022.z01 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate06262022.zip" ] && [ -f "/home/ark/arkosupdate06262022.z01" ]; then
		sudo rm -rfv /opt/kodi | tee -a "$LOG_FILE"
		zip -FF /home/ark/arkosupdate06262022.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate06262022.z* | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update06262022"
fi

if [ ! -f "/home/ark/.config/.update07012022" ]; then

	printf "\nUpdate ES to fix background music when returning from Kodi\nUpdated scummvm.sh script for scan of new games\nAdd missing shaders folder for some scummvm games\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07012022/rg503/arkosupdate07012022.zip -O /home/ark/arkosupdate07012022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07012022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07012022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07012022.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate07012022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07012022"
fi

if [ ! -f "/home/ark/.config/.update07042022" ]; then

	printf "\nUpdate Mupen64plus standalone build with tuning for rg503\nAdd support for 4:3 aspect ratio for mupen64plus standalone rice video plugin\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07042022/arkosupdate07042022.zip -O /home/ark/arkosupdate07042022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07042022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07042022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07042022.zip -d / | tee -a "$LOG_FILE"
		if test -z "$(grep "ResolutionWidth" /home/ark/.config/mupen64plus/mupen64plus.cfg | tr -d '\0')"
		then
		  sed -i "/\[Video-Rice\]/c\\[Video-Rice\]\n\n\# Hack to accomodate widescreen devices (Thanks to AmberElec sources for tip)\nResolutionWidth \= 960" /home/ark/.config/mupen64plus/mupen64plus.cfg
		fi
		if [ $(grep -c '<core>Default_Aspect' /etc/emulationstation/es_systems.cfg | tr -d '\0') -lt 2 ]; then 
		  cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07042022.bak | tee -a "$LOG_FILE"
		  sed -i '/<emulator name="standalone-Rice">/c\              <emulator name="standalone-Rice">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>' /etc/emulationstation/es_systems.cfg
		fi
		sudo rm -v /home/ark/arkosupdate07042022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07042022"
fi

if [ ! -f "/home/ark/.config/.update07302022" ]; then

	printf "\nUpdate PPSSPPSDL to 1.13.1\nUpdate OpenBOR\nUpdate Hypseus-Singe to 2.8.2c\nUpdate OpenBOR launcher script\nFix Retroarch restore scripts\nUpdate Retroarches to fix external controller issues\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07302022/rg503/arkosupdate07302022.zip -O /home/ark/arkosupdate07302022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07302022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07302022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07302022.zip -d / | tee -a "$LOG_FILE"
		sed -i "/input_max_users = \"/c\\input_max_users = \"8\"" /home/ark/.config/retroarch/retroarch.cfg
		sed -i "/input_max_users = \"/c\\input_max_users = \"8\"" /home/ark/.config/retroarch/retroarch.cfg.bak
		sed -i "/input_max_users = \"/c\\input_max_users = \"8\"" /home/ark/.config/retroarch32/retroarch.cfg
		sed -i "/input_max_users = \"/c\\input_max_users = \"8\"" /home/ark/.config/retroarch32/retroarch.cfg.bak
		sed -i "/all_users_control_menu = \"/c\\all_users_control_menu = \"true\"" /home/ark/.config/retroarch/retroarch.cfg
		sed -i "/all_users_control_menu = \"/c\\all_users_control_menu = \"true\"" /home/ark/.config/retroarch/retroarch.cfg.bak
		sed -i "/all_users_control_menu = \"/c\\all_users_control_menu = \"true\"" /home/ark/.config/retroarch32/retroarch.cfg
		sed -i "/all_users_control_menu = \"/c\\all_users_control_menu = \"true\"" /home/ark/.config/retroarch32/retroarch.cfg.bak
		sudo rm -v /home/ark/arkosupdate07302022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07302022"
fi

if [ ! -f "/home/ark/.config/.update08222022" ]; then

	printf "\nFix some mali driver issues\nAdd gliden64 video plugin for mupen64plus standalone\nFix retroarch rga scaling\nUpdate mupen64plus, hypseus, ppsspp, and yabasanshirosa\nChange default governor for hypseus and singe to performance\nAdd Duckstation Standalone\nUpdate emulationstation\nDefault ports governor to performance\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08222022/rg503/arkosupdate08222022.zip -O /home/ark/arkosupdate08222022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08222022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08222022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate08222022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08222022.bak | tee -a "$LOG_FILE"
		cd /usr/local/lib/aarch64-linux-gnu/
		sudo rm -v libMali.so
		sudo rm -v libEGL.so*
		sudo rm -v libGLES*
		sudo rm -v libgbm.so*
		sudo rm -v libmali.so*
		sudo rm -v libMali*
		sudo rm -v libOpenCL*
		sudo rm -v libwayland-egl*
		cd /usr/local/lib/arm-linux-gnueabihf/
		sudo rm -v libMali.so
		sudo rm -v libEGL.so*
		sudo rm -v libGLES*
		sudo rm -v libgbm.so*
		sudo rm -v libmali.so*
		sudo rm -v libMali*
		sudo rm -v libOpenCL*
		sudo rm -v libwayland-egl*
		cd /usr/lib/arm-linux-gnueabihf/
		sudo ln -sf libMali.so libEGL.so.1
		sudo ln -sf libMali.so libMaliOpenCL.so.1
		cd /usr/lib/aarch64-linux-gnu/
		sudo ln -sf libMali.so libEGL.so.1
		sudo ln -sf libMali.so libMaliOpenCL.so.1
		ldconfig
		cd /home/ark
		sed -i '/sudo perfmax %EMULATOR% %CORE%; nice -n -19 %ROM%; sudo perfnorm/c\\t\t<command>sudo perfmax On; nice -n -19 %ROM%; sudo perfnorm<\/command>' /etc/emulationstation/es_systems.cfg
		sed -i '/sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/daphne.sh standalone %ROM%; sudo perfnorm/c\\t\t<command>sudo perfmax On; nice -n -19 \/usr\/local\/bin\/daphne.sh standalone %ROM%; sudo perfnorm<\/command>' /etc/emulationstation/es_systems.cfg
		sed -i '/sudo perfmax %EMULATOR% %CORE%; nice -n -19 \/usr\/local\/bin\/singe.sh %ROM%; sudo perfnorm/c\\t\t<command>sudo perfmax On; nice -n -19 \/usr\/local\/bin\/singe.sh %ROM%; sudo perfnorm<\/command>' /etc/emulationstation/es_systems.cfg
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep standalone-duckstation)"
		then
		  sed -i -zE 's/<\/emulators>([^\n]*\n[^\n]*<platform>psx<\/platform>)/   <emulator name=\"\standalone-duckstation\">\n\t\t      <\/emulator>\n\t\t   <\/emulators>\1/' /etc/emulationstation/es_systems.cfg
		fi
		#if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep Gamecube)"
		#then
		#  sed -i -e '/<theme>n64dd<\/theme>/{r /home/ark/add_dolphin.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		#fi
		#mkdir -v /roms/gc | tee -a "$LOG_FILE"
		#if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		#  mkdir -v /roms2/gc | tee -a "$LOG_FILE"
		#  sed -i '/<path>\/roms\/gc/s//<path>\/roms2\/gc/g' /etc/emulationstation/es_systems.cfg
		#fi
		if [ ! -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sed -i '/<path>\/roms2\//s//<path>\/roms\//g' /home/ark/.config/duckstation/settings.ini
		  sudo cp -fv "/usr/local/bin/Switch to SD2 for Roms.sh" "/opt/system/Advanced/Switch to SD2 for Roms.sh" | tee -a "$LOG_FILE"
		else
		  sudo cp -fv "/usr/local/bin/Switch to main SD for Roms.sh" "/opt/system/Advanced/Switch to main SD for Roms.sh" | tee -a "$LOG_FILE"
		fi
		if test -z "$(cat /home/ark/.config/mupen64plus/mupen64plus.cfg | grep Video-GLideN64)"
		then
		  sed -i -e '/Rotate \= 0/{r /home/ark/add_gliden64_to_mupen64plus_cfg.txt' -e 'd}' /home/ark/.config/mupen64plus/mupen64plus.cfg
		fi
		if test -z "$(grep 'GlideN64' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\]/' /usr/local/bin/perfmax
  		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\]/' /usr/local/bin/perfmax.pic
  		  sudo sed -i '/\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Rice" \]\] || \[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\]/' /usr/local/bin/perfmax.asc
		fi
		sed -i '/<extension>.cue .CUE .ccd .CCD .lha .LHA .nrg .NRG .mds .MDS .iso .ISO .m3u .M3U/s//<extension>.chd .CHD .cue .CUE .ccd .CCD .lha .LHA .nrg .NRG .mds .MDS .iso .ISO .m3u .M3U/' /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/arkosupdate08222022.zip | tee -a "$LOG_FILE"
		#sudo rm -v /home/ark/add_dolphin.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_gliden64_to_mupen64plus_cfg.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nAdd GLideN64 plugin for mupen64plus standalone to ES\n" | tee -a "$LOG_FILE"
	if test -z "$(grep 'standalone-GlideN64' /etc/emulationstation/es_systems.cfg | tr -d '\0')"
	then
	  sed -i '/<emulator name="standalone-Glide64mk2">/c\              <emulator name="standalone-Glide64mk2">\n\t\t \t<cores>\n\t\t \t  <core>Default_Aspect<\/core>\n\t\t \t  <core>Widescreen_Aspect<\/core>\n\t\t \t<\/cores>\n              <\/emulator>\n              <emulator name="standalone-GlideN64">' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08222022"
fi

if [ ! -f "/home/ark/.config/.update09052022" ]; then

	printf "\nClean Up some system full names in ES\nUpdate NES-Box Theme\nUpdated Duckstation to prevent Vulkan setting\nAdded Dolphin Standalone emulator\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09052022/rg503/arkosupdate09052022.zip -O /home/ark/arkosupdate09052022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09052022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate09052022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate09052022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09052022.bak | tee -a "$LOG_FILE"
		sed -i '/<fullname>Turbografx CD<\/fullname>/s//<fullname>NEC - Turbografx CD<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Turbografx 16<\/fullname>/s//<fullname>NEC - Turbografx 16<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Saturn<\/fullname>/s//<fullname>Sega - Saturn<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Naomi<\/fullname>/s//<fullname>Sega - Naomi<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Dreamcast<\/fullname>/s//<fullname>Sega - Dreamcast<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Dreamcast VMU<\/fullname>/s//<fullname>Sega - Dreamcast VMU<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Sega Atomiswave<\/fullname>/s//<fullname>Sega - Atomiswave<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Phillips CDI<\/fullname>/s//<fullname>Phillips - CDI<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Nintendo 64DD<\/fullname>/s//<fullname>Nintendo - 64DD<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Nintendo DS<\/fullname>/s//<fullname>Nintendo - DS<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Mattel Intellivision<\/fullname>/s//<fullname>Mattel - Intellivision<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Microsoft MSX<\/fullname>/s//<fullname>Microsoft - MSX<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Microsoft MSX 2<\/fullname>/s//<fullname>Microsoft - MSX 2<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Fairchild ChannelF<\/fullname>/s//<fullname>Fairchild - ChannelF<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Atari ST<\/fullname>/s//<fullname>Atari - ST<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Atari Jaguar<\/fullname>/s//<fullname>Atari - Jaguar<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Atari 5200<\/fullname>/s//<fullname>Atari - 5200<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/<fullname>Amiga<\/fullname>/s//<fullname>Commodore - Amiga<\/fullname>/' /etc/emulationstation/es_systems.cfg
		sed -i '/\/3DO\//s//\/3do\//' /etc/emulationstation/es_systems.cfg
		sed -i '/<extension>.n64 .N64 .z64 .Z64<\/extension>/s//<extension>.d64 .D64 .n64dd .N64DD .ndd .NDD .n64 .N64 .z64 .Z64<\/extension>/' /etc/emulationstation/es_systems.cfg
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep Gamecube)"
		then
		  sed -i -e '/<theme>n64dd<\/theme>/{r /home/ark/add_dolphin.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		mkdir -v /roms/gc | tee -a "$LOG_FILE"
		if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		then
		  mkdir -v /roms2/gc | tee -a "$LOG_FILE"
		  sed -i '/<path>\/roms\/gc/s//<path>\/roms2\/gc/g' /etc/emulationstation/es_systems.cfg
		else
		  sed -i '/roms2\//s//roms\//g'  /home/ark/.config/duckstation/settings.ini
		fi
		if test ! -z "$(cat /home/ark/.config/duckstation/settings.ini | grep Vulkan | tr -d '\0')"
		then
		  sed -i '/Vulkan/s//OpenGL/' /home/ark/.config/duckstation/settings.ini
		fi
		cd /roms/themes/es-theme-nes-box
		git reset --hard origin/master | tee -a "$LOG_FILE"
		git pull | tee -a "$LOG_FILE"
		cd /home/ark
		sudo rm -v /home/ark/arkosupdate09052022.zip | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_dolphin.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMove Duckstation standalone build to new location\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /usr/local/bin/standalone-duckstation | grep "/opt/duckstation/" | tr -d '\0')"
	then
	  sudo sed -i '/duckstation-nogui/s//\/opt\/duckstation\/duckstation-nogui/g' /usr/local/bin/standalone-duckstation
	fi
	sudo rm -fv /usr/local/bin/duckstation-nogui | tee -a "$LOG_FILE"

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09052022"
fi

if [ ! -f "/home/ark/.config/.update10292022" ]; then

	printf "\nUpdate to Retroarch 1.12.0\nAdd Fake08 emulator\nUpdate Pico-8.sh script\nDisable Network Manager wait online by default\nAdd Love 11.4 engine\nUpdate Enable Developer Mode script\nUpdate timezones script\nEnable Threaded DSP for 3DO\nAdd headphone insertion detection workaround\Add missing gc folder\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10292022/arkosupdate10292022.zip -O /home/ark/arkosupdate10292022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10292022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10292022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate10292022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update10292022.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep '<emulator name="fake08">' | tr -d '\0')"
		then
		  sed -i '/<emulator name="full-screen">/c\              <emulator name="full-screen">\n              <\/emulator>\n              <emulator name="fake08">' /etc/emulationstation/es_systems.cfg
		fi
		sudo systemctl disable NetworkManager-wait-online
		sudo systemctl stop NetworkManager-wait-online
		if test -z "$(cat /opt/system/Enable\ Remote\ Services.sh | grep 'NetworkManager-wait-online' | tr -d '\0')"
		then
		  sed -i "/\#\!\/bin\/bash/c\\#\!\/bin\/bash\nsudo systemctl enable NetworkManager-wait-online\nsudo systemctl start NetworkManager-wait-online" /opt/system/Enable\ Remote\ Services.sh
		fi
		if test -z "$(cat /opt/system/Disable\ Remote\ Services.sh | grep 'NetworkManager-wait-online' | tr -d '\0')"
		then
		  sed -i "/\#\!\/bin\/bash/c\\#\!\/bin\/bash\nsudo systemctl disable NetworkManager-wait-online\nsudo systemctl stop NetworkManager-wait-online" /opt/system/Disable\ Remote\ Services.sh
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep 'love' | tr -d '\0')"
		then
		  sed -i -e '/<theme>n64dd<\/theme>/{r /home/ark/add_love.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if [ ! -d "/roms/love2d" ]; then
		  mkdir -v /roms/love2d | tee -a "$LOG_FILE"
		  if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		  then
		    if [ ! -d "/roms2/love2d" ]; then
		      mkdir -v /roms2/love2d | tee -a "$LOG_FILE"
		      sed -i '/<path>\/roms\/love2d/s//<path>\/roms2\/love2d/g' /etc/emulationstation/es_systems.cfg
			fi
		  fi
		fi
		if [ -f "/opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep love2d | tr -d '\0')"
		  then
		    sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/love2d\/" ]\; then\n      sudo mkdir \/roms2\/love2d\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nLove2d is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep gc | tr -d '\0')"
		  then
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gc\/" ]\; then\n      sudo mkdir \/roms2\/gc\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nGC is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep love2d | tr -d '\0')"
		  then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/love2d\/" ]\; then\n      sudo mkdir \/roms2\/love2d\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nLove2d is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep gc | tr -d '\0')"
		  then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gc\/" ]\; then\n      sudo mkdir \/roms2\/gc\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nGC is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/boot/rk3566.dtb" ]; then
		  if [ ! -d "/roms/gc" ]; then
		    mkdir -v /roms/gc | tee -a "$LOG_FILE"
		    if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		    then
			  if [ ! -d "/roms2/gc" ]; then
		        mkdir -v /roms2/gc | tee -a "$LOG_FILE"
		        sed -i '/<path>\/roms\/gc/s//<path>\/roms2\/gc/g' /etc/emulationstation/es_systems.cfg
			  fi
		    fi
		  fi
		fi
		cd /roms/themes/es-theme-nes-box
		git reset --hard origin/master | tee -a "$LOG_FILE"
		git pull | tee -a "$LOG_FILE"
		sudo chown ark:ark /opt/system/Advanced/Enable\ Developer\ Mode.sh
		cd /home/ark
		sudo rm -v /home/ark/add_love.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate10292022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct PPSSPPSDL for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      rm -fv /opt/ppsspp/PPSSPPSDL.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/ppsspp/PPSSPPSDL.rk3326 /opt/ppsspp/PPSSPPSDL | tee -a "$LOG_FILE"
	fi
	
	printf "\nCopy correct fake08 for device\n" | tee -a "$LOG_FILE"
#	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
#	    cp -fv /opt/fake08/fake08.640 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	elif [ -f "/boot/rk3566.dtb" ]; then
#	    cp -fv /opt/fake08/fake08.960 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	elif [ "$(cat ~/.config/.OS)" = "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" = "RGB10MAX" ]; then
#	    cp -fv /opt/fake08/fake08.848 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	else
#	    cp -fv /opt/fake08/fake08.480 /opt/fake08/fake08 | tee -a "$LOG_FILE"
#	    rm -fv /opt/fake08/fake08.* | tee -a "$LOG_FILE"
#	fi
	if [ -f "/boot/rk3566.dtb" ]; then
      mv -fv /opt/fake08/fake08.rk3566 /opt/fake08/fake08 | tee -a "$LOG_FILE"
      rm -fv /opt/fake08/fake08.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /opt/fake08/fake08.rk3326 /opt/fake08/fake08 | tee -a "$LOG_FILE"
      rm -fv /opt/fake08/fake08.rk3566 | tee -a "$LOG_FILE"
	fi

	printf "\nEnable Threaded DSP for 3DO by default\n" | tee -a "$LOG_FILE"
	if test ! -z "$(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep 'opera_dsp_threaded' | tr -d '\0')"
	then
	  sed -i '/opera_dsp_threaded \= "disabled"/c\opera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	  sed -i '/mgba_use_bios \= \"ON\"/c\mgba_use_bios \= \"ON\"\nopera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	else
  	  sed -i '/mgba_use_bios \= \"ON\"/c\mgba_use_bios \= \"ON\"\nopera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
  	  sed -i '/mgba_use_bios \= \"ON\"/c\mgba_use_bios \= \"ON\"\nopera_dsp_threaded \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct emulationstation depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.rgb10max | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.503 | tee -a "$LOG_FILE"
	  cd /usr/lib/aarch64-linux-gnu/
	  sudo ln -sf libMali.so libGLES_CM.so
	  ldconfig
	  cd /home/ark
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ]; then
	  sudo cp -fv /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.rgb10max | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.503 | tee -a "$LOG_FILE"
	  cd /usr/lib/aarch64-linux-gnu/
	  sudo ln -sf libMali.so libGLES_CM.so
	  ldconfig
	  cd /home/ark
	elif [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  sudo cp -fv /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.rgb10max /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.503 | tee -a "$LOG_FILE"
	  cd /usr/lib/aarch64-linux-gnu/
	  sudo ln -sf libMali.so libGLES_CM.so
	  ldconfig
	  cd /home/ark
	elif [ -f "/boot/rk3566.dtb" ]; then
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.503 /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.rgb10max | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	fi

	printf "\nMake sure retroarch core repos are still set to Github if it's been changed and make sure their set to the correct repo\n" | tee -a "$LOG_FILE"
    if [ -f "/boot/rk3566.dtb" ]; then
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg.bak
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/rg503\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg.bak
      echo "Retroarch core repos have been changed to github"
    else
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/aarch64\/\"" ~/.config/retroarch/retroarch.cfg.bak
      sed -i "/core_updater_buildbot_cores_url \=/c\core_updater_buildbot_cores_url \= \"https:\/\/raw.githubusercontent.com\/christianhaitian\/retroarch-cores\/master\/arm7hf\/\"" ~/.config/retroarch32/retroarch.cfg.bak
      echo "Retroarch core repos have been changed to github"
    fi

	printf "\nCopy updated kernel based on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
	  if [ -f "/home/ark/.config/.DEVICE" ]; then
	    if test ! -z "$(grep "RG353V" /home/ark/.config/.DEVICE | tr -d '\0')"
	    then
	      sudo mv -fv /boot/Image.353 /boot/Image | tee -a "$LOG_FILE"
		  sudo rm -fv /boot/Image.503 | tee -a "$LOG_FILE"
	    else
	      sudo mv -fv /boot/Image.503 /boot/Image | tee -a "$LOG_FILE"
		  sudo rm -fv /boot/Image.353 | tee -a "$LOG_FILE"
	    fi
	  else
	    sudo mv -fv /boot/Image.503 /boot/Image | tee -a "$LOG_FILE"
		sudo rm -fv /boot/Image.353 | tee -a "$LOG_FILE"
		echo "RG503" > /home/ark/.config/.DEVICE
	  fi
	else
	  sudo rm -fv /boot/Image.503 | tee -a "$LOG_FILE"
	  sudo rm -fv /boot/Image.353 | tee -a "$LOG_FILE"
	fi

	printf "\nAdd Workaround for headphone jack sense on boot\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
	  if test -z "$(sudo crontab -l | grep 'hpwatchdaemon.sh' | tr -d '\0')"
	  then
		sudo crontab -l > temp.cron
		echo "@reboot /usr/local/bin/hpwatchdaemon.sh &" >> temp.cron
		sudo crontab temp.cron
		sudo rm -v temp.cron | tee -a "$LOG_FILE"
		sudo crontab -l | grep 'hpwatchdaemon.sh' | tr -d '\0' | tee -a "$LOG_FILE"
	  else
	    printf "  No need to add this workaround as it already exists.\n" | tee -a "$LOG_FILE"
	  fi
	else
	  printf "  This is not a device that needs this workaround\n" | tee -a "$LOG_FILE"
	  sudo rm -v /usr/local/bin/hpwatchdaemon.sh  | tee -a "$LOG_FILE"
	fi

	printf "\nClean up some old unneeded files in the system\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	sudo journalctl --vacuum-time=1s

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10292022"

fi

if [ ! -f "/home/ark/.config/.update11012022" ]; then

	printf "\nAdd Bluetooth Audio support\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11012022/arkosupdate11012022.zip -O /home/ark/arkosupdate11012022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11012022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11012022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate11012022.zip -d / | tee -a "$LOG_FILE"
		cd /home/ark/bluez-alsa/build
		sudo make CFLAGS="-I /home/ark/bluez-alsa/build/depends/include/ -I /home/ark/bluez-alsa/build/depends/include/aarch64-linux-gnu/ \
		-I /home/ark/bluez-alsa/build/depends/include/dbus-1.0 -I /home/ark/bluez-alsa/build/depends/include/glib-2.0 \
		-I /home/ark/bluez-alsa/build/depends/include/gio-unix-2.0" LDFLAGS="-L/home/ark/bluez-alsa/build/depends/include/bluetooth \
		-L/home/ark/bluez-alsa/build/depends/include/sbc" install | tee -a "$LOG_FILE"
		cd /home/ark
		sudo cp -fv /home/ark/bluez-alsa/build/depends/include/sbc/libsbc.so /usr/lib/aarch64-linux-gnu/libsbc.so.1 | tee -a "$LOG_FILE"
		sudo systemctl daemon-reload
		bton=$(sudo systemctl status bluetooth | grep "disabled")
		if [ -z "$bton" ]
		then
		  sudo systemctl enable bluealsa
		  sudo systemctl enable watchforbtaudio
		fi
		sudo rm -rfv /home/ark/bluez-alsa | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11012022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct ogage per device\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /home/ark/.config/.DEVICE | grep RG353V | tr -d '\0')"
	then
	  sudo cp -fv /usr/local/bin/ogage.503 /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/ogage.* | tee -a "$LOG_FILE"
	else
	  sudo cp -fv /usr/local/bin/ogage.353 /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/ogage.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11012022"

fi

if [ ! -f "/home/ark/.config/.update11052022" ]; then

	printf "\nUpdate Bluetooth script for longer bluetooth names and add ability to turn bluetooth on and off\nFix Bluetooth audio volume control issue\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11052022/arkosupdate11052022.zip -O /home/ark/arkosupdate11052022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11052022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11052022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate11052022.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11052022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct ogage per device\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /home/ark/.config/.DEVICE | grep RG353V | tr -d '\0')"
	then
	  sudo cp -fv /usr/local/bin/ogage.503 /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/ogage.* | tee -a "$LOG_FILE"
	else
	  sudo cp -fv /usr/local/bin/ogage.353 /usr/local/bin/ogage | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/local/bin/ogage.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11052022"

fi

if [ ! -f "/home/ark/.config/.update11062022" ]; then

	printf "\nFix Retroarch Ozone menu crashing when called during game session\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11062022/arkosupdate11062022.zip -O /home/ark/arkosupdate11062022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11062022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11062022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate11062022.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11062022.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -A4 "fake08" | tr -d '\0' | grep "retroarch" | tr -d '\0')"
		then
		  sed -i '/%CORE%; sudo systemctl start pico8hotkey/s//%ROM%; sudo systemctl start pico8hotkey/' /etc/emulationstation/es_systems.cfg
		  sed -i '/<emulator name="fake08">/c\              <emulator name="fake08">\n              <\/emulator>\n              <emulator name="retroarch">' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(grep 'carts' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$1 == "standalone-GlideN64" \]\]/s//\[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == *"carts"* \]\]/' /usr/local/bin/perfmax
  		  sudo sed -i '/\[\[ \$1 == "standalone-GlideN64" \]\]/s//\[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == *"carts"* \]\]/' /usr/local/bin/perfmax.pic
  		  sudo sed -i '/\[\[ \$1 == "standalone-GlideN64" \]\]/s//\[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == *"carts"* \]\]/' /usr/local/bin/perfmax.asc
		fi
		sudo rm -v /home/ark/arkosupdate11062022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct libretro fake-08 core depending on device\n" | tee -a "$LOG_FILE"
	if [ ! -f "/boot/rk3566.dtb" ]; then
	  mv -fv /home/ark/.config/retroarch/cores/fake08_libretro.so.rk3326 /home/ark/.config/retroarch/cores/fake08_libretro.so | tee -a "$LOG_FILE"
	else
	  rm -fv /home/ark/.config/retroarch/cores/fake08_libretro.so.rk3326 | tee -a "$LOG_FILE"
	fi

	printf "\nCopy correct Retroarches depending on device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.unrot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.unrot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ] || [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
	  cp -fv /opt/retroarch/bin/retroarch32.rk3326.rot /opt/retroarch/bin/retroarch32 | tee -a "$LOG_FILE"
	  cp -fv /opt/retroarch/bin/retroarch.rk3326.rot /opt/retroarch/bin/retroarch | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	else
	  rm -fv /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
	  rm -fv /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11062022"

fi

if [ ! -f "/home/ark/.config/.update11092022" ]; then

  if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
	printf "\nAdd Tony 60hz timing for display panel\nAdd screen timing switching scripts\nFix update script for the RG353M\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11092022/arkosupdate11092022.zip -O /home/ark/arkosupdate11092022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11092022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11092022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate11092022.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11092022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct 60hz dtb depending on device\n" | tee -a "$LOG_FILE"
	if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ]; then
	  sudo cp -fv /boot/rk3566-OC.dtb /boot/rk3566-OC.dtb.orig | tee -a "$LOG_FILE"
	  sudo mv -fv /boot/rk3566-OC.dtb.tony-353v /boot/rk3566-OC.dtb.tony | tee -a "$LOG_FILE"
	  sudo cp -fv /boot/rk3566-OC.dtb.tony /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	  sudo rm -fv /boot/rk3566-OC.dtb.tony-353m | tee -a "$LOG_FILE"
	elif [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
	  sudo cp -fv /boot/rk3566-OC.dtb /boot/rk3566-OC.dtb.orig | tee -a "$LOG_FILE"
	  sudo mv -fv /boot/rk3566-OC.dtb.tony-353m /boot/rk3566-OC.dtb.tony | tee -a "$LOG_FILE"
	  sudo cp -fv /boot/rk3566-OC.dtb.tony /boot/rk3566-OC.dtb | tee -a "$LOG_FILE"
	  sudo rm -fv /boot/rk3566-OC.dtb.tony-353v | tee -a "$LOG_FILE"
	fi

	printf "\nFix update script for RG353M\n" | tee -a "$LOG_FILE"
	if [ "$(cat ~/.config/.DEVICE)" = "RG353M" ]; then
	  sed -i '/RG353V/s//RG353M/g' /opt/system/Update.sh
	  echo "Update script has been updated to point to Update-RG353M.sh for future updates" | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11092022"
  else
	touch "/home/ark/.config/.update11092022"
  fi
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nAdd Amstrad GX4000\nUpdate retroarch-tate script\nUpdate pico8.sh script\nUpdate N64 launch script\nUpdate PS1 M3U Generator script\nDefault external controller as Player 1\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11182022/arkosupdate11182022.zip -O /home/ark/arkosupdate11182022.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11182022.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11182022.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate11182022.zip -d / | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep GX4000)"
		then
		  sed -i -e '/<theme>amstradcpc<\/theme>/{r /home/ark/add_gx4000.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(grep 'cap32' /usr/local/bin/perfmax | tr -d '\0')"
		then
		  sudo sed -i '/\[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == "cap32" \]\]/' /usr/local/bin/perfmax
  		  sudo sed -i '/\[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == "cap32" \]\]/' /usr/local/bin/perfmax.pic
  		  sudo sed -i '/\[\[ \$1 == "standalone-Glide64mk2" \]\]/s//\[\[ \$1 == "standalone-Glide64mk2" \]\] || \[\[ \$1 == "standalone-GlideN64" \]\] || \[\[ \$2 == "cap32" \]\]/' /usr/local/bin/perfmax.asc
		fi
		if [ ! -d "/roms/gx4000" ]; then
		  mkdir -v /roms/gx4000 | tee -a "$LOG_FILE"
		fi
		if test ! -z "$(cat /etc/fstab | grep roms2 | tr -d '\0')"
		then
		  if [ ! -d "/roms2/gx4000" ]; then
		    mkdir -v /roms2/gx4000 | tee -a "$LOG_FILE"
		    sed -i '/<path>\/roms\/gx4000/s//<path>\/roms2\/gx4000/g' /etc/emulationstation/es_systems.cfg
		  fi
		fi
		if [ -f "/opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | grep gx4000 | tr -d '\0')"
		  then
		    sudo chown -v ark:ark /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh | tee -a "$LOG_FILE"
		    sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gx4000\/" ]\; then\n      sudo mkdir \/roms2\/gx4000\n  fi\n  sudo pkill filebrowser/' /opt/system/Advanced/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nAmstrad GX4000 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ -f "/usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh" ]; then
		  if test -z "$(cat /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh | grep gx4000 | tr -d '\0')"
		  then
		    sudo sed -i '/sudo pkill filebrowser/s//if [ \! -d "\/roms2\/gx4000\/" ]\; then\n      sudo mkdir \/roms2\/gx4000\n  fi\n  sudo pkill filebrowser/' /usr/local/bin/Switch\ to\ SD2\ for\ Roms.sh
		  else
		    printf "\nAmstrad GX4000 is already being accounted for in the switch to sd2 script\n" | tee -a "$LOG_FILE"
		  fi
		fi
		if [ ! -f "/boot/rk3566.dtb" ] && [ ! -f "/boot/rk3566-OC.dtb" ]; then
		  sudo rm -fv /home/ark/.config/retroarch/retroarch.cfg.ext | tee -a "$LOG_FILE"
		  sudo rm -fv /home/ark/.config/retroarch32/retroarch.cfg.ext | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/add_gx4000.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11182022.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/class/backlight/backlight/brightness
		exit 1
	fi

	printf "\nCopy correct cap32_libretro core for device\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3566.dtb" ]; then
      mv -fv /home/ark/cap32_libretro.so.rk3566 /home/ark/.config/retroarch/cores/cap32_libretro.so | tee -a "$LOG_FILE"
      rm -fv /home/ark/cap32_libretro.so.rk3326 | tee -a "$LOG_FILE"
    else
      mv -fv /home/ark/cap32_libretro.so.rk3326 /home/ark/.config/retroarch/cores/cap32_libretro.so | tee -a "$LOG_FILE"
      rm -fv /home/ark/cap32_libretro.so.rk3566 | tee -a "$LOG_FILE"
	fi

	printf "\nEnable N64DD by default in retroarch-core options file\n" | tee -a "$LOG_FILE"
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch/retroarch-core-options.cfg.bak
	sed -i '/parallel-n64-64dd-hardware \= "disabled"/c\parallel-n64-64dd-hardware \= "enabled"' /home/ark/.config/retroarch32/retroarch-core-options.cfg.bak

	printf "\nFix mupen64plus rice standalone emulator resolution\n"
	if [ "$(cat ~/.config/.DEVICE)" = "RG353V" ] || [ "$(cat ~/.config/.DEVICE)" = "RG353M" ] || [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sed -i '/ResolutionWidth \= /c\ResolutionWidth \= "640"' /home/ark/.config/mupen64plus/mupen64plus.cfg
	else
	  printf "  This doesn't seem to be a 640x480 resolution unit.  This change is not needed." | tee -a "$LOG_FILE"
	fi

	printf "\nAdd symlink for librga.so.2 arm32bit environment\n" | tee -a "$LOG_FILE"
	if [ ! -f "/usr/lib/arm-linux-gnueabihf/librga.so.2" ]; then
	  cd /usr/lib/arm-linux-gnueabihf/
	  sudo ln -sf librga.so librga.so.2
	  cd /home/ark
	else
	  printf "  librga.so.2 already exists in /usr/lib/arm-linux-gnueabihf/" | tee -a "$LOG_FILE"
	fi

	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "$UPDATE_DONE"
	rm -v -- "$0" | tee -a "$LOG_FILE"
	printf "\033c" >> /dev/tty1
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
	  LD_LIBRARY_PATH=/usr/local/bin msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	else
	  msgbox "Updates have been completed.  System will now restart after you hit the A button to continue.  If the system doesn't restart after pressing A, just restart the system manually."
	fi
	echo $c_brightness > /sys/class/backlight/backlight/brightness
	sudo reboot
	exit 187
fi