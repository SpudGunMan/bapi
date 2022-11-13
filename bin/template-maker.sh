#! /bin/bash
# ------------------------------------------------------------------
# house keeping script to update bapp files
# ------------------------------------------------------------------
SH_VERSION=0.8.1a
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: template-maker.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

BAPPVER="4"

BUILD_TEMPLATE() {
	cat >"$app".bapp <<TEMPLATEEOF
BAPP=$BAPPVER
ID=$ID
Name=$app
Comment='$comment'
VerLocal=0
VerRemote=0
W3='$www'
Author='$author'
NOTE='long help'

INSTALL(){
    #   operations handled buy the job-runner from the menu selections
    echo -e "INFORMATIONAL: installing"
    # Detect cortex chip (ARM's)
    if [[ "$BAPCPU" == *"ar"* ]]; then
        export BAPsrc="/run/shm/" # example, possibly set the build to ram disk to save SDCARD bashing
    fi

    #common process to all platforms
    cd hamlib || return
    ./configure
    make

    # Detect pi3
    if [[ "$BAPCPU" == *"arm"* ]]; then
        make install
        ldconfig
        make clean
    fi

    # Detect cortex chip (ARM's)
    if [[ "$BAPDIST" == *"ar"* ]]; then
        sudo -A make install
        sudo -A ldconfig
        sudo -A make clean
    fi
}

VERSION(){
    #Required variable ideally dynamic
    NEWVER=0-git
    
    #Required variable ideally dynamic, additionally shows installed or not
    if [[ $(whereis ls | grep bin) ]];then
        CURRENT=0-DEB
    else
        CURRENT=NONE
    fi
}

DEPENDS(){
    NEEDED="" #example of none required
    NEEDED="64BIT|HAMLIB" #Example of Multiple -BAPcore- Dependencies seperated by identifier |

    #additionally further example just like INSTALL you can..
    # Detect pi3
    if [[ "$BAPARCH" == *"arm"* ]]; then
        NEEDED="64BIT"
    fi
}
#EOF

TEMPLATEEOF
}

VALIDATE_FILE() {
    for file in $BAPAPPS_FILES_LOC; do  
        if [ -f $file ];then
            CK_BAPP=$(grep "BAPP=" $file)
            CK_ID=$(grep "ID=" $file)
            CK_NAME=$(grep "Name=" $file)
            CK_COMMENT=$(grep "Comment=" $file)
            CK_LOCAL=$(grep "VerLocal=" $file)
            CK_REMOTE=$(grep "VerRemote=" $file)
            source $file 2>/dev/null

            if [ $? != 0 ] || [ -z "${CK_BAPP}" ] || [ -z "${CK_ID}" ] || [ -z "${CK_NAME}" ] || [ -z "${CK_NAME}" ] || \
                [ -z "${CK_COMMENT}" ] || [ -z "${CK_LOCAL}" ] || [ -z "${CK_REMOTE}" ]; then
                    echo -e "\WARNING: template-checker parsing error on .bapp $file.corrupt" | tee -a $BAP_ERROR_LOG
                    mv $file $file.corrupt
            else
                if [ ${CLI_RUN:=0} -eq 1 ];then
                    DEFAULTVALUE='null'
                    echo -e "INFORMATIONAL: bapp file checks good ${2:-$DEFAULTVALUE}"
                fi
                # exit script
            fi
        fi
    done
    #rebuild app list file
    find apps/* -name '*.bapp' > $BAPAPPS_LIST_FILE
    echo -e "INFORMATIONAL: Found $(cat $BAPAPPS_LIST_FILE | grep .bapp | wc -l) app files"
}

# argument hadler
DEFAULTVALUE=''
argz="${1:-$DEFAULTVALUE}"
if [ "$argz" == "check" ]; then
    #fake enviroment
    if [ ! -z "${2-default}" ];then
        echo -e "INFORMATIONAL: processing ${2-default}"
        BAPAPPS_FILES_LOC=''
        BAPAPPS_FILES_LOC=${2-default}
        
        if [ -f ${2-default} ];then
            CLI_RUN=1
            VALIDATE_FILE
        else
            echo -e "CRITICAL: bad file given"
            exit 1
        fi
    else
        echo -e "INFORMATIONAL: no file given"
        exit 0
    fi
elif [ "$argz" == "bapi" ]; then
    echo "###################################"
    echo -e "INFORMATIONAL: Tuning up, and checking frequency, please stand by..."
    CLI_RUN=0
    VALIDATE_FILE

elif [ "$argz" == "build" ]; then
    echo -e "\nINFORMATIONAL: bapi Template Tool - generate BAPP=$BAPPVER"

    read -p "Enter template single word name: " app
    echo -e "INFORMATIONAL: app name and file name will be: $app\n"

    read -p "Enter $app ID shorthand dont duplicate existing!:" id
    ID=$(echo "${id^^}")
    echo -e "INFORMATIONAL: app ID: $ID\n"

    read -p "Enter $app short short comment:" comment
    echo -e "INFORMATIONAL: app comment field: $comment\n"

    read -p "Enter $app web support page clean as possible:" www
    echo -e "INFORMATIONAL: app W3: $www\n"

    read -p "Enter $app contact or about field for author:" author
    echo -e "INFORMATIONAL: $app: $author\n"
    
    echo -e "INFORMATIONAL: Recap the job we have before us!\nYour .bapp $BAPPVER File will be: $app.bapp\nYour App Name is: $app\nYour App ID is: $ID\nYour App comment is: $comment\nYour App support page is: $www\nfinally your author or you are: $author\n"
    read -p "INFORMATIONAL: CTL C or just keep going!"
    BUILD_TEMPLATE
elif [ "${1-default}" == "help" ]; then
    echo -e "INFORMATIONAL: bapi Template Tool\nOptions are:\n\ncheck - used to validate files and move to corrupt\nbuild - start template generator"
fi

exit 0
