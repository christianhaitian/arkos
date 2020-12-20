#!/bin/bash

sudo rg351p-js2xbox --silent -t oga_joypad &
sudo ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick

arr=($(nmcli -g uuid c s --active))

for i in "${arr[@]}"
do
	#echo uuid=$i
	str=$(echo CONNECTION)
	str+=$'\n'
	str+=$(nmcli -g connection.id c s $i)
	str+=$'\n\n'
	str+=$(nmcli -m tabular -f ip4.address,ip4.gateway,ip4.domain c s $i)

	echo $str
	msgbox "$str"
done
sudo kill $(pidof rg351p-js2xbox)
sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
