
#! /bin/bash
# ------------------------------------------------------------------
# github.md maker
# ------------------------------------------------------------------
SH_VERSION=1.0.1
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: app-readme.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

BAPAPPS_FILES_LOC="apps/stable/*.bapp apps/stable/**/*.bapp apps/experimental/*.bapp apps/experimental/**/*.bapp"


echo -e "| ID | Name | Comment | Website | Dev Note |"
echo -e "| --- | --- | --- | --- | --- |"

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

for file in $BAPAPPS_FILES_LOC; do  
    if [ -f $file ];then
        ID=$(read_bapp_field "ID" "$file")
        NAME=$(read_bapp_field "Name" "$file")
        COMMENT=$(read_bapp_field "Comment" "$file")
        W3=$(read_bapp_field "W3" "$file")
        NOTE=$(read_bapp_field "NOTE" "$file")
    fi
    echo -e "| $ID | $NAME | $COMMENT | $W3 | $NOTE |"

done

