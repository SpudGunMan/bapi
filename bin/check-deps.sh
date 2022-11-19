#! /bin/bash
# ------------------------------------------------------------------
# checks job files for any missed required apps to also be added
# ------------------------------------------------------------------
SH_VERSION=0.8.9a
#Error and DEBUG
if [ ${DEBUG:=0} -eq 1 ];then echo -e "DEBUG: check-deps.sh"; fi
if test -f ".dev"; then set -Eeoxu;trap 'echo >&2 "Error - exited with status $? at line $LINENO:"; 
         pr -tn $0 | tail -n+$((LINENO - 3)) | head -n7 >&2' ERR;elif test -f ".debug"; then set -Eeox;else set -Ee; fi

echo "###################################"
echo "#	Checking for Dependcies "
echo "###################################"

for Job in $JOBLIST; do  
    #check depends of from .bapp files get NEEDED
    source "${Job}"
	[[ $(type -t DEPENDS) == function ]] && DEPENDS
    echo -e "INFORMATIONAL: Processing: $Job"

	#if missing handle
    if [ ! -z "$NEEDED" ];then
		DEP_BASE_ISSUES=$(egrep -e $NEEDED data/base-apps.bap)
		echo -e "INFORMATIONAL: Required: $NEEDED"

		for MISSING_BASE in $DEP_BASE_ISSUES;do
			echo -e "INFORMATIONAL: Checking problems with choices, there is always with mine.."
			### Check deps!
			CURRENTLY_REQ=$(grep -ie $MISSING_BASE $APP_ID_FILE) || echo ''
			ADD_DEP_LIST=$(grep -ie $MISSING_BASE $BAPAPPS_LIST_FILE) || echo ''
			if [ -f $FOUND_APPS_FILE ];then FOUND_APP=$(grep -ie $MISSING_BASE $FOUND_APPS_FILE) || echo '' ; fi

			if [ ! -z "$DEP_BASE_ISSUES" ];then
				echo -e "\nWARNING: missing dependency $MISSING_BASE needs resolved!" | tee -a $BAP_ERROR_LOG

				# is this 64
				if [ "$MISSING_BASE" == "64BIT" ];then
					echo -e "INFORMATIONAL: Detected: $BAPARCH bit" | tee -a $BAP_ERROR_LOG
					echo -e "\nCRITICAL: missing required hardware 64b-ARCH" | tee -a $BAP_ERROR_LOG
					echo -e "INFORMATIONAL: removing $MISSING_BASE and $Job"
					#remove from jobs
					#sed -r "s:$Job::" $JOB_FILE | sed '/^$/d' > $JOB_FILE
					continue 
				fi

				#did we find it installed ignore it
				if [ ! -z "$FOUND_APP" ];then
					continue
				fi
				#are we installing it now? ignore it
				if [ ! -z "$CURRENTLY_REQ" ];then
					echo -e "INFORMATIONAL: adjusting plate current.."
					sed -i "1s:^:$ADD_DEP_LIST\n:" $JOB_FILE
					continue
				fi
				#find the path for the missing known file and add to the top of the job list
				if [ ! -z "$ADD_DEP_LIST" ];then
					echo -e "INFORMATIONAL: Resolving: $MISSING_BASE Job:$Job"
					echo -e "INFORMATIONAL: adjusting grid current.."
					sed -i "1s:^:$ADD_DEP_LIST\n:" $JOB_FILE
				else
					echo -e "\nCRITICAL: further issues remain with $MISSING_BASE and $Job" | tee -a $BAP_ERROR_LOG
					YADWARNING=$(yad --center --title "Warning" --image "dialog-warning" --button="gtk-ok" --text "Warning that $MISSING_BASE should be handled first.")
				fi

			fi
		done
		echo -e "INFORMATIONAL: finished processing jobs, new joblist:\n$(cat $JOB_FILE)\n"
	else
	echo -e "INFORMATIONAL: check-deps: nothing to process."
    fi
done
exit 0
