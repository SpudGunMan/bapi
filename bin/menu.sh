#! /bin/bash
# ------------------------------------------------------------------
# Next Gen Concept Script BuildAPi deps on yad no error check for it yet
# ------------------------------------------------------------------
SH_VERSION=1.0.0
# Error and debug controls.
if [ "${DEBUG:=0}" -eq 1 ]; then
    echo "DEBUG: menu.sh"
fi

if test -f ".dev"; then
    set -Eeoxu
    trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR
elif test -f ".debug"; then
    set -Eeox
else
    set -Ee
fi

extract_bapp_field() {
    local field="$1"
    local file="$2"
    grep -m 1 -e "^[[:blank:]]*$field" "$file" | cut -d = -f 2
}

emit_bapp_row() {
    local bappfile="$1"
    [ -f "$bappfile" ] || return 0

    extract_bapp_field "BAPP" "$bappfile"
    extract_bapp_field "ID" "$bappfile"
    extract_bapp_field "Name" "$bappfile"
    extract_bapp_field "Comment" "$bappfile"
    extract_bapp_field "VerRemote" "$bappfile"
    extract_bapp_field "VerLocal" "$bappfile"
    extract_bapp_field "LOC" "$bappfile"
}

BAP_CONFIG_MENU(){
    yad --width=500 --height=300 --form --title="Config Settings" --center --text "TODO, things like view and scan, add remove?"
}
export -f BAP_CONFIG_MENU

# loops files for data to put into yad table with checkboxes. BAPP column is lost to checkbox.
for bappfile in $BAPAPPS_FILES_LOC; do
    emit_bapp_row "$bappfile"
done | yad 2> /dev/null --width=1150 --height=650 --title="Build-A-Pi mark II - The leading edge Ham Radio Software Package Manager - $BAPCALL" --image="gtk-execute" \
            --center --list --print-all --search-column=2 --multiple --checklist --grid-lines=hor --dclick-action='bash -c "$BAPDIR/bin/about.sh return $1"' \
            --column="" --column="ID" --column="App" --column="description" --column="available version" --column="installed version" --column="source"\
            --text="Select package to install. you can sort, or search by typing. <b>Double click for package notes and support details.</b> Detected: $BAPARCH bit $BAPDIST" --button="Nope":1 --button="Lets Go!":2 | \
           grep TRUE | sed 's/TRUE|//' | cut -f1 -d"|" > $APP_ID_FILE

wait
unset BAP_CONFIG_MENU


#turn into APP ID LIST of requested Jobs to run
#APPIDLIST=$(cat $APP_ID_FILE | tr '\n' ' ' | cut -f1 -d"#" | sed 's/ //')
APPIDLIST=$(cat "$APP_ID_FILE")
#if we did nothing goodbye
if [ -z "$APPIDLIST" ]; then
    exit 0
fi

# write timestamp of this selection and copy to disk for historical
echo "$(date +%F-%T) BAP Install Update Requested" >> "$INSTALL_HISTORY_FILE"
echo "$APPIDLIST" >> "$INSTALL_HISTORY_FILE"

# grep all .bapp files and find the matching APP=ID from selection and return .bapp file name for processing
runlist=$(
    while IFS= read -r appid; do
        [ -n "$appid" ] || continue
        grep -m 1 -e "ID=$appid" $(cat "$BAPAPPS_LIST_FILE") | cut -f1 -d":" || true
    done < "$APP_ID_FILE"
)

#create a runlist file just as printed above but as a sting for processing
printf '%s\n' "$runlist" | sed '/^[[:space:]]*$/d' > "$JOB_FILE"
   
#this is for check-deps use in export
JOBLIST=$(cat "$JOB_FILE")

#run dependency checker and Set variables it will use
export APPIDLIST
export JOBLIST

./bin/check-deps.sh

exit 0
