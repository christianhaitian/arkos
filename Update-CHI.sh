#!/bin/bash
clear

UPDATE_DATE="12222021"
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

c_brightness="$(cat /sys/devices/platform/backlight/backlight/backlight/brightness)"
sudo chmod 666 /dev/tty1
echo 255 > /sys/devices/platform/backlight/backlight/backlight/brightness
touch $LOG_FILE
tail -f $LOG_FILE >> /dev/tty1 &

if [ ! -f "/home/ark/.config/.update07162021" ]; then

	printf "\nFix wifi toggle hotkey\nFix Atari 800,5200, and XEGS\nAdd Hotkeys Manual to Options section\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07162021/chi/arkosupdate07162021.zip -O /home/ark/arkosupdate07162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07162021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07162021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07162021.zip -d / | tee -a "$LOG_FILE"
		sudo chown ark:ark /etc/emulationstation/es_systems.cfg
		sudo rm -f -v /home/ark/arkosupdate07162021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.1" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07162021"
fi

if [ ! -f "/home/ark/.config/.update07162021-1" ]; then

	printf "\nFix wifi toggle hotkey for real this time\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07162021-1/chi/arkosupdate07162021-1.zip -O /home/ark/arkosupdate07162021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07162021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07162021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate07162021-1.zip -d / | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/arkosupdate07162021-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.1.1" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07162021-1"
fi

if [ ! -f "/home/ark/.config/.update07312021" ]; then

	printf "\nFix Timezone issues\nAdd ECWolf standalone\nAdd Wolfenstein system to ES\nAdd plaidman doom loader\nAdd scanning and other changes for EasyRPG\nFix resolution for SuperTux\nFix amiberry controls\nBetter lzdoom controls\nFix Daphne and hypseus-singe\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/07312021/chi/arkosupdate07312021.zip -O /home/ark/arkosupdate07312021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate07312021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate07312021.zip" ]; then
		mkdir -v /roms/wolf | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate07312021.zip -d / | tee -a "$LOG_FILE"
		cp -f -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update07312021.bak | tee -a "$LOG_FILE"
		sed -i -e '/<theme>doom<\/theme>/{r /home/ark/add_wolf.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		sed -i '/.ldb .LDB/s//.easyrpg .EASYRPG/' /etc/emulationstation/es_systems.cfg
		sed -i '/.wad .WAD .sh .SH/s//.wad .WAD .sh .SH .doom .DOOM/' /etc/emulationstation/es_systems.cfg
		sed -i '/supported_extensions \= /c\supported_extensions \= \"ldb|easyrpg|zip\"' /home/ark/.config/retroarch/cores/easyrpg_libretro.info
		sed -i '/\/usr\/local\/bin\/retroarch -L \/home\/ark\/.config\/retroarch\/cores\/easyrpg_libretro.so/s//\/usr\/local\/bin\/easyrpg.sh/' /etc/emulationstation/es_systems.cfg
		sudo sed -i '/window_width/c\    (window_width 640)' /roms/ports/supertux/config
		sudo sed -i '/window_height/c\    (window_height 480)' /roms/ports/supertux/config
		sudo rm -f -v /home/ark/arkosupdate07312021.zip | tee -a "$LOG_FILE"
		sudo rm -f -v /home/ark/add_wolf.txt | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nChange mednafen_vb options cpu emulation to fast\n" | tee -a "$LOG_FILE"
	if [[ ! -z $(cat /home/ark/.config/retroarch/retroarch-core-options.cfg | grep vb_cpu_emulation) ]]; then
	  sed -i '/vb_cpu_emulation \= /c\vb_cpu_emulation \= \"fast\"' /home/ark/.config/retroarch/retroarch-core-options.cfg
	else
	  printf '\nvb_cpu_emulation = "fast"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg
	fi
	printf '\nvb_cpu_emulation = "fast"' | tee -a /home/ark/.config/retroarch/retroarch-core-options.cfg.bak

	printf "\nStop symlinks from changing for aarch64 and arm32 when installing software from ubuntu repo\n" | tee -a "$LOG_FILE"
	sudo printf 'path-exclude=/usr/lib/arm-linux-gnueabihf' | sudo tee -a /etc/dpkg/dpkg.cfg.d/excludes
	sudo printf '\npath-exclude=/usr/lib/aarch64-linux-gnu' | sudo tee -a /etc/dpkg/dpkg.cfg.d/excludes

	printf "\nEnsure 64bit and 32bit sdl2 is still properly linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.2" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update07312021"
