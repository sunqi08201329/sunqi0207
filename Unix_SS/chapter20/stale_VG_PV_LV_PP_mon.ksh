#!/usr/bin/ksh
#
# SCRIPT: stale_VG_PV_LV_PP_mon.ksh
#
# AUTHOR: Randy Michael
# DATE: 01/29/2007
# REV: 1.2.P
# 
# PLATFORM: AIX only
#
# PURPOSE: This shell script is used to query the system for stale PPs.
#         The method queries the system for all of the currently vaied-on
#         volume groups and then builds a list of the PVs to query. If a PV
#         query detects any stale partitions notification is sent to the
#         screen. Each step in the process has user notification
#
# REVISION LIST:
#
#
# set -x # Uncomment to debug this shell script
# set -n # Uncomment to check command syntax without any execution
#
# EXIT CODES: 0 ==> Normal execution or no stale PP were found
#             1 ==> Trap EXIT
#             2 ==> Auto resyncing failed
#
####################################################
######### DEFINE VARIABLES HERE ####################
####################################################

case $(uname) in
AIX) :  # Correct OS
        # NOTE: a (:) colon is a no-op in Korn shell
     ;;
  *) echo "\nERROR: This shell script will only work on AIX"
     echo "...EXITING...\n"
     exit 99
     ;;
esac


ATTEMPT_RESYNC=FALSE    # Flag to enable auto resync, "TRUE" will resync

LOGFILE="/tmp/stale_PP_log" # Stale PP logfile
THIS_HOST=$(hostname)       # Hostname of this machine
STALE_PP_COUNT=0            # Initialize to zero
STALE_PV_COUNT=0            # Initialize to zero
HDISK_LIST=                 # Initialize to NULL
INACTIVE_PP_LIST=           # Initialize to NULL
STALE_PV_LIST=              # Initialize to NULL
STALE_LV_LIST=              # Initialize to NULL
STALE_VG_LIST=              # Initialize to NULL
RESYNC_LV_LIST=             # Initialize to NULL
PV_LIST=                    # Initialize to NULL

#######################################
#### INITIALIZE THE LOG FILE ####

>$LOGFILE          # Initialize the log file to empty
date >> $LOGFILE   # Date the log file was created
echo "\n$THIS_HOST \n" >> $LOGFILE # Host name for this report

#### DEFINE FUNCTIONS HERE ############

# Trap Exit function

function trap_exit
{
echo "\n\t...EXITING on a TRAPPED signal...\n"
}

#######################################

# Set a trap...

trap 'trap_exit; exit 1' 1 2 3 5 15

#######################################
######### BEGINNING OF MAIN ###########
#######################################

# Inform the user at each step

# Loop through each currently varied-on VG and query VG for stale PVs.
# For any VG that has at least one stale PV we then query the VG
# for the list of associated PV and build the $PV_LIST

echo "\nSearching each Volume Group for stale Physical Volumes...\c" \
        | tee -a $LOGFILE

# Search each VG for stale PVs, then build a list of VGs and PVs
# that have stale disk partitions

for VG in $(lsvg -o)
do
     NUM_STALE_PV=$(lsvg $VG | grep 'STALE PVs:' | awk '{print $3}')

     if ((NUM_STALE_PV > 0))
     then
          STALE_VG_LIST="$STALE_VG_LIST $VG"
          PV_LIST="$PV_LIST $(lsvg -p $VG | tail +3 | awk '{print $1}')"
          ((STALE_PV_COUNT = $STALE_PV_COUNT + 1))
     fi
done

# Test to see if any stale PVs were found, if not then
# exit with return code 0

if ((STALE_PV_COUNT == 0))
then
     echo "\nNo Stale Disk Mirrors Found...EXITING...\n" | tee -a $LOGFILE
     exit 0
else
     echo "\nStale Disk Mirrors Found!...Searching each hdisk for stale \
PPs...\c" | tee -a $LOGFILE
fi

