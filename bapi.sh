#! /bin/bash
#loader
SH_VERSION=1.0.7a #set up git missing installer (huh?)
echo "###################################"
echo "#      Build-A-Pi mark II.80      #"
echo "###################################"

#set working directory
BAPDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$BAPDIR"

#ENVAR
mkdir -p cache
mkdir -p errors
touch errors/apt.log
BAPSYSINFO=cache/cpu.bap
BAPSRC=$(echo ${HOME}/.bap-source-files)
BAP_ERROR_DIR=$(echo $BAPDIR/errors)
BAP_SYS_INFO_FILE=cache/cpu.bap
BAPINSTALL_FILE=cache/install-path.bap
BAPAPPS_LIST_FILE=cache/bapps-list.bap
FOUND_APPS_FILE=cache/apps-found-list.bap
echo $BAPDIR > $BAPINSTALL_FILE
APP_ID_FILE=cache/requested-apps.bap
JOB_FILE=cache/run-list.bap
BAP_ERROR_LOG=$(echo $BAP_ERROR_DIR/general-alarm.log)
INSTALL_HISTORY_FILE=cache/reqst-install-history.bap
if [ ! -f errors/apt.log ];then install -Dv /dev/null errors/apt.log ;fi
BAPAPPS_FILES_LOC="apps/stable/*.bapp apps/stable/**/*.bapp apps/experimental/*.bapp apps/experimental/**/*.bapp"
BAPPVER="4" #.bapp file version #also update template-maker.sh
BAPWHOAMI=$(whoami)
mkdir -p "$BAPSRC"

#####################################
#	DEV DEBUG
if test -f ".dev"; then
    DEBUG=1
    set -Eeoxu pipefail
    trap 'echo >&2 "Error at line $LINENO"' ERR
elif test -f ".debug"; then
    DEBUG=1
    set -Eeox
    trap 'echo >&2 "Error at line $LINENO"' ERR
else
    DEBUG=0
    set -Ee
fi
export DEBUG
if [ $DEBUG -eq 1 ];then echo -e "DEBUG: ON: additional tools:   touch .skip-dev-apt && touch .force-run"; fi

YAD_INFO_F(){
    local msg_txt=${1:-'dialog box'}
    msg_txt=${1:-'dialog box'}
    yad 2> /dev/null --title="bAPi" --center --button="OK" --text="$msg_txt"
}

#####################################
#	export globals
export BAPSRC
export BAP_SYS_INFO_FILE
export APP_ID_FILE
export JOB_FILE
export INSTALL_HISTORY_FILE
export FOUND_APPS_FILE
export BAPPVER
export BAPAPPS_LIST_FILE
export BAPAPPS_FILES_LOC
export BAP_ERROR_LOG
export BAP_ERROR_DIR
export BAPDIR
export BAPWHOAMI
export -f YAD_INFO_F

SETUP(){
    if [ $DEBUG -eq 1 ];then echo "DEBUG: Starting system setup"; fi
    #Install YAD
    echo "Updating packages..."
    sudo apt-get -y update > errors/apt.log
    if [[ $(whereis yad | grep bin) ]];then
        echo "yad found" > /dev/null
    else
        echo "Installing required packages..."
        sudo apt-get -y install git >> errors/apt.log
        sudo apt-get -y install yad >> errors/apt.log
        sudo apt-get -y install curl >> errors/apt.log
    fi

    # Detect if the script health and .git
    if [ ! -f "data/build-utility.bap" ]; then
        echo "Error: Package integrity issue. Please reinstall."
        git pull
        exit 1
    fi

    # check if the bin package setup the enviroment
    if [ -f bin/set-enviroment.sh ]; then
        echo "Setting up new system"
        ./bin/set-enviroment.sh
    else
        echo "Error: Package integrity issue." | tee -a $BAP_ERROR_LOG
        exit 1
    fi
    touch cache/.stage1
    # Note: app-check.sh will be called later in main flow
}

