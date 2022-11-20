#! /bin/bash
# ------------------------------------------------------------------
# menu enhancer
# ------------------------------------------------------------------
SH_VERSION=1.0.0
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: app-check.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi


#####################################
#	argument handler
DEFAULTVALUE=''
argz="${1:-$DEFAULTVALUE}"
id="${2:-$DEFAULTVALUE}"

if [ "$argz" == "return" ]; then
    bappfile=$(grep -i $id $BAPDIR/$BAPAPPS_LIST_FILE)
    w3=$(grep -m 1 -e '^[[:blank:]]*W3' $bappfile | cut -d = -f 2)
    about=$(grep -m 1 -e '^[[:blank:]]*NOTE' $bappfile | cut -d = -f 2)
    dev=$(grep -m 1 -e '^[[:blank:]]*Author' $bappfile | cut -d = -f 2)

    action=$(yad --width=480 --height=200 --fixed --center --title "About - $id" --image "dialog-question" --button="gtk-ok" \
    --text "Developer Notes and Support for: $id \n $about \n For Support Please see: $w3 \n bapp provided by $dev")
else
    echo -e "\n John 3:16 \n"
    echo -e "Copyright (c) [2022] [Kelly R Keeton K7MHI]\n"
fi
exit 0
