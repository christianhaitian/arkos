#!/bin/bash
sudo sed -i '/load mmc 1:1 ${dtb_loadaddr} rk3326-rg351p-linux.dtb/c\    load mmc 1:1 ${dtb_loadaddr} rk3326-rg351p-linux.dtb.15' /boot/boot.ini
sudo reboot
