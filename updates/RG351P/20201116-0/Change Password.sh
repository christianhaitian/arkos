#!/bin/bash
sudo rg351p-js2xbox --silent -t oga_joypad &
sudo ln -s /dev/input/event3 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
sudo chmod 777 /dev/input/by-path/platform-odroidgo2-joypad-event-joystick

OLD_PASS=`osk "Enter OLD password." | tail -n 1`
NEW_PASS=`osk "Enter NEW password." | tail -n 1`

echo "$OLD_PASS : $NEW_PASS"
echo -e "$OLD_PASS\n$NEW_PASS\n$NEW_PASS" | (passwd ark)

status=$?

if test $status -eq 0
then
	msgbox "Password successfully changed."
else
	msgbox "Password change failed."
fi

sudo kill $(pidof rg351p-js2xbox)
sudo rm /dev/input/by-path/platform-odroidgo2-joypad-event-joystick
