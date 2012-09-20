#!/bin/bash
#
# SCRIPT: generic_DIR_rsync_copy.bash
# AUTHOR: Randy Michael
# DATE: 1/14/2007
# REV: 1.0
# PLATFORM: Not platform dependent
#
# REQUIRED INSTALLATION: rsync must be 
#          installed on the source and
#          all target systems
#
# REQUIRED FILE FOR OPERATION: 
#          The file pointed to by the 
#          $DIR_LIST_FILE variable refers
#          to the required file listing the 
#          top level directory structures
#          that rsync is to replicate. The
#          DIR_LIST_FILE is defined in the 
#          variables declarations section
#          of this shell script
#
# PURPOSE: This shell script is used to replicate
#     directory structures to one or more remote 
#     machines using rsync in archive and 
#     compressed mode. This script requires
#     a file referenced by the variable
#     DIR_LIST_FILE that lists the top level
#     of each of the local directory structures
#     that we want to replicate to one or more
#     remote machines
#
# set -x # Uncomment to debug this script
#
# set -n # Uncomment to check script syntax
#        # without execution. Remember to put
#        # the comment back into the script or it
#        # will never execute.
#
#######################################
# DEFINE FILES AND VARIABLES HERE
#######################################

# Define the target machines to copy data to.
# To specify more than one host enclose the
# hostnames in double quotes and put at least
# one space between each hostname
#
# EXAMPLE: MACHINE_LIST="fred yogi booboo"

MACHINE_LIST="fred"

# The DIR_LIST_FILE variable define the shell script
# required file listing the directory structures
# to replicate with rsync.

DIR_LIST_FILE="rsync_directory_list.lst"

# Define the directory containing all of the 
# output files this shell script will produce

WORK_DIR=/usr/local/bin

# Define the rsync script log file

LOGFILE="generic_DIR_rsync_copy.log"

# Query the system for the hostname

THIS_HOST=$(hostname)

# Query the system for the UNIX flavor

OS=$(uname)

#######################################
# DEFINE FUNCTIONS HERE
#######################################

elapsed_time ()
{
SEC=$1
(( SEC < 60 )) && echo -e "[Elapsed time: $SEC seconds]\c"

(( SEC >= 60  &&  SEC < 3600 )) && echo -e "[Elapsed time: \
$(( SEC / 60 )) min $(( SEC % 60 )) sec]\c"

(( SEC > 3600 )) && echo -e "[Elapsed time: $(( SEC / 3600 )) \
hr $(( (SEC % 3600) / 60 )) min $(( (SEC % 3600) % 60 )) \
sec]\c" 
}

#######################################

verify_copy ()
{
# set -x

MYLOGFILE=${WORK_DIR}/verify_rsync_copy.log
>$MYLOGFILE
ERROR=0

# Enclose this loop so we can redirect output to the log file
# with one assignment at the bottom of the function
{
# Put a header for the verification log file

echo -e "\nRsync copy verification starting between $THIS_HOST \
and machine(s) $MACHINE_LIST\n\n" >$MYLOGFILE

for M in $MACHINE_LIST
do
   for DS in $(cat $DIR_LIST_FILE)
   do
       LS_FILES=$(find $DS -type f)
       for FL in $LS_FILES
       do
           LOC_FS=$(ls -l $FL | awk '{print $5}' 2>&1)
           REM_FS=$(ssh $M ls -l $FL | awk '{print $5}' 2>&1)
           echo "Checking File: $FL"
           echo -e "Local $THIS_HOST size:\t$LOC_FS"
           echo -e "Remote $M size:\t$REM_FS"
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

    echo -e "\n\nRSYNC ERROR: $THIS_HOST Rsync copy failed...file\
 size mismatch...\n\n" | tee -a $MYLOGFILE

    echo -e "\nERROR: Rsync copy Failed!"
    echo -e "\n\nCheck log file: $MYLOGFILE\n\n"
    echo -e "\n...Exiting...\n"

    # Send email notification with file size log

#    mailx -r from_someone@somewhere.??? -s "Rsync copy verification \
#failed $THIS_HOST -- File size mismatch" \
#    somebody@fsf.com < $MYLOGFILE

    sleep 2 # Give a couple of seconds to send the email
   
    exit 3
else
    echo -e "\nSUCCESS: Rsync copy completed successfully..."
    echo -e "\nAll file sizes match...\n"
fi
} | tee -a $MYLOGFILE

}

#######################################
# BEGINNING OF MAIN
#######################################

# We enclose the entire MAIN in curly craces
# so that all output of the script is logged
# in the $LOGFILE with a single output
# redirection

