#! /bin/bash
# ------------------------------------------------------------------
# house keeping script to update bapp files
# ------------------------------------------------------------------
SH_VERSION=1.0.5
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: app-check.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error at line $LINENO"' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

echo "########################################"
echo "Updating app metadata, warming the tubes..."

if [[ -z $BAPAPPS_FILES_LOC ]];then
	echo "Error: script must be run from menu.sh" | tee -a $BAP_ERROR_LOG
	exit 1
fi

# Safely upsert KEY=value lines in .bapp files without sed replacement parsing pitfalls.
set_bapp_field(){
	local file="$1"
	local key="$2"
	local value="$3"
	local tmp
	tmp="${file}.tmp.$$"

	awk -v key="$key" -v value="$value" '
		BEGIN { updated=0 }
		$0 ~ "^" key "=" {
			print key "=" value
			updated=1
			next
		}
		{ print }
		END {
			if (!updated) {
				print key "=" value
			}
		}
	' "$file" > "$tmp" && mv "$tmp" "$file"
}

shell_escape_value(){
	printf '%q' "$1"
}

for Job in $BAPAPPS_FILES_LOC; do
	if [ -f $Job ];then
		#get the version function ran to have access here
    	source "${Job}"

		#check function in.bapp file
		[[ $(type -t VERSION) == function ]] && VERSION > >(tee -a $BAP_ERROR_LOG) 2> >(tee -a $BAP_ERROR_LOG >&2)

		#Status Update newer version
		if [[ $NEWVER != "NONE" ]]; then
			set_bapp_field "$Job" "VerRemote" "$(shell_escape_value "$NEWVER")"
		else
			set_bapp_field "$Job" "VerRemote" "NONE"
		fi

		#add found apps to list and metadata update
		if [ "$CURRENT" != "NONE" ]; then
			echo "Found: $ID $CURRENT" | tee -a $FOUND_APPS_FILE

			#check if update is available and set status flag
			if (($(echo "${NEWVER} ${CURRENT}" | awk '{print ($1 > $2)}'))); then
				# Update available
				set_bapp_field "$Job" "VerLocal" "$(shell_escape_value "$CURRENT")"
				set_bapp_field "$Job" "UpdateAvailable" "true"
			else
				# Up to date
				set_bapp_field "$Job" "VerLocal" "$(shell_escape_value "$CURRENT")"
				set_bapp_field "$Job" "UpdateAvailable" "false"
			fi
		else
			set_bapp_field "$Job" "VerLocal" "NONE"
			set_bapp_field "$Job" "UpdateAvailable" "false"
		fi

		#update and file the .bapp LOC= data string for GUI, formats the path into string
		# removes all including the 0- infront of the folder path
		BAPAPPTYP=$(echo $Job | sed 's/apps\///' | sed 's/\.bapp//' | sed 's/\/[0-9]-/-/' | sed 's/\/.*//')

		if grep -q "^LOC=" "$Job" ;then
			#this is intensive needs oneline
			set_bapp_field "$Job" "LOC" "$BAPAPPTYP"
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

echo "Updated $(cat $BAPAPPS_LIST_FILE | grep .bapp | wc -l) apps."

#first boot checking
if [ -f cache/.stage1 ];then
	touch cache/.firstrun
	rm cache/.stage1
fi
exit 0
