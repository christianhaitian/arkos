If you wish to build packages that require header files, you can use this file to do this in ArkOS.  This package includes an updated kernel and additional kernel modules to support more usb wifi sticks.  Mostly Atheros based.

From a SSH terminal in ArkOS, do the following:

1. wget https://github.com/christianhaitian/arkos/raw/main/KernelandHeader/ArkosKernandHead.tar.gz
2. tar -zxvf ArkosKernandHead.tar.gz
3. sudo ./install_headers.sh
