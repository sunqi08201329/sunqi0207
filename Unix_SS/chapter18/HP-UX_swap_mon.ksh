#!/usr/bin/ksh
#
# SCRIPT: HP-UX_swap_mon.ksh
#
# AUTHOR: Randy Michael
# DATE: 5/31/2007
# REV: 1.1.P
# 
# PLATFORM: HP-UX Only
#
# PURPOSE: This shell script is used to produce a report of
#        the system's paging space statistics including:
#
#     Total paging space in MB, MB of Free paging space,
#     MB of Used paging space, % of paging space Used, and
#     % of paging space Free
#
# REV LIST:
#
#
# set -x # Uncomment to debug this shell script
# set -n # Uncomment to check command syntax without any execution
#
################ DEFINE VARIABLES HERE ####################

PC_LIMIT=65            # Percentage Upper limit of paging space
                       # before notification

THISHOST=$(hostname)   # Host name of this machine

###########################################################
################ INITIALIZE THE REPORT ####################

echo "\nSwap Space Report for $THISHOST\n"
date

###########################################################
############# CAPTURE AND PROCESS THE DATA ################

# Start a while read loop by using the piped in input from
# the swapinfo -tm command output. 


swapinfo -tm | grep dev | while read junk SW_TOTAL SW_USED \
                               SW_FREE PERCENT_USED junk2
do
    # Calculate the percentage of free swap space

    ((PERCENT_FREE = 100 - $(echo $PERCENT_USED | cut -d% -f1) ))

    echo "\nTotal Amount of Swap Space:\t${SW_TOTAL}MB"
    echo "Total MB of Swap Space Used:\t${SW_USED}MB"
    echo "Total MB of Swap Space Free:\t${SW_FREE}MB"
    echo "\nPercent of Swap Space Used:\t${PERCENT_USED}"
    echo "\nPercent of Swap Space Free:\t${PERCENT_FREE}%"

    # Check for paging space exceeded the predefined limit

    if (( PC_LIMIT <= $(echo $PERCENT_USED | cut -d% -f1) ))
    then
        # Swap space is over the predefined limit, send notification

       tput smso # Turn on reverse video!
         echo "\n\nWARNING: Swap Space has Exceeded the\
 ${PC_LIMIT}% Upper Limit!\n"
         tput rmso # Turn reverse video off!
    fi

done 

echo "\n"
