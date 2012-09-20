#!/bin/bash
#
# SCRIPT: generic_FS_rsync_copy.bash
# AUTHOR: Randy Michael
# DATE: 1/14/2008
# REV: 1.2.1
#
# PURPOSE: This script is used to replicate
#
#
# EXIT CODES:
#            0 ==> Normal execution.
#            2 ==> Remote host is not pingable.
#            3 ==> Copy verification failed. One or
#                  more local files are not the same
#                  size as the remote files.
#            4 ==> No machines are defined to copy
#                  data to.
#            5 ==> Exited on a trapped signal.
#
# set -x # Uncomment to debug this script
#
# set -n # Uncomment to check the script.s syntax
#        # without any execution. Do not forget to
#        # recomment this line!
#
########################################
# REVISION LIST:
########################################
#
# IF YOU MODIFY THIS SCRIPT, DOCUMENT THE CHANGE(S)!!!
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

# Define the target machines to copy data to.
# To specify more than one host enclose the
# hostnames in double quotes and put at least
# one space between each hostname
#
# EXAMPLE: MACHINE_LIST="fred yogi booboo"

MACHINE_LIST="fred"

# The FS_PATTERN variable defines the regular expression
# matching the filesystems we want to replicate with rsync.

FS_PATTERN="/data0[1-5]"

# Add /usr/local/bin to the PATH

export PATH=$PATH:/usr/local/bin

# Define the directory containing all of the
# output files this shell script will produce

WORK_DIR=/usr/local/bin

# Define the rsync script log file

LOGFILE=${WORK_DIR}/generic_FS_rsync_copy.log

# Capture the shell script file name

THIS_SCRIPT=$(basename $0)

# Initialize the background process ID list
# variable to NULL

BG_PID_LIST=

# Define the file containing a list of files to verify
# the sizes match locally and remotely

LS_FILES=ls_output.dat
>$LS_FILES

# Initialize the TOTAL variable to 0

TOTAL=0

# Query the system for the hostname

THIS_HOST=$(hostname)

# Query the system for the UNIX flavor

THIS_OS=$(uname)

##############################################
# DEFINE FUNCTIONS HERE
##############################################

verify_copy ()
{
# set -x

MYLOGFILE=${WORK_DIR}/verify_rsync_copy_day.log
>$MYLOGFILE
ERROR=0

# Enclose this loop so we can redirect output to the log file
# with one assignment at the bottom of the function

{

# Put a header for the verification log file

echo -e "\nRsync copy verification between $THIS_HOST and machine(s) \
$MACHINE_LIST\n\n" >> $MYLOGFILE

# Loop through each machine in the $MACHINE_LIST

for M in $MACHINE_LIST
do
   # Loop through each filesystem that matches the regular
   # regular expression point to by "$FS_PATTERN". It is
   # important that this variable is enclosed within double
   # quotes. Also note the column for the mount point is 6;
   # in AIX this should be changed to 7.

   for MP in $(df | grep "$FS_PATTERN" | awk '{print $6}')
   do
      # For each filesystem mount point, $MP, execute a
      # find command to find all files in the filesystem.
      # and store them in the $LS_FILES file. We will use this
      # file list to verify the file sizes on the remote
      # machines match the file sizes on the local machine.

      find $MP -type f > $LS_FILES

      # Loop through the file list

      for FL in $(cat $LS_FILES)
      do
          # Find the local file size
          LOC_FS=$(ls -l $FL | awk '{print $5}' 2>&1)
          # Find the remote file size using a remote shell command
          REM_FS=$(rsh $M ls -l $FL | awk '{print $5}' 2>&1)
          echo "Checking File: $FL"
          echo -e "Local $THIS_HOST size:\t$LOC_FS"
          echo -e "Remote $M size:\t$REM_FS"

          # Ensure the file sizes match
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
    echo -e "\n\nRSYNC ERROR: $THIS_HOST Rsync copy failed...file size mismatch...\n\n" | tee -a $MYLOGFILE
    echo -e "\nERROR: Rsync copy Failed!"
    echo -e "\n\nCheck log file: $MYLOGFILE\n\n"
    echo -e "\n...Exiting...\n"
    return 3
else
    echo -e "\nSUCCESS: Rsync copy completed successfully..."
    echo -e "\nAll file sizes match...\n"
fi
} | 2>&1 tee -a $MYLOGFILE

}

##############################################

elapsed_time ()
{
SEC=$1
(( SEC < 60 )) && echo -e "[Elapsed time: $SEC seconds]\c"

(( SEC >= 60 && SEC < 3600 )) && echo -e "[Elapsed time: $(( SEC / 60 )) min $(( SEC % 60 )) sec]\c"

(( SEC > 3600 )) && echo -e "[Elapsed time: $(( SEC / 3600 )) hr $(( (SEC % 3600) / 60 )) min $(( (SEC % 3600) % 60 )) sec]\c"
}

##############################################
# BEGINNING OF MAIN
##############################################

# Enclose the entire main part of the script in
# curly braces so we can redirect all output of
# the shell script with a single redirection
# at the bottom of the script to the $LOGFILE