fi

if [ ! -f "/home/ark/.config/.update08272021" ]; then

	printf "\nUpdate Retroarch to 1.9.8\nAdd genesis_plus_gx_wide 64bit\nFix options wifi menu\nAdd PortMaster to Options/Tool section\nAdd support for online updating from China\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08272021/chi/arkosupdate08272021.zip -O /home/ark/arkosupdate08272021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08272021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08272021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.196.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.196.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate08272021.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update08272021.bak | tee -a "$LOG_FILE"
		sed -i "/<core>genesis_plus_gx<\/core>/c\ \t\t\t  <core>genesis_plus_gx<\/core>\n\t\t\t  <core>genesis_plus_gx_wide<\/core>" /etc/emulationstation/es_systems.cfg
		sudo rm -v /home/ark/arkosupdate08272021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nFix scraping for Wolfenstein\n" | tee -a "$LOG_FILE"
	sed -i '/platform>wolf/c\\t\t<platform>pc<\/platform>' /etc/emulationstation/es_systems.cfg

	printf "\nFix sound volume does not restore previous saved state so it can self recover after a reboot\n" | tee -a "$LOG_FILE"
	sudo sed -i '/ConditionPathExists\=\/var\/lib\/alsa\/asound.state/c\\#ConditionPathExists\=\/var\/lib\/alsa\/asound.state' /lib/systemd/system/alsa-restore.service
	sudo systemctl daemon-reload

	printf "\nInstall fonts-noto-cjk to fix Retroarch Korean language and add dialog for wifi menu\n" | tee -a "$LOG_FILE"
	sudo apt -y update | tee -a "$LOG_FILE"
	sudo apt -y install fonts-noto-cjk dialog | tee -a "$LOG_FILE"

	printf "\nRemove old cache and backup folder files from var folder\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	
	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.3" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08272021"
fi

if [ ! -f "/home/ark/.config/.update08292021" ]; then

	printf "\nUpdate Retroarch 1.9.8 to fix overlay with dpad input issue\nUpdate PPSSPPSDL to 1.11.3\nUpdate PortMaster to 1.52\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/08292021/arkosupdate08292021.zip -O /home/ark/arkosupdate08292021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate08292021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate08292021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate08292021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate08292021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 1.7 Test Release 1.3.1" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update08292021"
fi

