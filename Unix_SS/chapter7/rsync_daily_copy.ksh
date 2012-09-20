#!/bin/ksh
#
# SCRIPT: rsync_daily_copy.ksh
# AUTHOR: Randy Michael
# DATE: 11/10/2007
# REV: 3.2.Prod
#
# PURPOSE: This script is used to replicate Oracle .dbf
#     files between the "master" DB server and the two
#     OLTP Oracle servers.  The copy method used is
#     rsync. For this method to work, the Oracle DBA must
#     first put the database tables that reside in the
#     copy filesystems into READ-ONLY mode. Before starting
#     rsync copy sessions, this script searches for a file,
#     defined by the $READYTORUN_FILE variable, that is
#     placed on the system by the Oracle DBA team; when
#     the file is found this script will execute
#     all 36 rsync sessions, 18 to each OLTP server,
#     at the same time, then waits for all sessions to
#     complete, both locally and on the remote servers.
#     After the rsync copy sessions complete the copy is
#     verified by matching file sizes between the master
#     copy file and the target copy files. When verified
#     successful this script writes a file to the system,
#     defined by the $COMPLETE_FILE variable, to signal
#     the Oracle DBAs to put the DB back into READ-WRITE
#     mode, copy the metadata over, build the tables and
#     attach the DB on the OLTP side servers. Should a 
#     failure occur a file, defined by the $RSYNCFAILED_FILE
#     variable, is written to the system to signal to the
#     Oracle DBA team an rsync copy process failure.
# 
#
# EXIT CODES:
#             0 ==> Normal execution.
#             1 ==> The value assigned to DAY is not
#                   an integer 1 or 2.
#             2 ==> Remote host is not pingable.
#             3 ==> Copy verification failed. One or
#                   more local files are not the same 
#                   size as the remote files.
#             4 ==> No machines are defined to copy
#                   data to.
#             5 ==> Exited on a trapped signal.
#
# set -x # Uncomment to debug this script
#
# set -n # Uncomment to check the script's syntax
#        # without any execution. Do not forget to
#        # recomment this line!
#
########################################
# REVISION LIST:
########################################
#
# IF YOU MODIFY THIS SCRIPT DOCUMENT THE CHANGE(S)!!!
#
########################################
#
# Revised by: Randy Michael
# Revision Date: 7/23/2007
# Revision: Changed the script to process
# all 36 mount points at a time. 
#
########################################
#
# Revised by: 
# Revision Date: 
# Revision: 
#
##############################################
# DEFINE FILES AND GLOBAL VARIABLES HERE
##############################################

typeset -i DAY
EMAIL_FROM=data_support@gamma
export PATH=$PATH:/usr/local/bin
WORK_DIR=/usr/local/bin
LOGFILE=${WORK_DIR}/rsync_daily_copy.log
SEARCH_DIR=/orabin/apps/oracle/dbadm/general/bin
READYTORUN_FILE=${SEARCH_DIR}/readytocopy.txt
COMPLETE_FILE=${SEARCH_DIR}/copycomplete.txt
RSYNCFAILED_FILE=${SEARCH_DIR}/copyfailed.txt
MAILMESSAGEFILE=${WORK_DIR}/email_message.out
THIS_SCRIPT=$(basename $0)
BG_PID_LIST=
TOTAL=0
THIS_HOST=$(hostname)
[[ $THIS_HOST = gamma ]] && MACHINE_LIST="alpha-rsync bravo-rsync"
[[ $THIS_HOST = gamma-dg ]] && MACHINE_LIST="alpha-rsync bravo-rsync"

# Setup the correct echo command usage. Many Linux
# distributions will execute in BASH even if the
# script specifies Korn shell. BASH shell requires
# we use echo -e when we use \n, \c, etc.

case $SHELL in
*/bin/bash) alias echo="echo -e"
            ;;
esac

##############################################
# DEFINE FUNCTIONS HERE
##############################################

usage ()
{
echo "\nUSAGE: $THIS_SCRIPT Day"
echo "\nWhere Day is 1 or 2\n"
}

##############################################

cleanup_exit ()
{
# If this script is executing, then something failed!

[ $1 ] && EXIT_CODE=$1 

echo "\n$THIS_SCRIPT is exiting on non-zero exit code: $EXIT_CODE"
echo "\nPerforming cleanup..."
echo "Removing $READYTORUN_FILE"
rm -f $READYTORUN_FILE >/dev/null 2>&1
echo "Removing $COMPLETE_FILE"
rm -f $COMPLETE_FILE >/dev/null 2>&1
echo "\nCreating $RSYNCFAILED_FILE"
echo "\nRsync failed on $THIS_HOST with exit code $EXIT_CODE $(date)\n"\
      | tee -a $RSYNCFAILED_FILE
echo "\nCleanup Complete...Exiting..."
return $EXIT_CODE
exit $EXIT_CODE
}

