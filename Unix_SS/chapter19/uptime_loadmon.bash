#!/bin/bash
#
# SCRIPT: uptime_loadmon.bash
# AUTHOR: Randy Michael
# DATE: 12/16/2007
# REV: 1.0.P
# PLATFORM: AIX, HP-UX, Linux, OpenBSD, and Solaris
#
# PURPOSE: This shell script uses the "uptime" command to
#          extract the most current load average data, which
#          in this case is the average number of jobs in the
#          run queue. 
#
# set -x # Uncomment to debug this shell script
# set -n # Uncomment to check script syntax without any execution
#
###################################################
############# DEFINE VARIABLES HERE ###############
###################################################

MAXLOAD=2.00

# Extract the interger and decimal parts of $MAXLOAD
MAXLOAD_INT=$(echo $MAXLOAD | awk -F '.' '{print $1}')
MAXLOAD_DEC=$(echo $MAXLOAD | awk -F '.' '{print $2}')

# Check the UNIX flavor for the correct uptime values
# AIX specifies load as the last 5, 10, and 15 minutes.
# The other UNIX flavors specifies the load in the last
# 1, 5, and 15 minutes.

case $(uname) in
AIX)     L1=5
         L2=10
         L3=15
         ;;
  *)
         L1=1
         L2=5
         L3=15
         ;;
esac


###################################################
# DEFINE FUNCTIONS HERE
###################################################

function get_max
{
# This function return the number of auguments
# presented to the function
# 
(($# == 0)) && return -1
echo $#
}

###################################################
#  BEGINNING OF MAIN
###################################################

echo -e "\nGathering System Load Average using the \"uptime\" command\n"

# This next command statement extracts the latest 
# load statistics no matter what the UNIX flavor is.

NUM_ARGS=$(get_max $(uptime)) # Get the total number of fields in uptime output

((NUM_ARGS == -1)) && echo "ERROR: get_max Function Error...EXITING..."\
                   && exit 2


# Extract the data for the last 5, 10, and 15 minutes

ARGM2=$(((NUM_ARGS - 2)))  # Subtract 2 from the total
ARGM1=$(((NUM_ARGS - 1)))  # Subtract 1 from the total
ARGM=$NUM_ARGS             # Last value in string

uptime | sed s/,//g | awk '{print $'$ARGM2', $'$ARGM1', $'$ARGM'}' \
       | while read LAST5 LAST10 LAST15
do
    echo $LAST5 | awk -F '.' '{print $1, $2}' \
    | while read INT DEC
    do
       if (( INT > MAXLOAD_INT )) 
       then
           echo -e "\nWARNING: System load has \
reached ${LAST5}\n"
       fi

       echo "System load average for the last $L1 minutes is $LAST5"
       echo "System load average for the last $L2 minutes is $LAST10"
       echo "System load average for the last $L3 minutes is $LAST15"
       echo  -e "\nThe load threshold is set to ${MAXLOAD}\n"
    done
done

