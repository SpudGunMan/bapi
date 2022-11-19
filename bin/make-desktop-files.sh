#! /bin/bash
# ------------------------------------------------------------------
# checks job files for any missed required apps to also be added
# ------------------------------------------------------------------
SH_VERSION=1.0.0
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: check-deps.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

exit 1
BAPINSTALL_FILE=cache/install-path.bap

#create build-a-pi menu item
cd ${MYPATH} || ! echo "Failure"

FLSUITE(){
    ##########################
    #	FLSUITE 
    ##########################
    CATEGORY=flsuite

    FLPATH=/usr/local/share/applications

    if [ -f $FLPATH/fldigi.desktop ]; then
        echo "updating fldigi"
        sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/fldigi.desktop
    fi

    if [ -f $FLPATH/flamp.desktop ]; then
        echo "updating flamp"
        sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flamp.desktop
    fi

    if [ -f $FLPATH/flarq.desktop ]; then
        echo "updating flarq"
        sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flarq.desktop
    fi

    if [ -f $FLPATH/flmsg.desktop ]; then
        echo "updating flmsg"
        sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flmsg.desktop
    fi

    if [ -f $FLPATH/flnet.desktop ]; then
        echo "updating flnet"
        sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flnet.desktop
    fi

    if [ -f $FLPATH/flwrap.desktop ]; then
        echo "updating flwrap"
        sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flwrap.desktop
    fi

    if [ -f $FLPATH/flwrap.desktop ]; then
        echo "updating flrig"
        sudo sed -i "s/Categories.*/Categories=$CATEGORY/" $FLPATH/flrig.desktop
    fi
}

BAP(){
    ##########################
    #	BAP 
    ##########################

    cd /run/user/$UID

    #DONATE
    if [ ! -f /usr/local/share/applications/donate.desktop ]; then
        cat >donate.desktop <<EOF
    [Desktop Entry]
    Name=Donate
    Comment=Donate to Build a Pi
    Exec=xdg-open https://www.paypal.com/paypalme/km4ack
    Icon=/home/`whoami`/pi-build/logo.png
    Terminal=false
    Type=Application
    Categories=bap
    Keywords=Support
    EOF

        sudo mv donate.desktop /usr/local/share/applications/
    fi

    #FAQ
    if [ ! -f /usr/local/share/applications/faq.desktop ]; then
        cat >faq.desktop <<EOF
    [Desktop Entry]
    Name=FAQ
    Comment=Build a Pi FAQ
    Exec=xdg-open https://app.simplenote.com/publish/C3bBxN
    Icon=/home/`whoami`/pi-build/logo.png
    Terminal=false
    Type=Application
    Categories=bap
    Keywords=Support

    EOF

        sudo mv faq.desktop /usr/local/share/applications/
    fi

    #SUPPORT
    if [ ! -f /usr/local/share/applications/support.desktop ]; then
        cat >support.desktop <<EOF
    [Desktop Entry]
    Name=Tech Support
    Comment=Build a Pi Tech Support
    Exec=xdg-open https://groups.io/g/KM4ACK-Pi/topics
    Icon=/home/`whoami`/pi-build/logo.png
    Terminal=false
    Type=Application
    Categories=bap
    Keywords=Support

    EOF

        sudo mv support.desktop /usr/local/share/applications/
    fi

    if [ ! -f /usr/local/share/applications/build-a-pi.desktop ]; then
    sudo mv /usr/share/applications/build-a-pi.desktop /usr/local/share/applications/
    sudo sed -i 's/Categories.*/Categories=bap/' /usr/local/share/applications/build-a-pi.desktop
    sudo sed -i 's/Name.*/Name=Update-Tool/' /usr/local/share/applications/build-a-pi.desktop
    fi
}


    #MOD HAMRADIO.MENU FILE
    cat >hamradio.menu <<EOF
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
    "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
    <Menu>
    <Name>Applications</Name>
    <Menu>
        <Name>Hamradio</Name>
        <Directory>HamRadio.directory</Directory>
        <Include>
            <Category>HamRadio</Category>
        </Include>
        <Menu>
        <Name>FLSUITE</Name>
        <Directory>FLsuite.directory</Directory>
        <Include>
            <Category>flsuite</Category>
        </Include>
        </Menu>
            <Menu>
                <Name>KM4ACK</Name>
                <Directory>km4ack.directory</Directory>
                <Include>
                    <Category>km4ack</Category>
                </Include>

            </Menu>
        <Menu>
            <Name>Build-a-Pi</Name>
            <Directory>bap.directory</Directory>
            <Include>
                <Category>bap</Category>
            </Include>

        </Menu>
    </Menu> <!-- End hamradio -->
    </Menu>
    EOF

    sudo mv hamradio.menu /usr/share/extra-xdg-menus/
}


if [[ "$BAPCPU" == *"ar"* ]]; then
    #verify ham menu is installed
    if [ ! -f /usr/share/extra-xdg-menus/hamradio.menu ]; then
    sudo apt install -y extra-xdg-menus
    fi

    BAP
    CREATEMENU
    FLSUITE
fi
