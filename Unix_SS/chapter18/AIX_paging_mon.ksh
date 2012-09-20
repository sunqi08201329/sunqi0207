#!/usr/bin/ksh
#
# SCRIPT: AIX_paging_mon.ksh
#
# AUTHOR: Randy Michael
# DATE: 5/31/2007
# REV: 1.1.P
#
# PLATFORM: AIX Only
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

lsps -s | tail +2 > $PAGING_STAT

# Start a while loop and feed the loop from the bottom using 
# the $PAGING_STAT file as redirected input

while read TOTAL PERCENT
do
     # Clean up the data by removing the suffixes
     PAGING_MB=$(echo $TOTAL | cut -d 'MB' -f1)
     PAGING_PC=$(echo $PERCENT | cut -d% -f1)

     # Calculate the missing data: %Free, MB used and MB free
     (( PAGING_PC_FREE = 100 - PAGING_PC ))
     (( MB_USED = PAGING_MB * PAGING_PC / 100 ))
     (( MB_FREE = PAGING_MB - MB_USED ))

     # Produce the rest of the paging space report:
     echo "\nTotal MB of Paging Space:\t$TOTAL"
     echo "Total MB of Paging Space Used:\t${MB_USED}MB"
     echo "Total MB of Paging Space Free:\t${MB_FREE}MB"
     echo "\nPercent of Paging Space Used:\t${PERCENT}"
     echo "\nPercent of Paging Space Free:\t${PAGING_PC_FREE}%"

     # Check for paging space exceeded the predefined limit 
     if ((PC_LIMIT <= PAGING_PC))
     then
          # Paging space is over the limit, send notification 

          tput smso  # Turn on reverse video!

          echo "\n\nWARNING: Paging Space has Exceeded the ${PC_LIMIT}% \
Upper Limit!\n"

          tput rmso  # Turn off reverse video
     fi

done < $PAGING_STAT

rm -f $PAGING_STAT

# Add an extra new line to the output

echo "\n"
