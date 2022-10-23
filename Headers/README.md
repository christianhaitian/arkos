If you wish to build packages that require header files or other projects, please follow the instructions below while in SSH on your device.  You must be on Arkos 1.6 or newer for this to work correctly.

From a SSH terminal in ArkOS, do the following:

```
wget https://github.com/christianhaitian/arkos/raw/main/Headers/install_headers.sh
chmod 777 install_headers.sh
./install_headers.sh
```

If all completes successfully, you can proceed with building your packages or projects.