echo "Checking system..."
#   We need a terminal this isnt a background or full yad GUI
if [ ! -t 0 ]; then
    echo "Error: This script requires 'run in terminal." | tee -a $BAP_ERROR_LOG
    exit 1
fi

if ! printenv | grep -q DISPLAY; then
	echo "Error: This script requires a graphical display." | tee -a $BAP_ERROR_LOG
    exit 1
fi

#####################################
#	Verify not run as root
BAPWHOAMI=$(whoami)
if [ "$BAPWHOAMI" = 'root' ]; then
	echo "Error: Do not run as root. Restart without sudo." | tee -a $BAP_ERROR_LOG
	exit 1
else
    echo "Please enter your password if prompted for sudo..."
    sudo cp LICENSE /dev/null 2>/dev/null || echo "License file missing"
fi

#####################################
#	Check Enviroment

#	change working directory
if [ $BAPDIR != $( cat $BAPINSTALL_FILE) ]; then
     echo "Warning: Working directory mismatch" | tee -a $BAP_ERROR_LOG
fi

if [ ! -d $BAPDIR/apps/stable ]; then
    mkdir -p $BAPDIR/apps
    cp -r $BAPDIR/data/app_db/* ./apps/
else
    # Use a temp dir for atomic update
    TMP_APPS_DIR=$(mktemp -d)
    cp -r $BAPDIR/data/app_db/* "$TMP_APPS_DIR/"
    if [ $? -eq 0 ]; then
        # Optionally backup old apps
        # mv ./apps ./apps_backup_$(date +%s)
        cp -r "$TMP_APPS_DIR/"* ./apps/
        echo "Checking for app updates..."
        ./bin/app-check.sh
    else
        echo "Error: Failed to update apps. Try: rm -rf apps/ cache/" | tee -a $BAP_ERROR_LOG
    fi
    rm -rf "$TMP_APPS_DIR"
fi


#run enviroment setup scripts for first run
if [ ! -f "$BAP_SYS_INFO_FILE" ]; then
    # call setup function
    echo "Setting up system..."
    SETUP
fi

#####################################
#	check dev tools
if [ -f '.skip-dev-apt' ]; then 
    echo "Using custom dev kit"
fi

if [ ! -f MYCALL.* ]; then
    # call setup function
    echo "Error: MYCALL not configured" | tee -a $BAP_ERROR_LOG
    exit 1
else
    MYCALL=$(ls MYCALL.* | sed 's/MYCALL.//')
    BAPCALL=$(ls MYCALL.* | sed 's/MYCALL.//')
fi

#####################################
#	check app files
if [ -f $JOB_FILE ]; then
    # check since last job run
    echo "Checking for changes..."
    rm cache/run-list.bap 2>/dev/null
    ./bin/app-check.sh
else
    # validate good .bapp files quickly no version updates we didnt cause a change to them
    ./bin/template-maker.sh bapi
fi

#####################################
#	Normal Runtime
BAPARCH=$(echo $(sed '1q;d' $BAP_SYS_INFO_FILE))
BAPCORE=$(echo $(sed '2q;d' $BAP_SYS_INFO_FILE))
BAPCPU=$(echo $(sed '3q;d' $BAP_SYS_INFO_FILE))
BAPDIST=$(echo $(sed '4q;d' $BAP_SYS_INFO_FILE))
PKG_PROFILE=$(ls cache/PKG_* | sed 's/cache\///'g | sed 's/.bap//')
export PKG_PROFILE
export BAPCPU
export BAPCORE
export BAPARCH
export BAPDIST
export BAPCALL
export MYCALL

if [ ! -f cache/.firstrun ]; then
    echo "Error: System setup incomplete. Try: ./bin/set-enviroment.sh reset" | tee -a $BAP_ERROR_LOG
else
    if [[ "$PKG_PROFILE" == *"PKG_DEF"* ]]; then
        #launch menu
        ./bin/menu.sh
    fi

    #launch job-runer
    ./bin/bap-runner.sh

    #goodbye
    echo -e "Done. 73s."   
fi

exit 0