if [ ! -f "/home/ark/.config/.update09212021" ]; then

	printf "\nAdd quicknes as a supported core for NES and Famicom Disk System\nAdd video filters for retroarch and retroarch32\nAdd BaRT (Boot and Recovery Tool)\nAdd Astrocade and Channel F emulators\nAdd scraping support for Astrocade for Emulationstation\nAdd ability to switch A/B button in Emulationstation\nUpdate NesBox Theme\nAdd 32bit gpsp core\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/chi/arkosupdate09212021.zip -O /home/ark/arkosupdate09212021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/chi/arkosupdate09212021.z01 -O /home/ark/arkosupdate09212021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.z01 | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/09212021/chi/arkosupdate09212021.z02 -O /home/ark/arkosupdate09212021.z02 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate09212021.z02 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate09212021.zip" ] && [ -f "/home/ark/arkosupdate09212021.z01" ] && [ -f "/home/ark/arkosupdate09212021.z02" ]; then
		sudo rm -rf /roms/themes/es-theme-nes-box/ | tee -a "$LOG_FILE"
		zip -FF /home/ark/arkosupdate09212021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate09212021.z* | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		mkdir -v /roms/channelf | tee -a "$LOG_FILE"
		sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update09212021.bak | tee -a "$LOG_FILE"
		sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch\/filters\/video\"" /home/ark/.config/retroarch/retroarch.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch\/filters\/video\"" /home/ark/.config/retroarch/retroarch.cfg.bak && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch32/retroarch.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch32/retroarch.cfg.bak
		sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch/config/Atari800/retroarch_5200.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch/config/Atari800/retroarch_A800.cfg && sed -i "/video_filter_dir \= \"default\"/c\video_filter_dir \= \"\/home\/ark\/.config\/retroarch32\/filters\/video\"" /home/ark/.config/retroarch/config/Atari800/retroarch_XEGS.cfg
		sed -i "/<core>fceumm<\/core>/c\ \t\t\t  <core>fceumm<\/core>\n\t\t\t  <core>quicknes<\/core>" /etc/emulationstation/es_systems.cfg
		sed -i '/<core>gpsp<\/core>/s//<core>gpsp<\/core>\n\t\t\t<\/cores>\n\t\t\t<\/emulator>\n\t\t\t  <emulator name\="retroarch32">\n\t\t\t<cores>\n\t\t\t  <core>gpsp<\/core>/'  /etc/emulationstation/es_systems.cfg
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep astrocade)"
		then
		  sed -i -e '/<theme>arcade<\/theme>/{r /home/ark/add_astrocade.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep channelf)"
		then
		  sed -i -e '/<theme>astrocade<\/theme>/{r /home/ark/add_channelf.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		sudo rm -v /home/ark/add_astrocade.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_channelf.txt | tee -a "$LOG_FILE"
		sudo rm -fv arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the theme configuration has been updated for nes box\n" | tee -a "$LOG_FILE"
	if test -z "$(cat ~/.emulationstation/es_settings.cfg | grep 'value="4:3"')"
	then
	   sed -i '$a<string name\=\"subset.Emulationstation Screen\" value\=\"4:3\" \/>' /home/ark/.emulationstation/es_settings.cfg
	fi
	sed -i '/<string name\=\"subset.fullscreenfix\" value\=\"351V\" \/>/d' /home/ark/.emulationstation/es_settings.cfg

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update09212021"
fi

if [ ! -f "/home/ark/.config/.update10162021" ]; then

	printf "\nUpdate Emulationstation\nUpdate controls for Solarus\nFix OpenBOR configuration loading and saving\nAdd Satellaview\nUpdate ScummVM to 2.5\nUpdate Retroarch to 1.9.11\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021/chirg351v/arkosupdate10162021.zip -O /home/ark/arkosupdate10162021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021/chirg351v/arkosupdate10162021.z01 -O /home/ark/arkosupdate10162021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021.z01 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10162021.zip" ] && [ -f "/home/ark/arkosupdate10162021.z01" ]; then
		sudo apt -y update && sudo apt -y install libglew2.1 libspeechd2 | tee -a "$LOG_FILE"
		zip -FF /home/ark/arkosupdate10162021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate10162021.z* | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.198.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.198.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		mkdir -v /roms/satellaview | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update10162021.bak | tee -a "$LOG_FILE"
		inputtest=$(cat /etc/emulationstation/es_input.cfg | grep "gameforce_gamepad")
		if [ -z "$inputtest" ]; then
		  sed -i "/<\/inputConfig>/c\ \t\t<input name=\"system_hk\" type=\"button\" id=\"9\" value=\"1\" />\n        <\/inputConfig>" /etc/emulationstation/es_input.cfg
		else
		  sed -i "/<\/inputConfig>/c\ \t\t<input name=\"system_hk\" type=\"button\" id=\"16\" value=\"1\" />\n        <\/inputConfig>" /etc/emulationstation/es_input.cfg		
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep satellaview)"
		then
		  sed -i -e '/<theme>arcade<\/theme>/{r /home/ark/add_satellaview.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		cp -r -v .solarus/ /roms/solarus/ | tee -a "$LOG_FILE"
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  sed -i '/<path>\/roms\//s//<path>\/roms2\//g' /etc/emulationstation/es_systems.cfg
		  mkdir -v /roms2/satellaview | tee -a "$LOG_FILE"
		  cp -r -v .solarus/ /roms2/solarus/ | tee -a "$LOG_FILE"
		fi
		if [ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]; then
		  sudo rm -v /boot/rk3326-rg351v-linux.dtb.* | tee -a "$LOG_FILE"
		  sudo rm -v /opt/system/Advanced/Screen\ -\ Switch\ to\ * | tee -a "$LOG_FILE"
		  sudo rm -v /usr/local/bin/Screen\ -\ Switch\ to\ * | tee -a "$LOG_FILE"
		fi
		sudo rm -v /home/ark/add_satellaview.txt | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10162021"
