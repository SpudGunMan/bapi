#! /bin/bash
# ------------------------------------------------------------------
# process manager
# ------------------------------------------------------------------
SH_VERSION=1.0.0
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: bap-runner.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

#Globals Dev doc. for use here or in .bapp
# var-BAPCPU  (armv7l / aarch64 / x86_64)
# var-BAPCORE (used for make -j)
# var-BAPARCH (64/32)
# var-BAPDIST (raspbian/debian/linuxmint)
# var-BAPDIR (root of application)
# var-BAPCALL / MYCALL
# var-MYCALL de k7mhi :)
# var-INSTALL_HISTORY_FILE (lifetime record of the app ID and datestamp)
# var-BAPPVER (bapp file versioning)
# var-BAP_ERROR_LOG ( generic error file )
# var-BAP_ERROR_DIR ( dump junk here if worth review)
# var-BAPAPPS_LIST_FILE ( list of all known good checked in .bapp files available )
# var-BAPAPPS_FILES_LOC ( large directory listing for search for bapp files )
# var-BAPSRC ( ${HOME}/.bap-source-files)
#
# var-JOBLIST (menu.sh created list of .bapp after selection --BEFORE-- dep-check processing.)
# var-APP_ID_FILE (recently selected menu items ID,space seprated)
# var-JOB_FILE ( run list of bapp files final output of dep checker processing)

#common scripts
#source ./data/build-utility.bap

execute_build_function() { 
    if [ ! -z $JOB_FILE ];then
        JOBLIST=$(cat $JOB_FILE)
        
        #launch funfacts
        #( bash -c 'data/funfacts' & )

        #process 
        for Job in $JOBLIST; do  
            #source INSTAL
            cd $BAPDIR
            source "${Job}"

            echo "###################################"
            echo "bapi processing: $Job"
            echo "###################################"
            if [[ $(type -t INSTALL) == function ]];then
                if [ $DEBUG -eq 0 ];then set +Ee; fi # Disable Debug
                INSTALL 2> >(tee -a $BAP_ERROR_LOG)
                wait
            fi
        done
    fi
}

profile_check_function() {
    if [[ $PKG_PROFILE == *"PKG_DE"* ]]; then
        echo -e "\n . QRU .."
    elif [[ $PKG_PROFILE == *"PKG_EM"* ]]; then
        echo -e "\nINFORMATION: EMCOM DEPLPYMENT"

        #done with work go back to PKG_DEFXDEV
        mv cache/PKG_* cache/PKG_DEFXDEV.bap

    elif [[ $PKG_PROFILE == *"PKG_APRS"* ]]; then
        echo -e "\nINFORMATION: APRS DEPLOYMENT"

        #deploy list, this can be moved to .bapp file INSTALL for ease of use?
        APPIDLIST="XASTIR|GPS|AX25"
        runlist=$(egrep -m 1 -e "ID=$APPIDLIST" $(cat $BAPAPPS_LIST_FILE) | cut -f1 -d":")
        echo $runlist | sed 's/ /\n/' > $JOB_FILE
        execute_build_function

        #done with work go back to PKG_DEFXDEV
        mv cache/PKG_* cache/PKG_DEFXDEV.bap

        execute_build_function
    else
        echo -e "WARNING: unknown deployment package:$PKG_PROFILE"
    fi
}

if [ -f $JOB_FILE ]; then
    echo "###################################"
    echo "#            Job Runner           #"
    echo "###################################"
    execute_build_function
else
    profile_check_function
fi

#kill off funfacts!
# running=$(ps aux | grep -m 1 data/funfacts)
# if [[ $running == *"bash"* ]];then
#     pid=$(ps aux | grep -m 1 data/funfacts | head -1 | awk '{print $2}')
#     kill -9 $pid > /dev/null 2>&1
# fi

exit 0
