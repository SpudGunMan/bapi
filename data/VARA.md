## Pi5 only bookworm 16K pagesize incompatible with wine/box (Dec42023)
- https://github.com/raspberrypi/bookworm-feedback/issues/107
 
switch to 4k-page adding 
- `kernel=kernel8.img` to /boot/config.txt
- reboot

## To manually install Box/Wine on a Pi
Load up Pi-Apps http://pi-apps.io
- `wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash`
- Use the Pi-Apps GUI navigate to Tools->Emulation
  - install Box86 32
  - install Wine 32

## To manually install latest winetricks
```
wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks 
sudo mv -v winetricks /usr/local/bin
```
## Configure Wine
- Install DLL with winetricks by running "winetricks" from CLI
  - You may want to run `WINEARCH=win32 winetricks` to set it up the first time
  - press OK for 'default prefix'
  - choose install a DLL or component
  - Select some needed DLL and press OK to install
    - comdlg32ocx, comctl32oxc, pdh-nt4, vb6run
    - VarAC
      - vcrun2003, vcrun2005, vcrun2008, vcrun2010
```         WINEARCH=win32 winecfg
            /usr/local/bin/winetricks --force pdh_nt4
            /usr/local/bin/winetricks --force vb6run
            /usr/local/bin/winetricks --force comdlg32ocx
            /usr/local/bin/winetricks --force comctl32ocx
            /usr/local/bin/winetricks --force vcrun2003
            /usr/local/bin/winetricks --force vcrun2005
            /usr/local/bin/winetricks --force vcrun2008
            /usr/local/bin/winetricks --force vcrun2010
            /usr/local/bin/winetricks --force corefonts
```

- Download Vara, VarAC, WineLink, Install them all
  - `wget -r -A "*.zip" 'https://downloads.winlink.org/'`
  - `https://www.dropbox.com/scl/fi/r69gwmt3tqfvlp95u4bko/VarAC_Installer_V8_4_4.exe`

- copy all the OCX files in VARA rather then set paths or register
  - `cp ~/.wine/drive_c/VARA/OCX/* ~/.wine/drive_c/VARA/`

- [missing fonts?](https://github.com/SpudGunMan/segoe-ui-linux) they are not installed as part of this tool yet

- remember to validate your VarAC.ini and disable `LinixCompatibleMode=OFF` liklely misplaced in ~/
  - `sed -i 's/LinuxCompatibleMode=OFF/LinuxCompatibleMode=ON/' ~/.wine/drive_c/VarAC/VarAC.ini`

- [https://github.com/islandmagic/varanny](https://github.com/islandmagic/varanny)