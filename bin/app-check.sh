#! /bin/bash
# ------------------------------------------------------------------
# house keeping script to update bapp files
# ------------------------------------------------------------------
SH_VERSION=1.0.5
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: app-check.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

echo "########################################"
echo -e "INFORMATIONAL: Updating menu/app meta-data, warming the tubes.."

if [[ -z $BAPAPPS_FILES_LOC ]];then
	echo -e "ERROR: script ran outside of menu.sh" | tee -a $BAP_ERROR_LOG
	exit 1
fi

# Escape replacement strings used in sed s||| operations.
sed_escape_replacement(){
	# Escape sed replacement metacharacters and delimiter for s||| commands.
	printf '%s' "$1" | sed 's/[\\&|]/\\&/g'
}

for Job in $BAPAPPS_FILES_LOC; do
	if [ -f $Job ];then
		#get the version function ran to have access here
    	source "${Job}"

		#check function in.bapp file
		[[ $(type -t VERSION) == function ]] && VERSION > >(tee -a $BAP_ERROR_LOG) 2> >(tee -a $BAP_ERROR_LOG >&2)

		#Status Update newer version
		if [[ $NEWVER != "NONE" ]]; then
			NEWVER_SAFE=$(sed_escape_replacement "$NEWVER")
			sed -i "s|^VerRemote=.*|VerRemote='$NEWVER_SAFE'|" "$Job"
		else
			sed -i "s|^VerRemote=.*|VerRemote='NONE'|" "$Job"
		fi

		#add found apps to list and metadata update
		if [ "$CURRENT" != "NONE" ]; then
			echo -e "INFORMATIONAL: found $ID $CURRENT is installed" | tee -a $FOUND_APPS_FILE

			#check if update is available
			if (($(echo "${NEWVER} ${CURRENT}" | awk '{print ($1 > $2)}'))); then
				echo -e "INFORMATIONAL: $ID: $NEWVER is available for update!"
				#Status Update newer version
				CURRENT_SAFE=$(sed_escape_replacement "$CURRENT")
				sed -i "s|^VerLocal=.*|VerLocal='Update:$CURRENT_SAFE'|" "$Job"
				
			else
				#Status Update current version
				CURRENT_SAFE=$(sed_escape_replacement "$CURRENT")
				sed -i "s|^VerLocal=.*|VerLocal='$CURRENT_SAFE'|" "$Job"
			fi
		else
			sed -i "s|^VerLocal=.*|VerLocal='NONE'|" "$Job"
		fi

		#update and file the .bapp LOC= data string for GUI, formats the path into string
		# removes all including the 0- infront of the folder path
		BAPAPPTYP=$(echo $Job | sed 's/apps\///' | sed 's/\.bapp//' | sed 's/\/[0-9]-/-/' | sed 's/\/.*//')

		if grep -Fxq "LOC=" $Job ;then
			#this is intensive needs oneline
			BAPAPPTYP_SAFE=$(sed_escape_replacement "$BAPAPPTYP")
			sed -i "s|^LOC=core$|LOC=$BAPAPPTYP_SAFE|" "$Job"
			sed -i "s|^LOC=experimental$|LOC=$BAPAPPTYP_SAFE|" "$Job"
			sed -i "s|^LOC=''$|LOC=$BAPAPPTYP_SAFE|" "$Job"
		else
			#echo -e "INFORMATIONAL: new folder location data."
			echo -e "\nLOC=$BAPAPPTYP" >> $Job
		fi

	fi
done

#rebuild app list file
find apps/* -name '*.bapp' > $BAPAPPS_LIST_FILE
#remove duplicates
awk '!seen[$0]++' $BAPAPPS_LIST_FILE > $BAPAPPS_LIST_FILE.tmp
mv $BAPAPPS_LIST_FILE.tmp $BAPAPPS_LIST_FILE
rm -f $BAPAPPS_LIST_FILE.tmp

echo -e "INFORMATIONAL: Updated $(cat $BAPAPPS_LIST_FILE | grep .bapp | wc -l) apps meta-data fields."

#first boot checking
if [ -f cache/.stage1 ];then
	touch cache/.firstrun
	rm cache/.stage1
fi
exit 0
