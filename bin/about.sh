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

read_bapp_field() {
    local field="$1"
    local file="$2"
    local raw

    raw=$(grep -m 1 -E "^[[:space:]]*${field}=" "$file" 2>/dev/null || true)
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

if [ "$argz" == "return" ]; then
    bappfile=$(grep -i $id $BAPDIR/$BAPAPPS_LIST_FILE)
    w3=$(read_bapp_field "W3" "$bappfile")
    about=$(read_bapp_field "NOTE" "$bappfile")
    dev=$(read_bapp_field "Author" "$bappfile")

    action=$(yad --width=480 --height=200 --fixed --center --title "About - $id" --image "dialog-question" --button="gtk-ok" \
    --text "Developer Notes and Support for: $id \n $about \n For Support Please see: $w3 \n bapp provided by $dev")
else
    echo -e "\n John 3:16 \n"
    echo -e "Copyright (c) [2023] [Kelly R Keeton K7MHI]\n"
fi
