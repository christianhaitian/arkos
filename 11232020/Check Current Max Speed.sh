#!/bin/bash

sudo rg351p-js2xbox --silent -t oga_joypad &
sudo ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick

msgbox "$(lscpu | grep "CPU max MHz")"

sudo kill $(pidof rg351p-js2xbox)
sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
