#! /bin/bash
# ------------------------------------------------------------------
# house keeping script to update bapp files
# ------------------------------------------------------------------
SH_VERSION=1.0.0
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

for Job in $BAPAPPS_FILES_LOC; do
	if [ -f $Job ];then
		#get the version function ran to have access here
    	source "${Job}"
		#pull function from file
		[[ $(type -t VERSION) == function ]] && VERSION > >(tee -a $BAP_ERROR_LOG) 2> >(tee -a $BAP_ERROR_LOG >&2)
		#echo "###################################"
		#echo "Check Version  $ID 	"

		#CHECK NEW VER AND CUR VER with bad math checking as its strings
		#update .bapp with new data gathered from .bapp VERSION function

		#Status Update current version
		if [[ $CURRENT =~ "^[0-9]+$" ]]; then
			sed -i "s/VerLocal=.*/VerLocal='$CURRENT'/" $Job
		else
			sed -i "s/VerLocal=.*/VerLocal='$CURRENT'/" $Job
		fi

		#add found to list
		if [ "$CURRENT" != "NONE" ]; then
			echo -e "INFORMATIONAL: found $ID $CURRENT is installed" | tee -a $FOUND_APPS_FILE
		fi

		#Status Update newer version
		if [[ $NEWVER =~ "^[0-9]+$" ]]; then
			sed -i "s/VerRemote=.*/VerRemote='$NEWVER'/" $Job
		else
			if (($(echo "${NEWVER} ${CURRENT}" | awk '{print ($1 > $2)}'))); then
				echo -e "INFORMATIONAL: $ID: $NEWVER is available for update!"
				sed -i "s/VerRemote=.*/VerRemote='Update:$NEWVER'/" $Job
			else
				#echo -e "INFORMATIONAL: $CURRENT appears the newest"
				sed -i "s/VerRemote=.*/VerRemote='$NEWVER'/" $Job
			fi
		fi

		#update and file the .bapp LOC= data string for GUI, formats the path into string
		# removes all including the 0- infront of the folder path
		BAPAPPTYP=$(echo $Job | sed 's/apps\///' | sed 's/\.bapp//' | sed 's/\/[0-9]-/-/' | sed 's/\/.*//')

		if grep -Fxq "LOC=" $Job ;then
			#this is intensive needs oneline
			sed -i "s/LOC=core/LOC=$BAPAPPTYP/" $Job
			sed -i "s/LOC=experimental/LOC=$BAPAPPTYP/"
			sed -i "s/LOC=''/LOC=$BAPAPPTYP/" $Job
		else
			#echo -e "INFORMATIONAL: new folder location data."
			echo -e "\nLOC=$BAPAPPTYP" >> $Job
		fi

	fi
done

#rebuild app list file
find apps/* -name '*.bapp' > $BAPAPPS_LIST_FILE
echo -e "INFORMATIONAL: Updated $(cat $BAPAPPS_LIST_FILE | grep .bapp | wc -l) apps meta-data fields."

#first boot checking
if [ -f cache/.stage1 ];then
	touch cache/.firstrun
	rm cache/.stage1
fi
exit 0
