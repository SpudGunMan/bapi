## Pi5 only bookworm 16K pagesize incompatible with wine/box (Dec42023)
- https://github.com/raspberrypi/bookworm-feedback/issues/107
 
switch to 4k-page adding 
- `kernel=kernel8.img` to /boot/config.txt
- reboot

## To manually install VARA and WinLink on a Pi
Load up Pi-Apps http://pi-apps.io
- `wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash`
- Use the Pi-Apps GUI navigate to Tools->Emulation
  - install Box86 (also installs wine)
- Install DLL with winetricks by running "winetricks" from CLI
  - press OK for 'default prefix'
  - choose install a DLL or component
  - Select some needed DLL and press OK to install
    - comdlg32ocx, pdh-nt4, vb6run, ahk
- Download Vara, VarAC, WineLink, Install them all, if you install VarAC first it will open the Vara Modem download page from CLI you can run with "wine setup.exe"
- copy all the OCX files in VARA rather then set paths or register
  - `cp ~/.wine/drive_c/VARA/OCX/* ~/.wine/drive_c/VARA/`