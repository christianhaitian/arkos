If you wish to build packages that require header files, you can use this file to do this in ArkOS.  You must be on Arkos 1.6.  This package includes an updated kernel and additional kernel modules.

From a SSH terminal in ArkOS, do the following:

1. wget https://github.com/christianhaitian/arkos/raw/main/KernelandHeader/ArkosKernandHead.tar.gz
2. tar -zxvf ArkosKernandHead.tar.gz
3. ./install_headers.sh

Note: Ignore the permission error about permission issues for /boot.  That is normal as permissions can't be set on fat partitions.
