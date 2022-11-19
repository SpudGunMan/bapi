#! /bin/bash
#loader
SH_VERSION=1.0.0a #set up git missing installer 
echo "###################################"
echo "#      Build-A-Pi mark II         #"
echo "###################################"

#set working directory
BAPDIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $BAPDIR

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
mkdir -p $BAPSRC

#####################################
#	DEV DEBUG
if test -f ".dev"; then
    DEBUG=1
    set -Eeoxu pipefail
    trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR
elif test -f ".debug"; then
    DEBUG=1
    set -Eeox
    trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR
else
    DEBUG=0
    set -Ee
fi
export DEBUG
if [ $DEBUG -eq 1 ];then echo -e "DEBUG: ON: additional tools:   touch .skip-dev-apt && touch .force-run"; fi

YAD_INFO_F(){
    msg_txt=${1:-'dialog box'}
    yad --title="bAPi" --center --button="OK" --text="$msg_txt"
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
    if [ $DEBUG -eq 1 ];then echo -e "DEBUG: bapi.sh SETUP function"; fi
    #Install YAD
    #echo -e "INFORMATIONAL: Enter your password if prompted to elevate"
    echo -e "INFORMATIONAL: apt-get update.."
    sudo apt-get -y update > errors/apt.log
    if [[ $(whereis yad | grep bin) ]];then
        echo "yad found" > /dev/null
    else
        echo -e "\n ERROR: WARNING: dependency yad, git, curl needed checking.."
        sudo apt-get -y install git >> errors/apt.log
        sudo apt-get -y install yad >> errors/apt.log
        sudo apt-get -y install curl >> errors/apt.log
    fi

    # Detect if the script health and .git
    if [ ! -f "data/build-utility.bap" ]; then
        echo -e "\n CRITICAL: critical enviroment issue, please see the below output"
        #add script to check for cache and apps if not there copy from data folder
        #this will prevent the pull from erasing also
        git pull
        exit 1
        #add smarts to not overwrite a folder here when git pull is done copy from data new install and git
    fi

    # check if the bin package setup the enviroment
    if [ -f bin/set-enviroment.sh ]; then
        echo -e "INFORMATIONAL: Detected New System for Install $(hostname -s)"
        ./bin/set-enviroment.sh
    else
        echo -e "\n ERROR: CRITICAL: check integrity of package. delete it all and start over!" | tee -a $BAP_ERROR_LOG
        exit 1
    fi
    touch cache/.stage1
    #check for updates on new run
    ./bin/app-check.sh
    wait
}

#####################################
#	Verify not run remote
echo -e "INFORMATIONAL: checking local console TTY settings"
#   We need a terminal this isnt a background or full yad GUI
if [ ! -t 0 ]; then
    echo -e "\n CRITICAL: EXIT: This script requires 'run in terminal.'" | tee -a $BAP_ERROR_LOG
    exit 1
fi

IS_GUI=$(printenv | grep DISPLAY)
if [ -z "$IS_GUI" ]; then
	echo -e "\n CRITICAL: EXIT: This script requires run local and yad GUI at this time." | tee -a $BAP_ERROR_LOG
    exit 1
fi

#####################################
#	Verify not run as root
BAPWHOAMI=$(whoami)
if [ "$BAPWHOAMI" = 'root' ]; then
	echo -e "\n CRITICAL: EXIT:root user DETECTED restart the script without" | tee -a $BAP_ERROR_LOG
	exit 1
else
    echo -e "INFORMATIONAL: Enter your password for sudo if prompted"
    sudo cp LICENSE /dev/null || echo -e "License file missing..."
fi

#####################################
#	Check Enviroment

#	change working directory
if [ $BAPDIR != $( cat $BAPINSTALL_FILE) ]; then
     echo -e "\nWARNING: Possible enviroment directory change" | tee -a $BAP_ERROR_LOG
fi

# app check
if [ ! -d $BAPDIR/apps/stable ]; then
    #cp -ur data/app_db/stable apps/stable
    mkdir -p $BAPDIR/apps
    cp -ur $BAPDIR/data/app_db/* ./apps/
else
    #sortin legos for no reason, problem is git updates..
    # dont like it for now edit the data/app_db and thats the master db
    echo -e "INFORMATIONAL: Checking if any updates to bapp files, please review!" 
    return= $(cp -iur $BAPDIR/data/app_db/* ./apps/)
    if [ ! -z $return ]; then
        echo -e "INFORMATIONAL: changes to app files detected. checking SWR.." 
        #we can assume something changed cp had file diff scan for it
        ./bin/app-check.sh
    fi
fi

#run enviroment setup scripts for first run
if [ ! -f "$BAP_SYS_INFO_FILE" ]; then
    # call setup function
    echo -e "\nWARNING: missing enviroment launching set-enviroment" | tee -a $BAP_ERROR_LOG
    SETUP
fi

#####################################
#	check dev tools
if [ -f '.skip-dev-apt' ]; then 
    echo -e "INFORMATIONAL: Using custom dev kit" | tee -a $BAP_ERROR_LOG
fi

if [ ! -f MYCALL.* ]; then
    # call setup function
    echo -e "\nCRITICAL: missing MYCALL dev needs to debug?" | tee -a $BAP_ERROR_LOG
    exit 1
else
    MYCALL=$(ls MYCALL.* | sed 's/MYCALL.//')
    BAPCALL=$(ls MYCALL.* | sed 's/MYCALL.//')
fi

#####################################
#	check app files
if [ -f $JOB_FILE ]; then
    # check since last job run
    echo -e "INFORMATIONAL: Scanning Changes since last Job-Run" | tee -a $BAP_ERROR_LOG
    rm cache/run-list.bap | tee -a $BAP_ERROR_LOG
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
    echo -e "\n CRITICAL: data corruption try a >  ./bin/set-enviroment.sh reset" | tee -a $BAP_ERROR_LOG
else
    if [[ "$PKG_PROFILE" == *"PKG_DEF"* ]]; then
        #launch menu
        ./bin/menu.sh
    fi

    #launch job-runer
    ./bin/bap-runner.sh

    #goodbye
    echo -e "see you down the log \n .. 73\n"   
fi

exit 0