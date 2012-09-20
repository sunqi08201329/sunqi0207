#!/bin/bash
#
# SCRIPT: iostat_loadmon.bash
# AUTHOR: Randy Michael
# DATE: 12/20/2007
# REV: 1.0.P
# PLATFORM: AIX, HP-UX, Linux, OpenBSD, and Solaris
#
# PURPOSE: This shell script take two samples of the CPU
# usage using the command. The first set of
# data is an average since the last system reboot. The
# second set of data is an average over the sampling
# period, or $INTERVAL. The result of the data acquired
# during the sampling period is shown to the user based
# on the UNIX operating system that this shell script is
# executing on. Different UNIX flavors have differing
# outputs and the fields vary too.
#
# REV LIST:
#
#
# set -n # Uncomment to check the script syntax without any execution
# set -x # Uncomment to debug this shell script
#
###################################################
############# DEFINE VARIABLES HERE ###############
###################################################

SECS=300 # Defines the number of seconds for each sample
INTERVAL=2 # Defines the total number of sampling intervals
STATCOUNT=0 # Initializes a loop counter to 0, zero
OS=$(uname) # Defines the UNIX flavor

###################################################
##### SET UP THE ENVIRONMENT FOR EACH OS HERE ######
###################################################

# These "F-numbers" point to the correct field in the
# command output for each UNIX flavor.

case $OS in
AIX|HP-UX) SWITCH='-t'
           F1=3
           F2=4
           F3=5
           F4=6
           echo -e "\nThe Operating System is $OS\n"
           ;;
Linux) SWITCH='-c'
           F1=1
           F2=3
           F3=4
           F4=6
           echo -e "\nThe Operating System is $OS\n"
           ;;
SunOS) SWITCH='-c'
           F1=1
           F2=2
           F3=3
           F4=4
          echo -e "\nThe Operating System is $OS\n"
          ;;
OpenBSD) SWITCH='-C'
          F1=1
          F2=2
          F3=3
          F4=5
          echo -e "\nThe Operating System is $OS\n"
          ;;
*)        echo -e "\nERROR: $OS is not a supported operating system\n"
          echo -e "\n\t...EXITING...\n"
          exit 1
          ;;
esac

###################################################
######## BEGIN GATHERING STATISTICS HERE ##########
###################################################

echo -e "Gathering CPU Statistics using vmstat...\n"
echo "There are $INTERVAL sampling periods with"
echo "each interval lasting $SECS seconds"
echo -e "\n...Please wait while gathering statistics...\n"

# Use "iostat" to monitor the CPU utilization and
# remove all lines that contain alphabetic characters
# and blank spaces. Then use the previously defined
# field numbers, for example, F1=4,to point directly
# to the 4th position, for this example. The syntax
# for this techniques is ==> $.$F1..

iostat $SWITCH $SECS $INTERVAL | egrep -v '[a-zA-Z]|^$' \
        | awk '{print $'$F1', $'$F2', $'$F3', $'$F4'}' \
        | while read FIRST SECOND THIRD FOURTH
do
if ((STATCOUNT == 1)) # Loop counter to get the second set
then # of data produced by "iostat"

    case $OS in # Show the results based on the UNIX flavor
    AIX)
         echo -e "\nUser part is ${FIRST}%"
         echo "System part is ${SECOND}%"
         echo "Idle part is ${THIRD}%"
         echo -e "I/O wait state is ${FOURTH}%\n"
         ;;
    HP-UX|OpenBSD)
         echo -e "\nUser part is ${FIRST}%"
         echo "Nice part is ${SECOND}%"
         echo "System part is ${THIRD}%"
         echo -e "Idle time is ${FOURTH}%\n"
         ;;
    SunOS|Linux)
         echo -e "\nUser part is ${FIRST}%"
         echo "System part is ${SECOND}%"
         echo "I/O Wait is ${THIRD}%"
         echo -e "Idle time is ${FOURTH}%\n"
         ;;
    esac
fi
((STATCOUNT = STATCOUNT + 1)) # Increment the loop counter
done