##############################################

trap_exit ()
{
echo "\nERROR: EXITING ON A TRAPPED SIGNAL!\n"
echo "\nRSYNC ERROR: $THIS_HOST -- Rsync process exited abnormally on a \
trapped signal $(date)!" > $MAILMESSAGEFILE

mailx -r "$EMAIL_FROM" -s "SYNC ERROR: $THIS_HOST -- Rsync process exited \
abnormally on a trapped signal!" data_support < $MAILMESSAGEFILE

sleep 2 # Allow the email to go out
cleanup_exit 5
return 5
exit 5
}

##############################################

verify_copy ()
{
#set -x

MYLOGFILE=${WORK_DIR}/verify_rsync_copy_day${DAY}.log
>$MYLOGFILE
ERROR=0

# Enclose this loop so we can redirect output to the log file
# with one assignment at the bottom of the function
{
# Put a header for the verification log file

echo "\nRsync copy verification between $THIS_HOST and machines $MACHINE_LIST\n\n" >$MYLOGFILE


for M in $MACHINE_LIST
do
   for LOC_MP in $(df | grep oradata_dm_[0-2][0-9] | awk '{print $7}')
   do
       LS_FILES=$(find $LOC_MP -type f)
       for FL in $LS_FILES
       do
           LOC_FS=$(ls -l $FL | awk '{print $5}' 2>&1)

           # This sed statement changes the "m" to $DAY
           REM_FL=$(echo $FL | sed s/oradata_dm_/oradata_d${DAY}_/g)

           REM_FS=$(rsh $M ls -l $REM_FL | awk '{print $5}' 2>&1)
           echo "Checking File: $FL"
           echo "Local $THIS_HOST size:\t$LOC_FS"
           echo "Checking Remote File: $REM_FL"
           echo "$M size:\t$REM_FS"
           if [ "$LOC_FS" -ne "$REM_FS" ]
           then
              echo "ERROR: File size mismatch between $THIS_HOST and $M"
              echo "File is: $FL"
              ERROR=1
           fi
       done
   done
done

if (( ERROR != 0 ))
then
    # Record the failure in the log file

    echo "\n\nRSYNC ERROR: $THIS_HOST Rsync copy failed...file size \
mismatch...\n\n" | tee -a $MYLOGFILE

    # Send email notification with file size log

    mailx -r "$EMAIL_FROM" -s "RSYNC ERROR: $THIS_HOST Rsync copy failed\
...file size mismatch -- log attached" data_support < $MYLOGFILE

    echo "\nERROR: Rsync copy Failed!"
    echo "\n\nCheck log file: $MYLOGFILE\n\n"
    echo "\n...Exiting...\n"
    cleanup_exit 3
    return 3
else
    echo "\nSUCCESS: Rsync copy completed successfully..."
    echo "\nAll file sizes match...\n"
fi
} | tee -a $MYLOGFILE

}

########################################

ready_to_run ()
{
# set -x
# This function looks for a file on the system
# defined by the $READYTORUN_FILE variable. The 
# presents presence of this file indicates we are ready
# to run this script. This file will contain a
# number 1 or 2 identifying the day we are 
# working with.

if [ -r ${READYTORUN_FILE} ]
then
     cat ${READYTORUN_FILE}
else
     echo "NOT_READY"
fi
}

##############################################

elapsed_time ()
{
SEC=$1
(( SEC < 60 )) && echo "[Elapsed time: $SEC seconds]\c"

(( SEC >= 60  &&  SEC < 3600 )) && echo "[Elapsed time: $(( SEC / 60 )) \
min $(( SEC % 60 )) sec]\c"

(( SEC > 3600 )) && echo "[Elapsed time: $(( SEC / 3600 )) hr $(( (SEC % 3600) / 60 )) \
min $(( (SEC % 3600) % 60 )) sec]\c"
}

##############################################
# BEGINNING OF MAIN
##############################################

# Set a trap

trap 'trap_exit' 1 2 3 5 6 11 14 15 17

# Save the old log file

cp -f $LOGFILE ${LOGFILE}.yesterday \
      >$LOGFILE

# Enclose the entire main part of the script in 
# curly braces so we can redirect all output of 
# the shell script with a single redirection
# at the bottom of the script to the $LOGFILE