{

# Save a copy of the last log file

cp -f $LOGFILE ${LOGFILE}.yesterday

echo -e "\n[[ $THIS_SCRIPT started execution $(date) ]]\n"

# Ensure that target machines are defined

if [ -z "$MACHINE_LIST" ]
then
    echo -e "\nERROR: No machines are defined to copy data to..."
    echo "...Unable to continue...Exiting..."
    exit 4
fi

# Ensure the remote machines are reachable through
# the network by sending 1 ping.

echo -e "Verifying the target machines are pingable...\n"

for M in $MACHINE_LIST
do
    echo "Pinging $M..."
    ping -c1 $M >/dev/null 2>&1
    if (( $? != 0 ))
    then
        echo -e "\nERROR: $M host is not pingable...cannot continue..."
        echo -e "...EXITING...\n"
        exit 2
    else
        echo "Pinging $M succeeded..."
    fi
done

# Start all of the rsync copy sessions at once by looping
# through each of the mount points and issuing an rsync
# command in the background, and incrementing a counter.

echo -e "\nStarting a bunch of rsync sessions...\n"

for M in $MACHINE_LIST
do
   # Loop through each filesystem that matches the regular
   # expression point to by "$FS_PATTERN". It is
   # important that this variable is enclosed within double
   # quotes. Also note the column for the mount point is 6;
   # in AIX this should be changed to 7.

   for MP in $(df | grep "$FS_PATTERN" | awk '{print $6}')
   do
      # Start the rsync session in the background

      time rsync -avz ${MP}/ ${M}:${MP} 2>&1 &

      # Keep a running total of the number of rsync
      # sessions started

      (( TOTAL = TOTAL + 1 ))
   done
done

# Sleep a few seconds before monitoring processes

sleep 10

# Find the number of rsync sessions that are still running

REM_SESSIONS=$(ps x | grep "rsync -avz" | grep "$FS_PATTERN" \
               | grep -v grep | awk '{print $1}' | wc -l)

# Give some feedback to the end user.

if (( REM_SESSIONS > 0 ))
then
   echo -e "\n$REM_SESSIONS of $TOTAL rsync copy sessions require \
further updating..."
   echo -e "\nProcessing rsync copies from $THIS_HOST to both \
$MACHINE_LIST machines"
   echo -e "\nPlease be patient, this process may take a very long \
time...\n"
   echo -e "Rsync is running [Start time: $(date)]\c"
else
   echo -e "\nAll files appear to be in sync...verifying file sizes...\
Please wait...\n"
fi

# While the rsync processes are executing this loop
# will place a . (dot) every 60 seconds as feedback
# to the end user that the background rsync copy
# processes are still executing. When the remaining
# rsync sessions are less than the total number of
# sessions (normally 36) this loop will give feedback
# as to the number of remaining rsync session, as well
# as the elapsed time of the processing, every 5 minutes..

SECONDS=10
MIN_COUNTER=0

# Loop until all of the local rsync sessions have completed

until (( REM_SESSIONS == 0 ))
do
   # sleep 60 seconds between loop iterations

   sleep 60

   # Display a dot on the screen every 60 seconds

   echo -e ".\c"

   # Find the number of remaining rsync sessions

   REM_SESSIONS=$(ps x | grep "rsync -avz" | grep "$FS_PATTERN" \
                  | grep -v grep | '{print $1}' | wc -l)

# Have any of the sessions completed? If so start giving
# the user updates every 5 minutes, specifying the number
# remaining rsync sessions and the elapsed time.

if (( REM_SESSIONS < TOTAL ))
then
    # Count every 5 minutes
    (( MIN_COUNTER = MIN_COUNTER + 1 ))

    # 5 minutes timed out yet?
    if (( MIN_COUNTER >= 5 ))
    then
        # Reset the minute counter
        MIN_COUNTER=0

        # Update the user with a new progress report

        echo -e "\n$REM_SESSIONS of $TOTAL rsync sessions \
remaining $(elapsed_time $SECONDS)\c"

        # Have three-fourths of the rsync sessions completed?

        if (( REM_SESSIONS <= $(( TOTAL / 4 )) ))
        then
           # Display the list of remaining rsync sessions
           # that continue to run.

           echo -e "\nRemaining rsync sessions include:\n"
           ps x | grep "rsync -avz" | grep "$FS_PATTERN" \
                | grep -v grep
           echo
        fi
     fi
   fi
done

echo -e "\n...Local rsync processing completed on $THIS_HOST...$(date)"
echo -e "\n...Checking remote target machines: $MACHINE_LIST..."

# Just because the local rsync processes have completed does
# not mean that the remote rsync processes have completed
# execution. This loop verifies that all of the remote
# rsync processes completed execution. The end user will
# receive feedback if any of the remote processes are running.

for M in $MACHINE_LIST
do
   # Loop through each matching filesystem

   for MP in $(df | grep "$FS_PATTERN" | awk '{print $7}')
   do
      # Find the remote process Ids.
      RPID=$(rsh $M ps x | grep rsync | grep $MP | grep -v grep \
             | awk '{print $1}')

      # Loop while remote rsync sessions continue to run.
      # NOTE: I have never found remote rsync sessions running
      # after the local sessions have completed. This is just
      # an extra sanity check

      until [ -z "$RPID" ]
      do
         echo "rsync is processing ${MP} on ${M}...sleeping one minute..."
         sleep 60
         RPID=$(rsh $M ps x | grep rsync | grep $MP | grep -v grep \
                | awk '{print $1}')
      done
   done
done

echo -e "\n...Remote rsync processing completed $(date)\n"

# Verify the copy process

verify_copy

# Check the verify_copy return code

if (( $? != 0 ))
then
    exit 3
fi

echo -e "\nRsync copy completed $(date)"

echo -e "\n[[ $THIS_SCRIPT completed execution $(date) ]]\n"
echo -e "\n[[ Elapsed Time: $(elapsed_time $SECONDS) ]]\n"

} | 2>&1 tee -a $LOGFILE

###############################################
# END OF SCRIPT
###############################################
