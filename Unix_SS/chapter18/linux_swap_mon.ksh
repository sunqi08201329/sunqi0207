#!/usr/bin/ksh
#
# SCRIPT: linux_swap_mon.ksh
#
# AUTHOR: Randy Michael
# DATE: 5/31/2007
# REV: 1.1.P
# 
# PLATFORM: Linux Only
#
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

THISHOST=$(hostname)   # Host name of this machine
PC_LIMIT=65            # Upper limit of Swap space percentage
                       # before notification 

###########################################################
################ INITIALIZE THE REPORT ####################

echo "\nSwap Space Report for $THISHOST\n"
date

###########################################################
############# CAPTURE AND PROCESS THE DATA ################

free -m | grep -i swap | while read junk SW_TOTAL SW_USED SW_FREE
do

# Use the bc utility in a here document to calculate
# the percentage of free and used swap space.

PERCENT_USED=$(bc <<EOF
scale=4
($SW_USED / $SW_TOTAL) * 100 
EOF
) 

PERCENT_FREE=$(bc <<EOF
scale=4
($SW_FREE / $SW_TOTAL) * 100
EOF
)

     # Produce the rest of the paging space report:
     echo "\nTotal Amount of Swap Space:\t${SW_TOTAL}MB"
     echo "Total KB of Swap Space Used:\t${SW_USED}MB"
     echo "Total KB of Swap Space Free:\t${SW_FREE}MB"
     echo "\nPercent of Swap Space Used:\t${PERCENT_USED}%"
     echo "\nPercent of Swap Space Free:\t${PERCENT_FREE}%"

     # Grap the integer portion of the percent used to 
     # test for the over limit threshold

     INT_PERCENT_USED=$(echo $PERCENT_USED | cut -d. -f1)

     if (( PC_LIMIT <= INT_PERCENT_USED ))
     then
          tput smso
          echo "\n\nWARNING: Paging Space has Exceeded the ${PC_LIMIT}% Upper Limit!\n"
          tput rmso
     fi

done 

echo "\n"
