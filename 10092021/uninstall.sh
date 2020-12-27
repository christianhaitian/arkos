#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

printf "\nUninstalling cloud sync services\n"

#########
# ARKLONE
#########
/opt/arklone/uninstall.sh

###########
# RETROARCH
###########
# Restore retroarch.cfgs
oldRAstring='cache_directory = "/tmp"'
newRAstring='cache_directory = ""'
sed -i "s|${oldRAstring}|${newRAstring}|" /home/ark/.config/retroarch/retroarch.cfg
sed -i "s|${oldRAstring}|${newRAstring}|" /home/ark/.config/retroarch32/retroarch.cfg

##################
# EMULATIONSTATION
##################
# Restore emulationstation.service
sudo bash -c 'cat <<EOF >"/etc/systemd/system/emulationstation.service"
[Unit]
Description=ODROID-GO2 EmulationStation
After=firstboot.service

[Service]
Type=simple
User=ark
WorkingDirectory=/home/ark
ExecStart=/usr/bin/emulationstation/emulationstation.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF'

# Restore es_systems.cfg
oldESstring='<command>%ROM% \&lt;/dev/tty \&gt;/dev/tty 2\&gt;/dev/tty</command>'
newESstring='<command>sudo chmod 666 /dev/tty1; %ROM% > /dev/tty1; printf "\\033c" >> /dev/tty1</command>'
sudo sed -i "s|${oldESstring}|${newESstring}|" /etc/emulationstation/es_systems.cfg

# Remove the arklone settings dialog from EmulationStation "Options" dir
rm -v "/opt/system/Cloud Settings.sh"

