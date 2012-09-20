#!/bin/ksh
#
# SCRIPT: stale_LV_mon.ksh
#
# AUTHOR: Randy Michael
# DATE: 01/22/2007
# REV: 1.1.P
# 
# PLATFORM: AIX only
#
# PURPOSE: This shell script is used to query the system
#       for stale PPs in every active LV within every active
#       VG.
#
# REVISION LIST:
#
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check command syntax without any execution

case $(uname) in
AIX) :  # Correct OS
        # NOTE: a (:) colon is a no-op in Korn shell
     ;;
  *) echo "\nERROR: This shell script will only work on AIX"
     echo "...EXITING...\n"
     exit 99
     ;;
esac 

THIS_HOST=`hostname`  # Hostname of this machine
STALE_PP_COUNT=0      # Initialize to zero

# Find all active VGs
echo "\nGathering a list of active Volume Groups"
ACTIVE_VG_LIST=$(lsvg -o)

# Find all active LVs in every active VG.
echo "\nCreating a list of all active Logical Volume"
ACTIVE_LV_LIST=$(lsvg -l $ACTIVE_VG_LIST | grep open | awk '{print $1}')

# Loop through each active LV and query for stale disk partitions
echo "\nLooping through each Logical Volume searching for stale PPs"
echo "...Please be patient this may take several minutes to complete..."

for LV in $(echo $ACTIVE_LV_LIST)
do
        # Extract the number of STALE PPs for each active LV
	NUM_STALE_PP=`lslv -L $LV | grep "STALE PP" | awk '{print $3}'`
        # Check for a value greater than zero
	if ((NUM_STALE_PP > 0))
	then
                # Increment the stale PP counter
                (( STALE_PP_COUNT = $STALE_PP_COUNT + 1))
                # Report on all LVs containing stale disk partitions 
		echo "\n${THIS_HOST}: $LV has $NUM_STALE_PP PPs"
	fi
done

# Give some feedback if no stale disk partition were found

if ((STALE_PP_COUNT == 0))
then
      echo "\nNo stale PPs were found in any active LV...EXITING...\n"
fi
