
## To manually install Box/Wine on a Pi

## Pi5 only 16K pagesize incompatible with wine/box
- https://github.com/raspberrypi/bookworm-feedback/issues/107
 
switch to 4k-page
- add `kernel=kernel8.img` to /boot/config.txt
- reboot

## Pi4 or 5 tip for stability March2023
wine-wow64 isnt helpfull for vara.exe a 32bit app
RECOMEND: use a 32bit OS image to cheat

# Pi4 or 5 to load box 86
Load up Pi-Apps http://pi-apps.io
- `wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash`
- Use the Pi-Apps GUI navigate to Tools->Emulation
  - install Wine 32bit
  - install Box86 32bit

the .wine folder they build for you is bloated you may consider deleting it and starting fresh

## Installing Wine on Intel /Debian
https://wiki.winehq.org/Ubuntu

## To manually install latest winetricks
```
wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks 
sudo mv -v winetricks /usr/local/bin
```
## Configure Wine
- Install DLL with winetricks by running "winetricks" from CLI
  - You may want to run `WINEARCH=win32 winetricks` to set it up the first time, on ARM64 wow64 it will fail
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

## Vara
- Download Vara, WinLink bundle
  - `wget -r -A "*.zip" 'https://downloads.winlink.org/'`

- copy all the OCX files in VARA rather then set paths or register
  - `cp ~/.wine/drive_c/VARA/OCX/* ~/.wine/drive_c/VARA/`

- [https://github.com/islandmagic/varanny](https://github.com/islandmagic/varanny)

## VarAC
- needs a free login get it from https://www.varac-hamradio.com/downloadlinux
- [missing fonts?](https://github.com/SpudGunMan/segoe-ui-linux) they are not installed as part of this tool yet

- remember to validate your VarAC.ini and disable `LinixCompatibleMode=OFF` liklely misplaced in ~/
  - `sed -i 's/LinuxCompatibleMode=OFF/LinuxCompatibleMode=ON/' ~/.wine/drive_c/VarAC/VarAC.ini`

- VarAC isn't loading well in older wine recommend version 8 or higher
