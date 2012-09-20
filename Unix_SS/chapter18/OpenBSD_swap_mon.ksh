#!/bin/bash
#
# SCRIPT: OpenBSD_swap_mon.ksh
#
# AUTHOR: Randy Michael
# DATE: 10/31/2007
# REV: 1.2.BOO
#
# PLATFORM: OpenBSD Only
#
# PURPOSE: This shell script is used to produce a report of 
#          the system's paging space statistics including:
#
#       Total paging space in MB, MB of Free paging space,
#       MB of Used paging space, % of paging space Used, and
#       % of paging space Free
#
# REV LIST:
#
#
# set -x # Uncomment to debug this shell script
# set -n # Uncomment to check command syntax without any execution
#
###########################################################
################ DEFINE VARIABLES HERE ####################

PC_LIMIT=65            # Percentage Upper limit of paging space
                       # before notification

THISHOST=$(hostname)   # Host name of this machine
PAGING_STAT=/tmp/paging_stat.out # Paging Stat hold file

###########################################################
################ INITIALIZE THE REPORT ####################

echo "\nPaging Space Report for $THISHOST\n"
date

###########################################################
############# CAPTURE AND PROCESS THE DATA ################

# Load the data in a file without the column headings

swapctl -lk | tail +2 | awk '{print $2, $3, $4, $5}' \
            | while read KB_TOT KB_USED KB_AVAIL PC_USED
do
     (( TOTAL = KB_TOT / 1000 ))
     (( MB_USED = KB_USED / 1000 ))
     (( MB_FREE = KB_AVAIL / 1000 ))
     PC_FREE_NO_PC=$(echo $PC_USED | awk -F '%' '{print $1}')
     (( PC_FREE = 100 - PC_FREE_NO_PC ))
    
     # Produce the rest of the paging space report:
     echo "\nTotal MB of Paging Space:\t${TOTAL}MB"
     echo "Total MB of Paging Space Used:\t${MB_USED}MB"
     echo "Total MB of Paging Space Free:\t${MB_FREE}MB"
     echo "\nPercent of Paging Space Used:\t${PC_USED}"
     echo "\nPercent of Paging Space Free:\t${PC_FREE}%\n"
done


# Check for paging space exceeded the predefined limit

if (( PC_LIMIT <= PC_FREE_NO_PC ))
then
     echo "\n\nWARNING: Paging Space has Exceeded the ${PC_LIMIT}% Upper Limit!\n"
fi
