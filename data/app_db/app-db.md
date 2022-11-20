# App Packages

| ID | Name | Comment | Website | Dev Note |
| --- | --- | --- | --- | --- |
|  |  |  |  |  |
| HAMLIB | hamlib | 'hamlib rig control' | 'https://sourceforge.net/projects/hamlib/support' | "Allows install of github or sourceforge code typically github is newer. Will detect and install python libs as well"  |
| FLRIG | flrig | 'flrig Rig Control' | 'http://www.w1hkj.com' | 'pulling directly from the dev home page'  |
| WFVIEW | wfview | 'icom rig controller' | 'https://wfview.org' | ''  |
| WFVSVR | wfServer | 'wfView Server icom rig control' | 'https://wfview.org' | 'this is not required for wfview its for standalone operations'  |
| ARDOP | ARDOP | 'ARDOP modem and GUI' | 'https://www.cantab.net/users/john.wiseman/' | 'pi is using precompiled bins, the gui on X86 bin is corrupt and building from source GUI_win32.exe will work in wine'  |
| CODEC2 | CODEC2 | 'low bit rate speech codec' | 'https://freedv.org' | 'core libs for CODEC2 project'  |
| DIREWOLF | direwolf | 'soundcard AX.25 modem/TNC and APRS' | 'https://packet-radio.net/direwolf/' | 'you can choose to use dev or main branch'  |
| MMON | multimon-ng | 'digital transmission modem' | '' | ''  |
| SoundModem | QTSoundModem | 'UZ7HO SoundModem' | 'http://uz7.ho.ua/packetradio.htm' | ''  |
| VARA | VARA++ | 'WINE - VARA Modem, RMS Express, VarAC' | 'https://github.com/WheezyE/Winelink/tree/main/docs' | 'WheezyE/Winelink installer script: failure? try re-running'  |
| DRATS | D-RATS | 'icom DSTAR D-RATS software' | 'https://github.com/ham-radio-software/D-Rats' | 'git clone no good version details found yet this will install python3 as well as dev kit'  |
| FDATA | FreeDATA | 'codec2 - TNC' | 'https://wiki.freedata.app/en' | 'installs to HOME and there is a launcher script this also installs npm and nodejs'  |
| FLAMP | flamp | 'Multicast Protocol - file transfer program' | 'http://www.w1hkj.com' | 'the source had issues, need to double check not bapi fault'  |
| FLDIGI | fldigi | 'multi-mode soundcard modem' | 'http://www.w1hkj.com' | ''  |
| FLMSG | flmsg | 'NBEMS messaging system' | 'http://www.w1hkj.com' | ''  |
| FREEDV | FreeDV | 'GUI for FreeDV  using the CODEC2' | 'https://freedv.org' | 'no launcher yet'  |
| GARIM | GARIM | 'ARDOP AR-IM' | '' | 'needs ARDOP modem but not required'  |
| JS8CALL | JS8CALL | 'JS8CALL Project' | 'http://js8call.com' | 'installs to /bin/local'  |
| QSSTV | QSSTV | 'SSTV Soundcard Modem' | 'https://www.qsl.net/on4qz/' | 'git clone no good version details found yet'  |
| VARIM | vARIM | 'Vara AR-IM' | '' | 'needs VARA modem but not required'  |
| WSJTX | WSJT-X | 'FST4, FST4W, FT4, FT8, JT4, JT9, JT65, Q65, MSK144, and WSPR' | 'https://physics.princeton.edu/pulsar/k1jt/wsjtx.html' | 'installed to /usr/local/bin to get better performance note .. renice -n -19 -u wsjtx'  |
| ANTVIS | antennavis | 'antenna radiation pattern visualization' | 'http://www.include.gr/antennavis.html' | 'deb package has a lot of depends'  |
| ANTSCOPE2 | AntScope2 | 'Antenna Scope2 Rigexpert' | 'https://rigexpert.com/antscope2-for-rasberry-pi-raspbian/' | 'installs to HOME, using static links to code from web along with git'  |
| AX25 | AX25 | 'linux AX25 tools' | 'https://tldp.org/HOWTO/pdf/AX25-HOWTO.pdf' | 'adds telnet and linpac,uronode will auto add your call to axports'  |
| CHIRP | CHIRP | 'Chirp Radio Programmer' | '' | 'this will also delay menu load because chirp -version is slow'  |
| CQRPROP | HAMQSL-Propigation | 'N0NBH Propigation Tool' | 'http://www.hamqsl.com/solar.html' | ''  |
| DOCS | ReferenceDocs | 'Reference Charts from ARRL and Icom' | '' | ''  |
| FLNET | flnet | 'voice net controller database' | 'http://www.w1hkj.com' | ''  |
| FLWRAP | flwrap | 'file encapsulation / compression' | 'http://www.w1hkj.com' | 'had issues with compile could be code related'  |
| GPredict | GPredict | 'real-time satellite tracking and orbit prediction' | 'http://gpredict.oz9aec.net/index.php' | 'git clone no good version details found yet'  |
| GPS | GPS | 'GPS Services and KM4ACK tools' | '' | 'includes some extras'  |
| GridTracker | GridTracker | 'display data from WSJT/AIDF on a map' | 'https://gridtracker.org' | 'commonly has download issues needs NWJS a 1.3GB package FYI'  |
| HAMCLOCK | HamClock | 'ClearSky Ham CLock' Ham Clock | 'http://www.clearskyinstitute.com/ham/HamClock' | ''  |
| M0IAX | JS8CALLTools | 'm0iax Tools for JS8CALL' | '' | 'git clone no good version details found yet'  |
| PROPREP | Propigation | 'RF Propagation Tools' | 'https://www.qsl.net/h/hz1jw//voacapl/index.html' | 'git clone no good version details found yet'  |
| PULSE | PULSE | 'PULSE AUDIO Control' | '' | 'debian package'  |
| RSTART | Repeater-START | 'view nearby ham radio repeaters' | 'https://sourceforge.net/projects/repeater-start/' | 'sf clone no good version details found yet'  |
| TNCGAMES | TNCGAMES | 'Chess and Checkers for your AX25 TNC' | 'http://uz7.ho.ua' | ''  |
| XDX | Xdx | 'DX Cluster Spotting app' | 'https://sourceforge.net/projects/xdxclusterclient/' | 'non functioning TODO'  |
| XASTIR | XASTIR | 'APRS Client' | '' | ''  |
| YAAC | YAAC | 'Yet Anotter APRS Client JAVA' | 'https://www.ka2ddo.org/ka2ddo/YAAC.html' | 'this will install java and the jre packages'  |
| CQRLOG | TECQRLOGMPLT | 'Logging Software' | 'https://www.cqrlog.com/' | '' NOTE=''  |
| HAMRS | HAM-RS-Logger | 'HAM RS Logging Software' | 'https://www.hamrs.app' | 'cross package install on pi4:64 as there is no binary. no source.'  |
| KLOG | K-LOG | 'K-LOG' | 'https://www.klog.xyz' | 'version thing needs looked at added -j core and didnt test yet'  |
| PYQSO | PY-QSO-Logger | 'Light Weight Contacting Logging' | 'https://christianjacobs.uk/pyqso/' | 'you need hamlib with python to get connections'  |
| TQSL | T-QSL | 'ARRL Log Uploader' | 'https://lotw.arrl.org/lotw-help/' | 'updates are handled in the app ideally not here'  |
| GQRX | GQRX | 'GQRX SDR Software' | 'https://gqrx.dk' | 'installs a mess of SDR rules as well'  |
| SDRTRUNK | 'SDR TRUNK' | 'SDR Trunking Decoder' | 'https://github.com/DSheirer/sdrtrunk' | 'statc web link to release packages'  |
| URH | RadioHacker | 'Universal Radio RF hacker Tool' | 'https://github.com/jopohl/urh' | 'installs soapy etc..'  |
| URH | RadioHacker | 'Universal Radio RF hacker Tool' | 'https://github.com/jopohl/urh' | 'installs soapy etc..'  |
| AUTOHOTSPOT | AutoHotSpot | 'Allows a Raspberry Pi WiFi Hotspot' | 'https://www.raspberryconnect.com/' | 'not fully yad-GUI yet'  |
| CONKY | CONKY | 'Conky Telemetry Display' | '' | 'Depends on GPS, Pi only at the moment'  |
| GridCalc | KM4GridCalc | 'KM4ACK Grid Calculating Tool' | '' | 'no cross compile scripts tested'  |
| PIAPRS | KM4-PI-APRS | 'KM4ACK PI APRS' | 'https://github.com/km4ack/Pi-APRS' | 'no cross compile scripts tested'  |
| PI-RTC | PI-RTC | 'pi Real Time Clock tools' | '' | 'un tested'  |
| AGWPE | AGWPE | 'AGWPE in box:wine' | 'http://www.sv2agw.com/' | 'https://www.soundcardpacket.org/6AGWPrograms.aspx and https://www.soundcardpacket.org/6compat.aspx'  |
| BLUEDV | bluedv | 'bluedv DSTAR DEXTRA, DPLUS, DCS, FUSION DMR' | 'https://www.pa7lim.nl/bluedv-linux/' | 'building now what'  |
| BPQ32 | linBPQ | 'BPQ32 Node, APRS BBS and Chat Server AND bpq-config' | 'https://www.cantab.net/users/john.wiseman/Documents/InstallingLINBPQ.htm' | 'also installs http://www.prinmath.com/ham/bpq-config and BPQAPRS. Will set your call for default values on config'  |
| DROID | DroidStar | 'DroidStar DMR, P25, NXDN, D-STAR (REF/XRF/DCS)' | 'https://github.com/nostar/DroidStar' | 'builds where to put it now'  |
| JTDX | JTDX | 'WSJT DX Project' | 'https://jtdx.freeforums.net' | 'this currently builds but not installing it yet where to?'  |
| PAT | PAT-WINLINK | 'Pat Winlink' | 'https://groups.google.com/g/pat-users' | 'installs go and pat from github source, very basic setup'  |
| QtTermTCP | QtTermTCP | 'multi-platform version of BPQTermTCP' | 'https://www.cantab.net/users/john.wiseman/Documents/QtTermTCP.html' | ''  |
| SHARE-TNC | SHARE-TNC | 'Share a serial TNC using KISS over TCP/IP' | 'https://github.com/trasukg/share-tnc' | 'installs npm'  |
| TNCAttach | TNC-Attach | 'Attach KISS TNC devices as network interfaces in Linux.' | 'https://unsigned.io/ethernet-and-ip-over-packet-radio-tncs/' | ''  |
| TT3 | TinyTrack3/4 | 'TinyTrak3/4 Configuration Software' | 'https://www.byonics.com/products' | 'serial ports work?'  |
| WSJT-ZED | WSJT-Zed | 'WSJT-Zed Project' | '' | 'this currently builds but not installing it where to?'  |
