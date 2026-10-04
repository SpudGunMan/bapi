
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

for file in $BAPAPPS_FILES_LOC; do  
    if [ -f $file ];then
        ID=$(grep "ID=" $file | sed 's/ID=//')
        NAME=$(grep "Name=" $file | sed 's/Name=//')
        COMMENT=$(grep "Comment=" $file | sed 's/Comment=//')
        W3=$(grep "W3=" $file | sed 's/W3=//')
        NOTE=$(grep "NOTE=" $file | tr "\n" " " | sed 's/NOTE=//')
    fi
    echo -e "| $ID | $NAME | $COMMENT | $W3 | $NOTE |"

done

