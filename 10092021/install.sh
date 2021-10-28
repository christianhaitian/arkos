#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

printf "\nInstalling cloud sync services\n"

#########
# ARKLONE
#########
git clone --depth 1 https://github.com/ridgekuhn/arklone-arkos /opt/arklone

sudo chown ark:ark /opt/arklone
chmod u+x /opt/arklone/install.sh

/opt/arklone/install.sh

###########
# RETROARCH
###########
# This prevents arklone path units from being triggered when .zip content is temporarily decompressed by RetroArch
cp -v "/home/ark/.config/retroarch/retroarch.cfg" "/home/ark/.config/retroarch/retroarch.cfg.arklone.bak"
cp -v "/home/ark/.config/retroarch32/retroarch.cfg" "/home/ark/.config/retroarch32/retroarch.cfg.arklone.bak"

oldRAstring='cache_directory = ""'
newRAstring='cache_directory = "/tmp"'
sed -i "s|${oldRAstring}|${newRAstring}|" /home/ark/.config/retroarch/retroarch.cfg
sed -i "s|${oldRAstring}|${newRAstring}|" /home/ark/.config/retroarch32/retroarch.cfg

##################
# EMULATIONSTATION
##################
# Modify emulationstation.service
# This runs emulationstation on tty1 instead of detatched
cp "/etc/systemd/system/emulationstation.service" "/etc/emulationstation/emulationstation.service.arklone.bak"

sudo bash -c 'cat <<EOF >"/etc/systemd/system/emulationstation.service"
[Unit]
Description=ODROID-GO2 EmulationStation
After=firstboot.service

[Service]
Type=simple
User=ark
WorkingDirectory=/home/ark
StandardInput=tty
StandardOutput=journal+console
StandardError=journal+console
TTYPath=/dev/tty1
ExecStart=/usr/bin/emulationstation/emulationstation.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target

EOF'

# Modify es_systems.cfg
# Redirects stdin, stdout, stderr
# from the tty EmulationStation is attached to (tty1, per above),
# to the command run from the "Options" menu (/opt/system/ directory)
cp "/etc/emulationstation/es_systems.cfg" "/etc/emulationstation/es_systems.cfg.arklone.bak"

oldESstring='<command>sudo chmod 666 /dev/tty1; %ROM% > /dev/tty1; printf "\\033c" >> /dev/tty1</command>'
newESstring='<command>%ROM% \&lt;/dev/tty \&gt;/dev/tty 2\&gt;/dev/tty</command>'
sudo sed -i "s|${oldESstring}|${newESstring}|" /etc/emulationstation/es_systems.cfg

# Add the arklone settings dialog to EmulationStation "Options" dir
sudo bash -c 'cat <<EOF >"/opt/system/Cloud Settings.sh"
#!/bin/bash
# arklone cloud sync utility
# by ridgek
# Released under GNU GPLv3 license, see LICENSE.md.

/opt/arklone/src/dialogs/scripts/input-listener.sh "/opt/arklone/src/dialogs/settings.sh"
EOF'

sudo chown ark:ark "/opt/system/Cloud Settings.sh"
sudo chmod a+x "/opt/system/Cloud Settings.sh"

