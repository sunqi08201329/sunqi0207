#!/usr/bin/ksh
#
# SCRIPT: stale_PP_mon.ksh
#
# AUTHOR: Randy Michael
# DATE: 01/29/07
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

case $(uname) in
AIX) :  # Correct OS
        # NOTE: a (:) colon is a no-op in Korn shell
     ;;
  *) echo "\nERROR: This shell script will only work on AIX"
     echo "...EXITING...\n"
     exit 99
     ;;
esac
 
THIS_HOST=$(hostname)   # Hostname of this machine
FIRST_TIME=0            # Initialize to zero
HDISK_LIST=             # Initialize to NULL
STALE_PP_COUNT=0        # Initialize to zero

# Infor the user at each step
echo "\nGathering a list of hdisks to query\n"
 
# Loop through each currently varied-on VG

for VG in $(lsvg -o)
do
      # Build a list of hdisks that belong to currently varied on VGs
      echo "Querying $VG for a list of disks"
      HDISK_LIST="$HDISK_LIST $(lsvg -p $VG |grep disk | awk '{print $1}')"
done

echo "\nStarting the hdisk query on individual disks\n"

# Loop through each of the hdisks found in the previous loop

for HDISK in $(echo $HDISK_LIST)
do
     # Query a new hdisk on each loop iteration

     echo "Querying $HDISK for stale partitions"
     NUM_STALE_PP=$(lspv -L $HDISK | grep "STALE PARTITIONS:" | awk '{print $3}')
     # Check to see if the stale partition count is greater than zero
     if ((NUM_STALE_PP > 0))
     then
           # This hdisk has at least one stale partition - Report it!
           echo "\n${THIS_HOST}: Disk $HDISK has $NUM_STALE_PP Stale Partitions"
           if ((STALE_PP_COUNT == 0))
           then
                 # Build a list of hdisks that have stale disk partitions
                 STALE_HDISK_LIST=$(echo $STALE_HDISK_LIST; echo $HDISK)

           fi
     fi
done

# If no stale partitions were found send a "all is good message"

((NUM_STALE_PP > 0)) || echo "\n${THIS_HOST}: No Stale PPs have been found...EXITING...\n"

