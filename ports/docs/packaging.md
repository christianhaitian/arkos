# Packaging ports for PortMaster

Because the intention of the ports in PortMaster is to be as broadly compatible as possible with at least the Ubuntu based RK3326 devices, there are some prerequisites the packages ports have to meet which are as follows:

## Identifying which rk3326 device it's being run from in order to set various parameters like gamepad controls and screen resolution.

The best solution I've seen so far is to look at the device's gamecontroller existence in /dev/input/by-path/.  In some cases, you can also look in emulationstation's es_systems.cfg file to differentiate between a OGA 1.0(RK2020) and OGA 1.1(RGB10) unit.
  As an example, here's how I typically do this for the Chi, Anbernic, OGA, OGS and the RK2020,
```  
if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  echo "anbernic"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    echo "oga"
  else
    echo "rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  echo "ogs"
else
  echo "chi"
fi
```
## Provide the ability to force quit a port where possible.

You can use [oga_controls](https://github.com/christianhaitian/oga_controls.git) to do this.  Just have it launched before the actual port is launched and provide the name of the port's executable and fork it to the background.

ex. `sudo ./oga_controls opentyrian rk2020 &`
Note: if the port is using it's own builtin gamepad control, be sure to disable oga_controls' button definitions so they don't potentially interfere with controls.  You do this by providing a oga_controls_settings.txt file in the same directory as oga_controls with all inputs disabled using `\"` so it just serves as an exit daemon.

ex.

oga_controls_settings.txt with all input buttons disabled

```
back = \"
start = \"
a = \"
b = \"
x = \"
y = \"
l1 = \"
l2 = \"
l3 = \"
r1 = \"
r2 = \"
r3 = \"
up = \"
down = \" 
left = \"
right = \"
left_analog_up = \"
left_analog_down = \"
left_analog_left = \"
left_analog_right = \"
right_analog_up = \"
right_analog_down = \" 
right_analog_left = \"
right_analog_right = \"
```

## If the port needs keyboard controls, you can use [oga_controls](https://github.com/christianhaitian/oga_controls.git) to emulate keyboard presses.  Reassignment of keyboard keys can be done via oga_controls_settings.txt.  The default assigned keys can be reviewed [here](https://github.com/christianhaitian/oga_controls/blob/17325791c46c1ee4ec2ad68d44b4ebb2fb305433/main.c#L69)

It's important to note that when running oga_controls, you need to provide a name of the executable so it can kill the application using the device's hotkey combo as well as the device (anbernic, chi, oga, ogs, rk2020) so the keys can be assigned properly.  

`sudo ./oga_controls opentyrian chi &`

As an aside, the reason for the rk2020 be assigned separate from the oga is because the rk2020 is missing one of the keys that is used by the oga for using hotkeys to kill applications.

## If the port uses SDL gamecontroller controls.  Assign them to a gamecontrollerdb.txt file or provide the controls to the port via SDL_GAMECONTROLLERCONFIG= during execution or as an export.

You can have these preassigned per supported device so depending on which device is identified during execution, it will have the proper SDL_GAMECONTROLLERCONFIG info.

ex.

```
if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  sdl_controllerconfig="03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,leftstick:b8,lefttrigger:b10,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux,"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    sdl_controllerconfig="190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,back:b12,leftstick:b13,lefttrigger:b14,rightstick:b16,righttrigger:b15,start:b17,platform:Linux,"
  else
    sdl_controllerconfig="190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,back:b10,lefttrigger:b12,righttrigger:b13,start:b15,platform:Linux,"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000011000000010000,GO-Super Gamepad,platform:Linux,x:b2,a:b1,b:b0,y:b3,back:b12,guide:b14,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b15,rightstick:b16,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
else
  sdl_controllerconfig="19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,"
fi


SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./gmloader gamedata/am2r.apk

```

## At least one RK3326 device (Anbernic RG351V) supports 2 sd card slots.  ArkOS is one that specifically distinguishes when the second sd card is being use or not for games and ports.  If a singular sd card is being used, then there's just a roms partition used for games and ports.  When the second sd card slow is being used, then there's a roms2 partition for games nad ports. That needs to be accounted for:

ex. 
```
if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
  directory="roms2"
else
  directory="roms"
fi
```

## Port specific additional libraries should be included within the port's directory in a separate subfolder named libs.
They can be loaded at runtime using export LD_LIBRARY_PATH

# Now let's put it all together.  Below is an example script for AM2R that incorporates everything mentioned above
```
#!/bin/bash

if [[ -e "/dev/input/by-path/platform-ff300000.usb-usb-0:1.2:1.0-event-joystick" ]]; then
  sdl_controllerconfig="03000000091200000031000011010000,OpenSimHardware OSH PB Controller,a:b1,b:b0,x:b3,y:b2,leftshoulder:b4,rightshoulder:b5,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,dpup:h0.1,leftx:a0~,lefty:a1~,leftstick:b8,lefttrigger:b10,rightstick:b9,back:b7,start:b6,rightx:a2,righty:a3,righttrigger:b11,platform:Linux,"
  param_device="anbernic"
elif [[ -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    sdl_controllerconfig="190000004b4800000010000001010000,GO-Advance Gamepad (rev 1.1),a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b9,dpleft:b10,dpright:b11,dpup:b8,leftx:a0,lefty:a1,back:b12,leftstick:b13,lefttrigger:b14,rightstick:b16,righttrigger:b15,start:b17,platform:Linux,"
    param_device="oga"
  else
    sdl_controllerconfig="190000004b4800000010000000010000,GO-Advance Gamepad,a:b1,b:b0,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,dpdown:b7,dpleft:b8,dpright:b9,dpup:b6,leftx:a0,lefty:a1,back:b10,lefttrigger:b12,righttrigger:b13,start:b15,platform:Linux,"
    param_device="rk2020"
  fi
elif [[ -e "/dev/input/by-path/platform-odroidgo3-joypad-event-joystick" ]]; then
  sdl_controllerconfig="190000004b4800000011000000010000,GO-Super Gamepad,platform:Linux,x:b2,a:b1,b:b0,y:b3,back:b12,guide:b14,start:b13,dpleft:b10,dpdown:b9,dpright:b11,dpup:b8,leftshoulder:b4,lefttrigger:b6,rightshoulder:b5,righttrigger:b7,leftstick:b15,rightstick:b16,leftx:a0,lefty:a1,rightx:a2,righty:a3,platform:Linux,"
  param_device="ogs"
else
  sdl_controllerconfig="19000000030000000300000002030000,gameforce_gamepad,leftstick:b14,rightx:a3,leftshoulder:b4,start:b9,lefty:a0,dpup:b10,righty:a2,a:b1,b:b0,guide:b16,dpdown:b11,rightshoulder:b5,righttrigger:b7,rightstick:b15,dpright:b13,x:b2,back:b8,leftx:a1,y:b3,dpleft:b12,lefttrigger:b6,platform:Linux,"
  param_device="chi"
fi

sudo chmod 666 /dev/tty1

if [ -f "/opt/system/Advanced/Switch to main SD for Roms.sh" ]; then
  directory="roms2"
else
  directory="roms"
fi

export LD_LIBRARY_PATH=/$directory/ports/am2r/libs:/usr/lib
sudo rm -rf ~/.config/am2r
ln -sfv /$directory/ports/am2r/conf/am2r/ ~/.config/
cd /$directory/ports/am2r
sudo ./oga_controls gmloader $param_device &
SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig" ./gmloader gamedata/am2r.apk
sudo kill -9 $(pidof oga_controls)
unset LD_LIBRARY_PATH
sudo systemctl restart oga_events &
printf "\033c" > /dev/tty1
```

Notes:  
-  Note that in order to properly assign keys during execution for oga_controls, we have it assigned as a variable depending on what rk3326 device is detected during execution.  
-  We also add an additional kill process for oga_controls because the user may decide to exit a port properly through the port's exit menu.  If that happens, we still need to kill oga_controls or it may cause double key press issues in various menus or if another port is run, double up on the number of oga_controls are still running in memory.
- We're restarting oga_events because for some reason in ArkOS, the use of oga_controls can impact the oga_events which is responsible for system global hotkeys like volume and brightness controls.  This is at least the case for ArkOS.
- The printf command at the bottom is to clean up the terminal tty1 screen so potential key press screen junk doesn't remain and make the screen look messy between other various system functions.  Many people care about this.  ¯\_(ツ)_/¯
