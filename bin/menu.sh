#! /bin/bash
# ------------------------------------------------------------------
# Next Gen Concept Script BuildAPi deps on yad no error check for it yet
# ------------------------------------------------------------------
SH_VERSION=1.0.0
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: menu.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

echo -e "INFORMATIONAL: Welcome, $BAPCALL"

BAP_CONFIG_MENU(){
    yad --width=500 --height=300 --form --title="Config Settings" --center --text "TODO, things like view and scan, add remove?"
}
export -f BAP_CONFIG_MENU

#loops files for data to put into yad table with checkboxes. BAPP column is lost to checkbox.
for bappfile in $BAPAPPS_FILES_LOC; do
    if [ -f $bappfile ];then
        grep -m 1 -e '^[[:blank:]]*BAPP' $bappfile | cut -d = -f 2
        grep -m 1 -e '^[[:blank:]]*ID' $bappfile | cut -d = -f 2
        grep -m 1 -e '^[[:blank:]]*Name' $bappfile | cut -d = -f 2
        grep -m 1 -e '^[[:blank:]]*Comment' $bappfile | cut -d = -f 2
        grep -m 1 -e '^[[:blank:]]*VerLocal' $bappfile | cut -d = -f 2
        grep -m 1 -e '^[[:blank:]]*VerRemote' $bappfile | cut -d = -f 2
        grep -m 1 -e '^[[:blank:]]*LOC' $bappfile | cut -d = -f 2
    fi
done | yad --width=1150 --height=650 --title="Build-A-Pi mark II - The leading edge Ham Radio Software Package Manager - $BAPCALL" --image="gtk-execute" \
            --center --list --print-all --search-column=2 --multiple --checklist --grid-lines=hor --dclick-action='bash -c "$BAPDIR/bin/about.sh return $1"' \
            --column="" --column="ID" --column="App" --column="description" --column="installed version" --column="available version" --column="source"\
            --text="Select package to install. you can sort, or search by typing. <b>Double click for package notes and support details.</b> Detected: $BAPARCH bit $BAPDIST" | \
           grep TRUE | sed 's/TRUE|//' | cut -f1 -d"|" > $APP_ID_FILE

wait
unset BAP_CONFIG_MENU


#turn into APP ID LIST of requested Jobs to run
#APPIDLIST=$(cat $APP_ID_FILE | tr '\n' ' ' | cut -f1 -d"#" | sed 's/ //')
APPIDLIST=$(cat $APP_ID_FILE)
#if we did nothing goodbye
if [ -z "$APPIDLIST" ]; then
      echo -e "INFORMATIONAL: nothing selected to do"
      exit 0
fi

# write timestamp of this selection and copy to disk for historical
echo "$(date +%F-%T) BAP Install Update Requested" >> $INSTALL_HISTORY_FILE
echo $APPIDLIST >> $INSTALL_HISTORY_FILE

#grep all .bapp files and find the matching APP=ID from selection and return .bapp file name for processing
runlist=$(egrep -m 1 -e "ID=$APPIDLIST" $(cat $BAPAPPS_LIST_FILE) | cut -f1 -d":")

#cat $runlist > $JOBFILE
#create a runlist file just as printed above but as a sting for processing
echo $runlist | sed 's/ /\n/' > $JOB_FILE 
   
#this is for check-deps use in export
JOBLIST=$(echo $runlist | sed 's/ /\n/')
    
echo -e "INFORMATIONAL: apps to install $APPIDLIST"
echo -e "INFORMATIONAL: files to process now:\n$runlist"
echo -e "INFORMATIONAL: CPU core for make -j$(sed '2q;d' $BAP_SYS_INFO_FILE)"

#run dependency checker and Set variables it will use
export APPIDLIST
export JOBLIST

./bin/check-deps.sh

exit 0