{

# Save the last logfile with a .yesterday filename extension

cp -f $LOGFILE ${LOGFILE}.yesterday 2>/dev/null

# Zero out the $LOGFILE to start a new file

>$LOGFILE

# Start all of the rsync copy sessions at once by looping
# through each of the mount points and issuing an rsync
# command in the background, saving the PID of the
# background process, and incrementing a counter.

echo -e "\nStarting a bunch of rsync sessions...$(date)\n"

# Initialize the rsync session counter, TOTAL
# to zero

TOTAL=0

# Loop through each machine in the $MACHINE_LIST

for M in $MACHINE_LIST
do
   # Loop through all of the directory structures
   # listed in the $DIR_LIST_FILE and start an rsync
   # session in the background for each directory

   for DS in $(cat $DIR_LIST_FILE)
   do
      # Ensure each directory structure has a trailing
      # forward slash to ensure an extra directory is
      # not created on the target

      if ! $(echo "$DS" | grep -q '/$')
      then
           # If the directory structure does not
           # have a trailing forward slash, add it

           DS="${DS}/"
      fi

      # Start a timed rsync session in the background

      time rsync -avz ${DS} ${M}:${DS} 2>&1 &

      # Keep a running total of the number of rsync
      # sessions started
      (( TOTAL = TOTAL + 1 ))
   done
done

# Sleep a 10 seconds before monitoring processes

sleep 10

# Query the process table for the number of rsync sessions 
# that continue executing and store that value in the
# REM_SESSIONS variable

# Create a list of directory structures for an egrep list

EGREP_LIST=    # Initialize to null

while read DS
do
   if [ -z "$EGREP_LIST" ]
   then
       EGREP_LIST="$DS"
   else
       EGREP_LIST="|$DS" 
   fi
done < $DIR_LIST_FILE

REM_SESSIONS=$(ps x | grep "rsync -avz" | egrep "$EGREP_LIST" \
               | grep -v grep | awk '{print $1}' | wc -l)

# Give some feedback to the end user.

if (( REM_SESSIONS > 0 ))
then
   echo -e "\n$REM_SESSIONS of $TOTAL rsync copy sessions require further updating..."
   echo -e "\nProcessing rsync copies from $THIS_HOST to both $MACHINE_LIST machines"
   echo -e "\nPlease be patient, this process may a very long time...\n"
   echo -e "Rsync is running [Start time: $(date)]\c"
else
   echo -e "\nAll files appear to be in sync...verifying file sizes...Please wait...\n"
fi

# While the rsync processes are executing this loop
# will place a . (dot) every 60 seconds as feedback
# to the end user that the background rsync copy
# processes are still executing. When the remaining
# rsync sessions are less than the total number of
# sessions this loop will give feedback as to the
# number of remaining rsync session, as well as
# the elapsed time of the procesing, every 5 minutes

# Set the shell variable SECONDS to 10 to make up for the
# time we slept while the rsync sessions started

SECONDS=10

# Initialize the minute counter to zero minutes

MIN_COUNTER=0

# Loop until all of the rsync sessions have completed locally

until  (( REM_SESSIONS == 0 ))
do
    sleep 60
    echo -e ".\c"
    REM_SESSIONS=$(ps x | grep "rsync -avz" | egrep "$EGREP_LIST" \
                   | grep -v grep | awk '{print $1}' | wc -l)
    if (( REM_SESSIONS < TOTAL ))
    then
        (( MIN_COUNTER = MIN_COUNTER + 1 ))
        if (( MIN_COUNTER >= $(( TOTAL / 2 )) ))
        then
           MIN_COUNTER=0
           echo -e "\n$REM_SESSIONS of $TOTAL rsync sessions \
remaining $(elapsed_time $SECONDS)\c"
           if (( REM_SESSIONS <= $(( TOTAL / 4 )) ))
           then
              echo -e "\nRemaining rsync sessions include:\n"
              ps aux | grep "rsync -avz" | egrep "$EGREP_LIST" \
                     | grep -v grep
              echo
           fi
        fi
    fi
done

echo -e "\n...Local rsync processing completed on ${THIS_HOST}...$(date)"

echo -e "\n...Checking remote target machine(s): ${MACHINE_LIST}..."

# Just because the local rsync processes have completed does
# not mean that the remote rsync processes have completed
# execution. This loop verifies that all of the remote
# rsync processes completed execution. The end user will
# receive feedback if any of the remote processes are running.

for M in $MACHINE_LIST
do
   for DS in $(cat $DIR_LIST_FILE)
   do
       RPID=$(ssh $M ps x | grep rsync | grep $DS | grep -v grep | awk '{print $1}')
       until [ -z "$RPID" ]
       do
           echo "rsync is processing ${MP} on ${M}...sleeping one minute..."
           sleep 60
           RPID=$(ssh $M ps x | grep rsync | grep $DS | grep -v grep \
                | awk '{print $1}')
       done
   done
done

echo -e "\n...Remote rsync processing completed $(date)\n"

# Verify the copy process

verify_copy

echo -e "\nRsync copy completed $(date)"
echo -e "\nElapsed time: $(elapsed_time $SECONDS)\n"

} 2>&1 | tee -a $LOGFILE 

###############################################
# END OF SCRIPT
###############################################
