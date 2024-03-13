# To manually install Box/Wine on a Pi
Box enables x86 binary to run on arm, wine enables windows to run in linux

## Pi4 or 5 tip for stability March2023
wine64-wow64 isnt helpfull for vara.exe, a 32bit app

RECOMMEND: use a 32bit OS image to get up and running quickly with these tips.

## Pi4 or 5 to load box 86
Load up Pi-Apps http://pi-apps.io
- `wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash`
- Use the Pi-Apps GUI navigate to Tools->Emulation
  - install Wine 32bit
  - install Box86 32bit

If you only see 64bit, you cant use this method and you need to look at installing box32 and wine32 on the OS which at this time, isnt documented here. 

## Pi5 only 16K pagesize incompatible with wine/box
- https://github.com/raspberrypi/bookworm-feedback/issues/107
 
switch to 4k-page (pi-apps will do this for you)
- add `kernel=kernel8.img` to /boot/config.txt
- reboot

# Installing Wine on Intel /Debian
Reference the following https://wiki.winehq.org/Ubuntu

# Configure Wine
## To manually install latest winetricks
```
wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks 
sudo mv -v winetricks /usr/local/bin
```

- Install DLL with winetricks by running "winetricks" from CLI
  - You may want to run `WINEARCH=win32 winetricks` to set it up the first time, on wow64 it will fail
  - press OK for 'default prefix'
  - choose install a DLL or component
  - Select some needed DLL and press OK to install
    - Vara comdlg32ocx, comctl32oxc, pdh-nt4, vb6run
    - VarAC vcrun2010
 
```
WINEARCH=win32 winecfg
/usr/local/bin/winetricks --force pdh_nt4
/usr/local/bin/winetricks --force vb6run
/usr/local/bin/winetricks --force comdlg32ocx
/usr/local/bin/winetricks --force comctl32ocx
/usr/local/bin/winetricks --force vcrun2010
```

## Serial Ports
wine regedit
`HKEY_LOCAL_MACHINE\Software\Wine\Ports` add a new `String Value` for example of: `COM1` and the value `/dev/ttyUSB0`

# Vara
- Download Vara, WinLink bundle
  - `wget -r -A "*.zip" 'https://downloads.winlink.org/'`

- copy all the OCX files in VARA rather then set paths or register
  - `cp ~/.wine/drive_c/VARA/OCX/* ~/.wine/drive_c/VARA/`

- [https://github.com/islandmagic/varanny](https://github.com/islandmagic/varanny)

# VarAC
- needs a free login get it from https://www.varac-hamradio.com/downloadlinux

- remember to validate your VarAC.ini and disable `LinixCompatibleMode=OFF` .net crash seems to happen with it ON
  - `sed -i 's/LinuxCompatibleMode=OFF/LinuxCompatibleMode=OFF/' ~/.wine/drive_c/VarAC/VarAC.ini`
  - [possible missing fonts?](https://github.com/SpudGunMan/segoe-ui-linux) its unclear why they are not being used by varac.
    - VarAC isn't loading well in older wine recommend version 8 or higher the "linux mode" causes a debug crash for missing font.