{
echo "\n[[ $THIS_SCRIPT started execution $(date) ]]\n"

# Ensure that target machines are defined

if [ -z "$MACHINE_LIST" ]
then
    echo "\nERROR: No machines are defined to copy data to..."
    echo "\nRSYNC ERROR: $THIS_HOST has no machines are defined \
to copy data to..." > $MAILMESSAGEFILE
    mailx -r "$EMAIL_FROM" -s "RSYNC ERROR: $THIS_HOST has no machines \
defined to copy data to" data_support < $MAILMESSAGEFILE
    echo "...Unable to continue...Exiting..."
    
    cleanup_exit 4
    exit 4
fi

# Checking for currently running versions of this script

echo "Checking for Currently Runnning Versions of this Script"

MYPID=$$ # Capture this scripts PID

MYOTHERPROCESSES=$(ps -ef | grep $THIS_SCRIPT | grep -v $MYPID \
                   | grep -v grep | awk '{print $2}')

if [[ "$MYOTHERPROCESSES" != "" ]]
then
    echo "\WARNING: Another version of this script is running...Killing it!"
    echo "Killing the following processe(es)...$MYOTHERPROCESSES"
    kill -9 $MYOTHERPROCESSES
    echo "\nNOTICE: Sleeping for 1 minute to allow both local 
and remote rsync sessions to terminate, if they exist...\n"
    sleep 60  # Allow any rsync sessions to stop both locally and remotely
else
    echo "No other versions running...proceeding"
fi

# Remove the file that indicates the rsync copy
# is mounted and ready to use, if it exists.

rm -f $COMPLETE_FILE >/dev/null 2>&1

# Remove the file that indicates the rsync copy
# failed and exited on a non-zero exit code, if
# it exists.

rm -f $RSYNCFAILED_FILE >/dev/null 2>&1


# Search for the file indicating we are ready to proceed

# Send notification

echo "\nDaily Rsync Copy Process Began on Host $THIS_HOST $(date)" \
     > $MAILMESSAGEFILE
echo "\nStarted looking for $READYTORUN_FILE" >> $MAILMESSAGEFILE

mailx -r "$EMAIL_FROM" -s "Rsync Copy Process Began Looking for Startup \
File on $THIS_HOST" data_support < $MAILMESSAGEFILE

echo "\nSearching for the file: ${READYTORUN_FILE}"
RUN_STATUS=$(ready_to_run)
until [[ $RUN_STATUS != "NOT_READY" ]]
do
    date
    echo "$READYTORUN_FILE is not present...Sleeping 5 minutes..."
    sleep 300
    RUN_STATUS=$(ready_to_run)
done
date
echo "Found file: $READYTORUN_FILE -- Ready to proceed..."
DAY=$RUN_STATUS


# Test the value assigned to the DAY variable

echo "Testing variable assignment for the DAY variable"

if (( DAY != 1 && DAY != 2 ))
then
    echo "\nRSYNC ERROR: $THIS_HOST -- The value assigned to \
the DAY variable" > $MAILMESSAGEFILE 
    echo "==> $DAY - is not an integer 1 or 2...Exiting..." 
          >> $MAILMESSAGEFILE
    mailx  -r "$EMAIL_FROM" -s "ERROR: $THIS_HOST -- Value assigned \
to the DAY variable $DAY is invalid" data_support < $MAILMESSAGEFILE

    usage
    cleanup_exit
    exit 1
fi

# Ensure the remote machines are reachable through
# the network by sending 1 ping.

echo "Verifying the target machines are pingable...\n"
for M in $MACHINE_LIST
do
    echo "Pinging $M..."
    ping -c1 $M >/dev/null 2>&1
    if (( $? != 0 ))
    then
        echo "RSYNC ERROR: $M is not pingable from $THIS_HOST" \
              > $MAILMESSAGEFILE
        echo "The rsync copy process cannot continue...Exiting" \
              >> $MAILMESSAGEFILE
        mailx -r "$EMAIL_FROM" -s "RSYNC ERROR: $M is not pingable 
from $THIS_HOST" data_support < $MAILMESSAGEFILE

        echo "\nERROR: $M host is not pingable...cannot continue..."
        echo "...EXITING...\n"
        sleep 2
        cleanup_exit 2
        exit 2
    else
        echo "Pinging $M succeeded..."
    fi
done

# Notify start of rsync processing by email

echo "Rsync Copy Process for Day $DAY Starting Execution on \
$THIS_HOST $(date)" > $MAILMESSAGEFILE

mailx -r "$EMAIL_FROM" -s "Rsync copy process for day $DAY starting \
on $THIS_HOST" data_support < $MAILMESSAGEFILE

# Start all of the rsync copy sessions at once by looping
# through each of the mount points and issuing an rsync
# command in the background, and incrementing a counter.

echo "\nStarting a bunch of rsync sessions...\n"

# This script copies from the DM filesystems to the
# Day 1 or Day 2 filesystems on the OLTP servers.

for M in $MACHINE_LIST
do
   for LOC_MP in $(df | grep oradata_dm_[0-2][0-9] | awk '{print $7}')
   do
        # This sed statement changes the "m" to $DAY
        REM_MP=$(echo $LOC_MP | sed s/m/$DAY/g)
        time rsync -avz ${LOC_MP}/ ${M}:${REM_MP} 2>&1 &
        (( TOTAL = TOTAL + 1 ))
   done   
done

# Sleep a few seconds before monitoring processes

sleep 10

# Give some feedback to the end user.

REM_SESSIONS=$(ps -ef | grep "rsync -avz" | grep oradata_dm_[0-2][0-9] \
               | grep -v grep | awk '{print $2}' | wc -l)

if (( REM_SESSIONS > 0 ))
then
   echo "\n$REM_SESSIONS of $TOTAL rsync copy sessions require further updating..."
   echo "\nProcessing rsync copies from $THIS_HOST to both $MACHINE_LIST machines"
   echo "\nPlease be patient, this process may take longer than two hours...\n"
   echo "Rsync is running [Start time: $(date)]\c"
else
   echo "\nAll files appear to be in sync...verifying file sizes...Please wait...\n"
fi

# While the rsync processes are executing this loop
# will place a . (dot) every 60 seconds as feedback
# to the end user that the background rsync copy 
# processes are still executing. When the remaining
# rsync sessions are less than the total number of
# sessions (normally 36) this loop will give feedback
# as to the number of remaining rsync session, as well
# as the elapsed time of the procesing, every 5 minutes.

SECONDS=10
MIN_COUNTER=0

until  (( REM_SESSIONS == 0 ))
do 
    sleep 60
    echo ".\c"
    REM_SESSIONS=$(ps -ef | grep "rsync -avz" | grep oradata_dm_[0-2][0-9] \
                   | grep -v grep | awk '{print $2}' | wc -l)
    if (( REM_SESSIONS < TOTAL ))
    then
        (( MIN_COUNTER = MIN_COUNTER + 1 ))
        if (( MIN_COUNTER >= 5 ))
        then 
           MIN_COUNTER=0
           echo "\n$REM_SESSIONS of $TOTAL rsync sessions \
remaining $(elapsed_time $SECONDS)\c"
           if (( REM_SESSIONS <= $(( TOTAL / 4 )) ))
           then
              echo "\nRemaining rsync sessions include:\n"
              ps -ef | grep "rsync -avz" | grep oradata_dm_[0-2][0-9] \
                     | grep -v grep
              echo
           fi
        fi
    fi
done 

echo "\n...Local rsync processing completed on $THIS_HOST...$(date)"
echo "\n...Checking remote target machines: $MACHINE_LIST..."

# Just because the local rsync processes have completed does
# not mean that the remote rsync processes have completed
# execution. This loop verifies that all of the remote
# rsync processes completed execution. The end user will
# receive feedback if any of the remote processes are running.

for M in $MACHINE_LIST
do
   for LOC_MP in $(df | grep oradata_dm_[0-2][0-9] | awk '{print $7}')
   do
       # This sed statement changes the "m" to $DAY
       REM_MP=$(echo $LOC_MP | sed s/m/$DAY/g)
       
       RPID=$(rsh $M ps -ef | grep rsync | grep $REM_MP \
              | grep -v grep | awk '{print $2}')

       until [ -z "$RPID" ]
       do
           echo "rsync is processing ${REM_MP} on ${M}...sleeping one minute..."
           sleep 60
           RPID=$(rsh $M ps -ef | grep rsync | grep $REM_MP \
                  | grep -v grep | awk '{print $2}')
       done
   done
done

echo "\n...Remote rsync processing completed $(date)\n"

# Verify the copy process

verify_copy
if (( $? != 0 ))
then
    exit 3
fi

# Write to the $COMPLETE_FILE to signal the Oracle DBAs
# that the copy has completed

echo "Rsync copy from $THIS_HOST to machines $MACHINE_LIST \
completed successfully $(date)" | tee -a $COMPLETE_FILE

# Remove the ready to run file

rm -f $READYTORUN_FILE >/dev/null 2>&1

# Notify completion by email

echo "Rsync Copy for Day $DAY Completed Successful Execution \
on $THIS_HOST $(date)\n" > $MAILMESSAGEFILE
elapsed_time $SECONDS >> $MAILMESSAGEFILE
mailx -r "$EMAIL_FROM" -s "Rsync copy for day $DAY completed \
successfully on $THIS_HOST" data_support < $MAILMESSAGEFILE

echo "\nRsync copy completed $(date)"

echo "\n[[ $THIS_SCRIPT completed execution $(date) ]]\n"

exit 0

} | 2>&1 tee -a $LOGFILE

###############################################
# END OF SCRIPT
###############################################