fi

if [ ! -f "/home/ark/.config/.update10162021-1" ]; then

	printf "\nFix arcade theme label gaff from previous update\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10162021-1/arkosupdate10162021-1.zip -O /home/ark/arkosupdate10162021-1.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10162021-1.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10162021-1.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate10162021-1.zip -d / | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg.update10162021.bak /etc/emulationstation/es_systems.cfg | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep satellaview)"
		then
		  sed -i -e '/<theme>sufami<\/theme>/{r /home/ark/add_satellaview.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		sudo rm -v /home/ark/add_satellaview.txt | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate10162021-1.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10162021-1"
fi

if [ ! -f "/home/ark/.config/.update10172021" ]; then

	printf "\nUpdate Retroarches 1.9.11 to newer commit with ozone missing assets fix\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/10172021/arkosupdate10172021.zip -O /home/ark/arkosupdate10172021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate10172021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate10172021.zip" ]; then
		sudo unzip -X -o /home/ark/arkosupdate10172021.zip -d / | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate10172021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update10172021"
fi

if [ ! -f "/home/ark/.config/.update11052021" ]; then

	printf "\nUpdate to Retroarch 1.9.12\nAdd MegaDuck\nUpdate standalone PPSSPP to 1.12.3\nUpdate liblcf for EasyRPG 0.7.0 future update\nUpdate Emulationstation for megaduck scraping and fix mixv2 scraping\nAdd .7z support for various systems\nAdd .zip support for Amiga\nAdd .vsf support for c64\nAdd ability to hide .zip for DOS games\nAdd missing ppsspp backup folder\nUpdate nes-box theme for megaduck\nFix Space key for non English ES\nIgnore options and retroarch for auto collections\nUpdate update script\nRemove core locks\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11052021/arkosupdate11052021.zip -O /home/ark/arkosupdate11052021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11052021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11052021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1911.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1911.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate11052021.zip -d / | tee -a "$LOG_FILE"
		sudo rm /home/ark/.config/retroarch/cores/*.lck
		sudo rm /home/ark/.config/retroarch32/cores/*.lck
		mkdir -v /roms/megaduck | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update11052021.bak | tee -a "$LOG_FILE"
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep megaduck)"
		then
		  sed -i -e '/<theme>cps3<\/theme>/{r /home/ark/add_megaduck.txt' -e 'd}' /etc/emulationstation/es_systems.cfg
		fi
		sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
		sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
		sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/backupforromsfolder.zip | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/add_megaduck.txt | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11052021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	#Sed some additional supported extensions for various systems
	#Amiga
	sed -i '/<extension>.lha .LHA .hdf .HDF .adf .ADF .m3u .M3U/s//<extension>.lha .LHA .hdf .HDF .adf .ADF .m3u .M3U .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	#Amstrad
	sed -i '/<extension>.cpc .CPC .dsk .DSK .zip .ZIP/s//<extension>.cpc .CPC .dsk .DSK .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Commodore 64
	sed -i '/<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT/s//<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .vsf .VSF/' /etc/emulationstation/es_systems.cfg
	#Atari 2600
	sed -i '/<extension>.a26 .A26 .bin .BIN .zip .ZIP/s//<extension>.a26 .A26 .bin .BIN .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Atari 5200
	sed -i '/<extension>.a52 .A52 .zip .ZIP/s//<extension>.a52 .A52 .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Atari 800
	sed -i '/<extension>.atr .ATR .rom .ROM .zip .ZIP/s//<extension>.atr .ATR .rom .ROM .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Atari Lynx
	sed -i '/<extension>.lnx .LNX .zip .ZIP/s//<extension>.lnx .LNX .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#PC Engine/Turbografx 16
	sed -i '/<extension>.pce .PCE .bin .BIN .zip .ZIP/s//<extension>.pce .PCE .bin .BIN .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.pce .PCE .chd .CHD .zip .ZIP/s//<extension>.pce .PCE .chd .CHD .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#NES
	sed -i '/<extension>.nes .NES .zip .ZIP/s//<extension>.nes .NES .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Virtual Boy
	sed -i '/<extension>.vb .VB .vboy .VBOY .zip .zip/s//<extension>.vb .VB .vboy .VBOY .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#NGP/NGPC
	sed -i '/<extension>.ngp .NGP .ngc .NGC .zip .ZIP/s//<extension>.ngp .NGP .ngc .NGC .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Colecovision
	sed -i '/<extension>.rom .ROM .ri .RI .mx1 .MX1 .mx2 .MX2 .col .COL .dsk .DSK .cas .CAS .sg .SG .sc .SC .m3u .M3U .zip .ZIP/s//<extension>.rom .ROM .ri .RI .mx1 .MX1 .mx2 .MX2 .col .COL .dsk .DSK .cas .CAS .sg .SG .sc .SC .m3u .M3U .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Vectrex
	sed -i '/<extension>.vec .VEC .zip .ZIP/s//<extension>.vec .VEC .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#MSX/MSX2
	sed -i '/<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .ZIP .m3u .M3U/s//<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .ZIP .m3u .M3U .7z .7Z/' /etc/emulationstation/es_systems.cfg
	sed -i '/<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .Zip .m3u .M3U/s//<extension>.cas .CAS .dsk .DSK .mx1 .MX1 .mx2 .MX2 .rom .ROM .zip .ZIP .m3u .M3U .7z .7Z/' /etc/emulationstation/es_systems.cfg
	#Supervision
	sed -i '/<extension>.bin .BIN .zip .ZIP/s//<extension>.bin .BIN .zip .ZIP .7z .7Z/' /etc/emulationstation/es_systems.cfg
	
	#Ignore Options and Retroarch for auto collections
	sed -i '/<platform>cmds</s//<platform>ignore</' /etc/emulationstation/es_systems.cfg
	sed -i '/<platform>retroarch</s//<platform>ignore</' /etc/emulationstation/es_systems.cfg

	printf "\nFix Amiberry select and start key assignment\n" | tee -a "$LOG_FILE"
	sed -i '/input_select_btn \= \"12\"/s//input_select_btn \= \"8\"/' /opt/amiberry/conf/gameforce_gamepad.cfg
	sed -i '/input_start_btn \= \"13\"/s//input_start_btn \= \"9\"/' /opt/amiberry/conf/gameforce_gamepad.cfg

	printf "\nAdd ability to recreate sdl_controllers.txt for pico-8\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /usr/local/bin/pico8.sh | grep sdl_controllers)"
	then
	  sudo sed -i '/bash/s//bash\n\nif [[ ! -f \"\/roms\/pico-8\/sdl_controllers.txt\" ]]\; then\necho \"19000000030000000300000002030000\,gameforce_gamepad\,leftstick:b14\,rightx:a3\,leftshoulder:b4\,start:b9\,lefty:a0\,dpup:b10\,righty:a2\,a:b1\,b:b0\,guide:b16\,dpdown:b11\,rightshoulder:b5\,righttrigger:b7\,rightstick:b15\,dpright:b13\,x:b2\,back:b8\,leftx:a1\,y:b3\,dpleft:b12\,lefttrigger:b6\,platform:Linux\,\n190000004b4800000010000000010000\,GO-Advance Gamepad\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:b7\,dpleft:b8\,dpright:b9\,dpup:b6\,leftx:a0\,lefty:a1\,guide:b10\,leftstick:b12\,lefttrigger:b11\,rightstick:b13\,righttrigger:b14\,start:b15\,platform:Linux\,\n190000004b4800000010000001010000\,GO-Advance Gamepad (rev 1.1)\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:b9\,dpleft:b10\,dpright:b11\,dpup:b8\,leftx:a0\,lefty:a1\,guide:b12\,leftstick:b14\,lefttrigger:b13\,rightstick:b15\,righttrigger:b16\,start:b17\,platform:Linux\,\n190000004b4800000011000000010000\,GO-Super Gamepad\,x:b2\,a:b1\,b:b0\,y:b3\,back:b12\,start:b13\,dpleft:b10\,dpdown:b9\,dpright:b11\,dpup:b8\,leftshoulder:b4\,lefttrigger:b6\,rightshoulder:b5\,righttrigger:b7\,leftstick:b14\,rightstick:b15\,leftx:a0\,lefty:a1\,rightx:a2\,righty:a3\,platform:Linux\,\n03000000091200000031000011010000\,OpenSimHardware OSH PB Controller\,a:b1\,b:b0\,x:b2\,y:b3\,leftshoulder:b4\,rightshoulder:b5\,dpdown:h0.4\,dpleft:h0.8\,dpright:h0.2\,dpup:h0.1\,guide:b7\,leftstick:b14\,lefttrigger:b13\,rightstick:b15\,righttrigger:b16\,leftx:a0~\,lefty:a1~\,start:b6\,platform:Linux\,\" \> \/roms\/pico-8\/sdl_controllers.txt\nfi/' /usr/local/bin/pico8.sh
	fi

	printf "\nRemove old logs, cache and backup folder files from var folder\n" | tee -a "$LOG_FILE"
	sudo rm -rfv /var/cache/* | tee -a "$LOG_FILE"
	sudo rm -rfv /var/backups/* | tee -a "$LOG_FILE"
	sudo journalctl --vacuum-time=1s | tee -a "$LOG_FILE"

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11052021"
fi

if [ ! -f "/home/ark/.config/.update11092021" ]; then

	printf "\nUpdate to Retroarch 1.9.13\nUpdate PPSSPP to newer commit of 1.12.3 to address glitches\nUpdate Emulationstation to add brightness control from start menu\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/11092021/arkosupdate11092021.zip -O /home/ark/arkosupdate11092021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate11092021.zip | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate11092021.zip" ]; then
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1912.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1912.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate11092021.zip -d / | tee -a "$LOG_FILE"
		sudo cp -f -v /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
		sudo chmod 777 /usr/bin/emulationstation/emulationstation
		sudo rm -v /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
		sudo rm -v /home/ark/arkosupdate11092021.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.10.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.10.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	
	printf "\nUpdate boot text to reflect current version of ArkOS\n" | tee -a "$LOG_FILE"
	sudo sed -i "/title\=/c\title\=ArkOS 2.0 ($UPDATE_DATE)" /usr/share/plymouth/themes/text.plymouth

	touch "/home/ark/.config/.update11092021"
fi

if [ ! -f "$UPDATE_DONE" ]; then

	printf "\nUpdate Retroarch and Retroarch32 to 1.9.14\nUpdate ScummVM\nReplace Solarus 1.7.0 with 1.6.5 with control patch\nFix retrorun and retrorun32 emus with 1 sd card\nUpdate easyrpg scan script\nAdd script to switch L2/R2 for OGA1.1\nAdd Mame (Current) to Arcade system\nAdd support for mods for ecwolf\n" | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12222021/arkosupdate12222021.zip -O /home/ark/arkosupdate12222021.zip -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12222021.zip | tee -a "$LOG_FILE"
	sudo wget -t 3 -T 60 --no-check-certificate "$LOCATION"/12222021/arkosupdate12222021.z01 -O /home/ark/arkosupdate12222021.z01 -a "$LOG_FILE" || rm -f /home/ark/arkosupdate12222021.z01 | tee -a "$LOG_FILE"
	if [ -f "/home/ark/arkosupdate12222021.zip" ] && [ -f "/home/ark/arkosupdate12222021.z01" ]; then
		zip -FF /home/ark/arkosupdate12222021.zip --out /home/ark/arkosupdate.zip -fz | tee -a "$LOG_FILE"
		sudo rm -fv /home/ark/arkosupdate12222021.z* | tee -a "$LOG_FILE"
		sudo rm -f -v /opt/retroarch/bin/retroarch.* | tee -a "$LOG_FILE"
		sudo rm -f -v /opt/retroarch/bin/retroarch32.* | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch /opt/retroarch/bin/retroarch.1913.bak | tee -a "$LOG_FILE"
		cp -v /opt/retroarch/bin/retroarch32 /opt/retroarch/bin/retroarch32.1913.bak | tee -a "$LOG_FILE"
		cp -v /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.update12222021.bak | tee -a "$LOG_FILE"
		sudo unzip -X -o /home/ark/arkosupdate.zip -d / | tee -a "$LOG_FILE"
		if [ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]; then
		  cp -f -v /opt/solarus/pads.ini.351v /opt/solarus/pads.ini | tee -a "$LOG_FILE"
		elif [ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]; then
			if [ ! -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000")" ]; then
		      cp -f -v /opt/solarus/pads.ini.rgb10 /opt/solarus/pads.ini | tee -a "$LOG_FILE"
			else
		      cp -f -v /opt/solarus/pads.ini.rk2020 /opt/solarus/pads.ini | tee -a "$LOG_FILE"
			fi
		elif [ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]; then
		  cp -f -v /opt/solarus/pads.ini.351mp /opt/solarus/pads.ini | tee -a "$LOG_FILE"
		else
		  cp -f -v /opt/solarus/pads.ini.chi /opt/solarus/pads.ini | tee -a "$LOG_FILE"
		fi
		if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
		  cp -f -v /roms/easyrpg/Scan_for_new_games.easyrpg /roms2/easyrpg/Scan_for_new_games.easyrpg | tee -a "$LOG_FILE"
		fi
		if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep openmsx)"
		then
		  sed -i '/<core>fmsx<\/core>/c\\t\t \t  <core>fmsx<\/core>\n\t\t \t<\/cores>\n\t\t      <\/emulator>\n\t\t      <emulator name\=\"openmsx\">' /etc/emulationstation/es_systems.cfg
		  sed -i -e '/openmsx/{n;d}' /etc/emulationstation/es_systems.cfg
		fi
		sudo apt -y update && sudo apt -y install psmisc | tee -a "$LOG_FILE"
		if [ -z "$(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000")" ]; then
		  sudo rm -f -v /boot/rk3326-odroidgo2-linux-v11.dtb.* | tee -a "$LOG_FILE"
		  sudo rm -f -v /usr/local/bin/"Triggers -- Enable RGB10 Version.sh" | tee -a "$LOG_FILE"
		  sudo rm -f -v /usr/local/bin/"Triggers -- Enable OGA 1.1 Version.sh" | tee -a "$LOG_FILE"
		  sudo rm -f -v /opt/system/Advanced/"Triggers -- Enable OGA 1.1 Version.sh" | tee -a "$LOG_FILE"
		fi
		sudo rm -f -v /opt/solarus/pads.ini.* | tee -a "$LOG_FILE"
		sed -i '/back:12/s//back:b12/' /opt/openmsx/gamecontrollerdb.txt
		sudo rm -v /home/ark/arkosupdate.zip | tee -a "$LOG_FILE"
	else 
		printf "\nThe update couldn't complete because the package did not download correctly.\nPlease retry the update again." | tee -a "$LOG_FILE"
		sleep 3
		echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
		exit 1
	fi

	printf "\nAdd prg support for C64\n" | tee -a "$LOG_FILE"
	  sed -i '/<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT/s//<extension>.d64 .D64 .zip .ZIP .7z .7Z .t64 .T64 .crt .CRT .prg .PRG/' /etc/emulationstation/es_systems.cfg
	
	printf "\nAdd zip support for EasyRPG\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '.EASYRPG .ZIP')"
	then
	  sed -i '/<extension>.easyrpg .EASYRPG/s//<extension>.easyrpg .EASYRPG .zip .ZIP/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd sgd support for Genesis and MD\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '.sgd .68k')"
	then
	  sed -i '/<extension>.mdx .MDX .md .MD .smd .SMD .gen .GEN .bin .BIN .cue .CUE .iso .ISO .sms .SMS .gg .GG .sg .SG/s//<extension>.mdx .MDX .md .MD .smd .SMD .gen .GEN .bin .BIN .cue .CUE .iso .ISO .sms .SMS .gg .GG .sg .SG .sgd .SGD/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd .ecwolf support for Wolfenstein system\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '.ecwolf')"
	then
	  sed -i '/<extension>.wolf .WOLF/s//<extension>.ecwolf .ECWOLF .wolf .WOLF/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd support for mame current to Arcade system\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /etc/emulationstation/es_systems.cfg | grep -i '<core>mame</core>')"
	then
	  sed -i -e '/Arcade - Various Platform/,/arcade</s/fbalpha2012/fbalpha2012<\/core>\n\t\t \t  <core>mame/' /etc/emulationstation/es_systems.cfg
	fi

	printf "\nAdd support for fceumm to Famicom system\n" | tee -a "$LOG_FILE"
	sed -i '/\/home\/ark\/.config\/retroarch\/cores\/nestopia_libretro.so %ROM%; sudo perfnorm<\/command>/s//\/home\/ark\/.config\/%EMULATOR%\/cores\/%CORE%_libretro.so %ROM%; sudo perfnorm<\/command>\n                  <emulators>\n                      <emulator name="retroarch">\n                        <cores>\n                          <core>nestopia<\/core>\n                          <core>fceumm<\/core>\n                        <\/cores>\n                      <\/emulator>\n                   <\/emulators>/g' /etc/emulationstation/es_systems.cfg

	printf "\nFix atomiswave, dreamcast, and naomi not working with 1 sd card for 351v and 351mp\n" | tee -a "$LOG_FILE"
	if [ -f "/opt/system/Advanced/Switch to SD2 for Roms.sh" ]; then
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/atomiswave.sh
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/dreamcast.sh
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/naomi.sh
	  sudo sed -i '/roms2\//s//roms\//g' /usr/local/bin/saturn.sh
	fi

	printf "\nForce the use of older SDL2 for hypseus due to audio sync issue\n" | tee -a "$LOG_FILE"
	if test -z "$(cat /usr/local/bin/daphne.sh | grep -i 'libSDL2-2.0.so.0.1')"
	then
	   if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	     sudo sed -i '/\.\/hypseus/s//LD_PRELOAD=\/usr\/lib\/aarch64-linux-gnu\/libSDL2-2.0.so.0.10.0 .\/hypseus/' /usr/local/bin/daphne.sh
	   else
	     sudo sed -i '/\.\/hypseus/s//LD_PRELOAD=\/usr\/lib\/aarch64-linux-gnu\/libSDL2-2.0.so.0.14.1 .\/hypseus/' /usr/local/bin/daphne.sh
	   fi
	fi

	printf "\nCopy correct updated ES for RGB10, RK2020 and OGAs\n" | tee -a "$LOG_FILE"	
	if [ ! -f "/boot/rk3326-rg351v-linux.dtb" ] && [ ! -f "/boot/rk3326-rg351mp-linux.dtb" ] && [ ! -f "/boot/rk3326-gameforce-linux.dtb" ]; then
      sudo rm -fv /usr/bin/emulationstation/emulationstation.351v | tee -a "$LOG_FILE"
	  test=$(stat -c %s "/usr/bin/emulationstation/emulationstation")
	  if [ $test = "3240584" ] || [ $test = "3232392" ]; then
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.header /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  else
		  sudo cp -f -v /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  fi
	else
	  sudo mv -fv /usr/bin/emulationstation/emulationstation.351v /usr/bin/emulationstation/emulationstation | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.fullscreen | tee -a "$LOG_FILE"
	  sudo rm -fv /usr/bin/emulationstation/emulationstation.header | tee -a "$LOG_FILE"
	fi
	
	printf "\nMake sure the proper SDLs are still linked\n" | tee -a "$LOG_FILE"
	if [ -f "/boot/rk3326-rg351v-linux.dtb" ] || [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.16.0 /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.16.0 /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 /usr/lib/arm-linux-gnueabihf/libSDL2.so
	else
	  sudo mv -f -v /home/ark/sdl2-64/libSDL2-2.0.so.0.16.0.rotated /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo mv -f -v /home/ark/sdl2-32/libSDL2-2.0.so.0.16.0.rotated /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-64 | tee -a "$LOG_FILE"
	  sudo rm -rfv /home/ark/sdl2-32 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2.so /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0.16.0 /usr/lib/aarch64-linux-gnu/libSDL2.so | tee -a "$LOG_FILE"
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2.so /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0
	  sudo ln -sfv /usr/lib/arm-linux-gnueabihf/libSDL2-2.0.so.0.16.0 /usr/lib/arm-linux-gnueabihf/libSDL2.so
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
	echo $c_brightness > /sys/devices/platform/backlight/backlight/backlight/brightness
	sudo reboot
	exit 187
fi