#! /bin/bash
# envioment checking
# depends on lscpu (likely able to work around this in other ways) which appears to be on debian anyway
SH_VERSION=1.0.0
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: set-env.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

#####################################
#	argument handler
DEFAULTVALUE=''
argz="${1:-$DEFAULTVALUE}"
if [ "$argz" == "reset" ]; then
    echo -e "DANGER: This will delete user Data and /.bap-source-files"
    read -ep  "press Y/y to continue.." -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [ -f ../cache/* ];then rm -f ../cache/* ; fi
            if [ -f ../MYCALL.* ];then rm -f ../MYCALL.* ; fi
            rm -f cache/* > /dev/null
            rm -f MYCALL.* > /dev/null
            sudo rm -rf ${HOME}/.bap-source-files
            mkdir -p errors/
            echo -e "enviroment reset - first log\n" > errors/general-alarm.log
            echo -e "enviroment reset - first log\n" > errors/apt.log
            echo -e "INFORMATIONAL: Reset bapi user data and removed ${HOME}/.bap-source-files"
            echo -e "INFORMATIONAL: optionally rm -rf apps/ and it will be rebuilt next launch"
            exit 0
        else
            exit 0
        fi
elif [ "$argz" == "clean" ]; then
    read -p "DANGER: This will delete /.bap-source-files are you sure? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\nDo dangerous stuff"
        rm -rf ${HOME}/.bap-source-files
        rm -rf apps/stable
        rm -rf apps/experimental
        echo -e "\nI hope you know what you did!"
        exit 0
    fi
else
    echo "###################################"
    echo -e "INFORMATIONAL: Setting up enviroment"
    echo "###################################"
fi

#####################################
#	set hardware id

#the following works for pi/raspian/debian and mint
rm -f /tmp/bap-env-*
lscpu > /tmp/bap-env-lscpu
eval "$(sed -n 's/^ID=/distribution=/p' /etc/os-release)"
eval "$(sed -n 's/^VERSION_ID=/version=/p' /etc/os-release | tr -d '"')"
eval "$(sed -n 's/^Architecture:                    /arch=/p' /tmp/bap-env-lscpu)"
eval "$(sed -n 's/^CPU(s):                          /cpu=/p' /tmp/bap-env-lscpu)"

#fix older version output
if [ -z $cpu ]; then
    eval "$(sed -n 's/^CPU(s):              /cpu=/p' /tmp/bap-env-lscpu)"
fi
if [ -z $arch ]; then
    eval "$(sed -n 's/^Architecture:        /arch=/p' /tmp/bap-env-lscpu)"
fi

#errors are bad so exit 1 if we still have a mess
if [ -z $arch ]; then
    echo -e "ERROR: Unknown Please report: $distribution $version $arch with $cpu cores"
    exit 1
fi
if [ -z $cpu ]; then
    echo -e "ERROR: Unknown Please report: $distribution $version $arch with $cpu cores"
    exit 1
fi


# the following will detect Ubuntu and..
if [ -z $distribution ]; then
    #this detection method isnt good for PI but is for others.
    source /etc/lsb-release 
        #DISTRIB_ID
        #DISTRIB_RELEASE
        #DISTRIB_CODENAME
        #DISTRIB_DESCRIPTION
    $distribution='$DISTRIB_ID'

fi
if [ -z $version ]; then
    #return string release might be better? unused.
    $version='$DISTRIB_CODENAME'
fi

case "$arch" in
    armv7l)
        CPU=32
        if [ -f /sys/firmware/devicetree/base/model ];then
            IFS= read -r -d '' model </proc/device-tree/model || [[ $model ]]
    
            if [[ "$model" == *"Pi 2"* ]]; then
                echo -e "WARNING: Pi2 detected setting cores to two"
                cpu=2 #the pi2 is unstable with all cores in use via VNC and SSH
            fi
        fi
        
        if [ -f "/usr/bin/wine" ]; then export BAPWINEARCH=32; fi
        ;;
    aarch64)
        CPU=64
        if [ -f "/usr/bin/wine" ]; then export BAPWINEARCH=64; fi
        ;;
    x86_64)
        CPU=64
        if [ -f "/usr/bin/wine" ]; then export BAPWINEARCH=64; fi
        ;;
    x86)
        CPU=32
        if [ -f "/usr/bin/wine" ]; then export BAPWINEARCH=32; fi
        ;;
    *)
        echo -e "ERROR: Unsupported: $arch with $cpu cores"
        ;;
esac

case "$distribution" in
    raspbian)
        ls > /dev/null #nothing yet
        ;;
    debian)
        ls > /dev/null #nothing yet
        ;;
    linuxmint)
        ls > /dev/null #nothing yet
        ;;
    ubuntu)
        #consider DISTRIB_RELEASE less than 20 to say no
        if [ "$DISTRIB_CODENAME" == "bionic" ];then
            echo -e "WARNING: UNTESTED reasonably old, upgrade!:" | tee -a $BAP_ERROR_LOG
        fi
        ;;
    *)
        echo -e "ERROR: Unsupported: $distribution $version you have a $arch with $cpu cores no plans currently"
        exit 1
        ;;
esac

#####################################
# create directory locations

#	set repo directory
mkdir -p ${HOME}/.bap-source-files

#used to autostart conky at boot
mkdir -p ${HOME}/.config/autostart


#####################################
#   set the station call sign, if youre here to snip this remember to give credit for the rest!
N0CALL=$(yad --form --width=420 --text-align=center --center \
    --title="Amature Radio Callsign Required" --center --image="gtk-execute" \
    --field="Call Sign" \
    --field="<b>Required</b>":LBL \
    --button="Continue")

#input validate
TMPCALL=$(echo "${N0CALL^^}" | sed 's/||//' | awk '{gsub(/[^[:alnum:][:space:]]/,"?")} 1')

if echo "$TMPCALL" | grep -q "?";then
    echo -e "\n ERROR: CRITICAL: valid call to operate (no SSID) $TMPCALL QRZ?" | tee -a $BAP_ERROR_LOG
    exit 1
fi

#blank check call
if [ $N0CALL = "||" ] || [ $N0CALL = "" ]; then
    echo -e "\n ERROR: CRITICAL: need a radio call to operate, nothing heard QRZ?" | tee -a $BAP_ERROR_LOG
    exit 1
else
    #save
    MYCALL=$TMPCALL
    BAPCALL=$TMPCALL
    touch MYCALL.$MYCALL
    touch cache/MYCALL.$MYCALL
    echo -e "INFORMATIONAL: Registered $MYCALL to this host"
fi

#set a config register for use by all apps first line is bits, second is core for make -j4
echo -e "$CPU\n$cpu\n$arch\n$distribution\n$MYCALL\n$(hostname -s)" > $BAP_SYS_INFO_FILE
echo -e "INFORMATIONAL: set enviroment $CPU $arch $distribution"
BAPARCH=$CPU
BAPCORE=$cpu
BAPCPU=$arch
BAPDIST=$distribution

# Show once dialog and profile selections
list="Default-Chosen EM1COM APRS Skip-Installing-DEV-tools"
until [ "$select" = "8" ]; do
        action=$(yad --form --width=420 --height=200 --fixed --center --entry --title="Welcome!" \
        --image=data/ico/logo.png --image-on-top --text-align=fill --button="gtk-ok" \
        --text="\n<b>$MYCALL DE K7MHI</b> \n
        Welcome to the new and improved.. \n
            <b>Build-A-Pi mark II</b> \n
        Now with feature enhanced secret sauce! \n
                -BAPI PRE-RELEASE - SEE README \n
                -Double click app in menu for notes \n
                -Press ESC now to exit!" \
        --entry-text $list)
        
        ret=$?
        [[ $ret -ge 1 ]] && exit 0
        case $action in
            De*) clear ; touch cache/PKG_DEFAULT.bap && break ;; #Default
            EM1*) clear ; touch cache/PKG_EM1COM.bap && touch .skip-dev-apt && break ;; #Load EM1COM Package
            EM2*) clear ; touch cache/PKG_EM2COM.bap && touch .skip-dev-apt && break ;; #Load EM2COM Package
            AP*) clear ; touch cache/PKG_APRS.bap && touch .skip-dev-apt && break ;; #Load APRS
            Sk*) clear ; touch cache/PKG_DEFAULT.bap && touch .skip-dev-apt && break ;;
        esac
done

PKG_PROFILE=$(ls cache/PKG_* | sed 's/cache\///'g | sed 's/.bap//')
echo -e "INFORMATIONAL: Install: $PKG_PROFILE"

#####################################
#	extra build scripts can be called here or in the 
#   /data/build-utility.bap file as shown below
#   if using static code better in the .bap
#   first spot sudo is called externally as well might hold for all distros
if [ $DEBUG -eq 1 ];then echo -e "DEBUG: Run Once Scripts located at set-enviroment"; fi

ln -s ${HOME}/.bap-source-files src
source ./data/build-utility.bap
PULSE_SOUND_VIRT_ADD
SET_BAP_WALLPAPER
SET_DIALUP_USER
VNC_PERF

#####################################
# Developent Enviroment setup 
# for now this is here till a better spot or idea
# the problem really is front loading a lot of heavy stuff at home vs cell phone field or just over and over
if [ ! -f '.skip-dev-apt' ] && [ ! -f '.ran-dev-apt' ];then
    echo -e "INFORMATIONAL: Installing developer tools, this may take some time."
    COMMON_DEVELOPER_TOOLS_INSTALL >> errors/apt.log
else
    echo -e "INFORMATIONAL: developer tools NOT installed skipped"
fi

export MYCALL
export BAPCALL

exit 0
