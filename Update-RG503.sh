#!/bin/bash
clear
UPDATE_DATE="06262022"
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
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

if [ ! -f "$UPDATE_DONE" ]; then

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
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
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