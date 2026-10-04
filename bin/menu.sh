#! /bin/bash
# ------------------------------------------------------------------
# Next Gen Concept Script BuildAPi deps on yad no error check for it yet
# ------------------------------------------------------------------
SH_VERSION=1.0.0
# Error and debug controls.
if [ $DEBUG -eq 1 ];then echo "DEBUG: menu.sh"; fi

if test -f ".dev"; then
    set -Eeoxu
    trap 'echo >&2 "Error at line $LINENO"' ERR
elif test -f ".debug"; then
    set -Eeox
else
    set -Ee
fi

extract_bapp_field() {
    local field="$1"
    local file="$2"
    local raw

    raw=$(grep -m 1 -E "^[[:space:]]*${field}=" "$file" 2>/dev/null || true)
    [ -n "$raw" ] || { printf '%s' ""; return 0; }

    raw=${raw#*=}
    raw=${raw%$'\r'}
    raw="${raw#"${raw%%[![:space:]]*}"}"
    raw="${raw%"${raw##*[![:space:]]}"}"

    if [ "${raw:0:1}" = "'" ] && [ "${raw: -1}" = "'" ]; then
        raw="${raw:1:${#raw}-2}"
    elif [ "${raw:0:1}" = '"' ] && [ "${raw: -1}" = '"' ]; then
        raw="${raw:1:${#raw}-2}"
    fi

    printf '%s' "$raw"
}

get_install_status() {
    local verlocal="$1"
    local available="$2"

    if [ "$verlocal" = "NONE" ]; then
        echo "Not Installed"
    elif [ "$available" = "true" ]; then
        echo "Update Available"
    else
        echo "Installed"
    fi
}

emit_bapp_row() {
    local bappfile="$1"
    [ -f "$bappfile" ] || return 0

    local verlocal
    local available
    local status
    local id
    local name
    local comment
    local loc

    verlocal=$(extract_bapp_field "VerLocal" "$bappfile")
    available=$(extract_bapp_field "UpdateAvailable" "$bappfile")
    status=$(get_install_status "$verlocal" "$available")
    id=$(extract_bapp_field "ID" "$bappfile")
    name=$(extract_bapp_field "Name" "$bappfile")
    comment=$(extract_bapp_field "Comment" "$bappfile")
    loc=$(extract_bapp_field "LOC" "$bappfile")

    printf '%s|%s|%s|%s|%s|%s\n' "FALSE" "$id" "$name" "$comment" "$status" "$loc"
}

BAP_CONFIG_MENU(){
    yad --width=500 --height=300 --form --title="Config Settings" --center --text "TODO, things like view and scan, add remove?"
}
export -f BAP_CONFIG_MENU

# Build the menu from the real recursive app list so 0-CORE/HAMLIB is not skipped.
YAD_ARGS=(
    --width=1050
    --height=650
    --title="Build-A-Pi mark II - Ham Radio App Manager - $BAPCALL"
    --image="gtk-execute"
    --center
    --list
    --separator='|'
    --print-all
    --search-column=2
    --multiple
    --checklist
    --grid-lines=hor
    --dclick-action='bash -c "$BAPDIR/bin/about.sh return $1"'
    --column=""
    --column="ID"
    --column="App"
    --column="Description"
    --column="Status"
    --column="Category"
    --text="Select apps to install. You can sort or search by typing. Double-click for details."
    --button="Cancel":1
    --button="Install":2
)

while IFS= read -r bappfile; do
    [ -n "$bappfile" ] || continue
    verlocal=$(extract_bapp_field "VerLocal" "$bappfile")
    available=$(extract_bapp_field "UpdateAvailable" "$bappfile")
    status=$(get_install_status "$verlocal" "$available")
    id=$(extract_bapp_field "ID" "$bappfile")
    name=$(extract_bapp_field "Name" "$bappfile")
    comment=$(extract_bapp_field "Comment" "$bappfile")
    loc=$(extract_bapp_field "LOC" "$bappfile")

    YAD_ARGS+=("FALSE" "$id" "$name" "$comment" "$status" "$loc")
done < <(find apps/stable apps/experimental -type f -name '*.bapp' 2>/dev/null | sort)

# Execute the list with discrete row arguments; this avoids the row-merging bug from pipe-delimited text.
yad "${YAD_ARGS[@]}" 2> /dev/null | grep TRUE | sed 's/^TRUE|//' | cut -f1 -d"|" > $APP_ID_FILE

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