# Now we have a list of PVs from every VG that reported stale PVs
# The next step is to query each PV to make sure each PV is in
# and "active" state and then query each PV for stale PPs.
# If a PV is found to be inactive then we will not query 
# the PV for stale partitions, but move on to the next PV in
# the $PV_LIST.

for HDISK in $(echo $PV_LIST)
do
     PV_STATE=$(lspv $HDISK | grep 'PV STATE:' | awk '{print $3}')
     if [[ $PV_STATE != 'active' ]]
     then
         INACTIVE_PV_LIST="$INACTIVE_PV_LIST $HDISK"
     fi
     if ! $(echo $INACTIVE_PV_LIST | grep $HDISK) >/dev/null 2>&1
     then
          NUM_STALE_PP=$(lspv $HDISK | grep 'STALE PARTITIONS:' \
                         | awk '{print $3}')
          if ((NUM_STALE_PP > 0)) 
          then
               STALE_PV_LIST="$STALE_PV_LIST $HDISK"
               ((STALE_PP_COUNT = $STALE_PP_COUNT + 1)) 
          fi
     fi
done

# Now we have the list of PVs that contain the stale PPs.
# Next we want to get a list of all of the LVs affected.

echo "\nSearching each disk with stale PPs for associated LVs\c" \
        | tee -a $LOGFILE

for PV in $(echo $STALE_PV_LIST)
do
     STALE_LV_LIST="$STALE_LV_LIST $(lspv -l $PV | tail +3 \
                    | awk '{print $1}')"
done

# Using the STALE_LV_LIST variable list we want to query 
# each LV to find which ones need to be resynced

echo "\nSearch each LV for stale partitions to build a resync LV list\c" \
        | tee -a $LOGFILE

for LV in $(echo $STALE_LV_LIST)
do
     LV_NUM_STALE_PP=$(lslv $LV | grep "STALE PPs:" | awk '{print $3}')
     (($LV_NUM_STALE_PP == 0)) & RESYNC_LV_LIST="$RESYNC_LV_LIST $LV"
done

# If any inactive PV were found we need to inform the user
# of each inactive PV

# Check for a NULL variable

if [[ -n $INACTIVE_PV_LIST && $INACTIVE_PV_LIST != '' ]]
then
     for PV in $(echo $INACTIVE_PV_LIST)
     do
          echo "\nWARNING: Inactive Physical Volume Found:" | tee -a $LOGFILE
          echo "\n$PV is currently inactive:\n" | tee -a $LOGFILE
          echo "\nThis script is not suitable to to correct this problem..." \
                  | tee -a $LOGFILE
          echo "       ...CALL IBM SUPPORT ABOUT ${PV}..." | tee -a $LOGFILE
     done
fi

echo "\nStale Partitions have been found on at least one disk!" \
        | tee -a $LOGFILE
echo "\nThe following Volume Group(s) have stale PVs:\n" \
        | tee -a $LOGFILE
echo $STALE_VG_LIST | tee -a $LOGFILE
echo "\nThe stale disk(s) involved include the following:\n" \
        | tee -a $LOGFILE
echo $STALE_PV_LIST | tee -a $LOGFILE
echo "\nThe following Logical Volumes need to be resynced:\n" \
        | tee -a $LOGFILE
echo $RESYNC_LV_LIST | tee -a $LOGFILE

if [[ $ATTEMPT_RESYNC = "TRUE" ]]
then
     echo "\nAttempting to resync the LVs on $RESYNC_PV_LIST ...\n" \
             | tee -a $LOGFILE
     syncvg -l $RESYNC_LV_LIST | tee -a $LOGFILE 2>&1
     if (( $? == 0))
     then
          echo "\nResyncing all of the LVs SUCCESSFUL...EXITING..." \
                  | tee -a $LOGFILE
     else
          echo "\nResyncing FAILED...EXITING...\n" | tee -a $LOGFILE
          exit 2
     fi
else
     echo "\nAuto resync is not enabled...set to TRUE to automatically \
resync\n" | tee -a $LOGFILE
     echo "\n\t...EXITING...\n" | tee -a $LOGFILE
fi 

echo "\nThe log file is: $LOGFILE\n"

