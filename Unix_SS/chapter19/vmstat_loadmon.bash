#!/bin/bash
#
# SCRIPT: vmstat_loadmon.bash
# AUTHOR: Randy Michael
# DATE: 12/20/2007
# REV: 1.0.P
# PLATFORM: AIX, HP-UX, Linux, OpenBSD, and Solaris
#
# PURPOSE: This shell script takes two samples of the CPU
#          usage using the command. The first set of
#          data is an average since the last system reboot. The
#          second set of data is an average over the sampling
#          period, or $INTERVAL. The result of the data acquired
#          during the sampling period is shown to the user based
#          on the UNIX operating system that this shell script is
#          executing on. Different UNIX flavors have differing
#          outputs and the fields vary too.
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
INTERVAL=2  # Defines the total number of sampling intervals
STATCOUNT=0 # Initializes a loop counter to 0, zero
OS=$(uname) # Defines the UNIX flavor

###################################################
##### SET UP THE ENVIRONMENT FOR EACH OS HERE ######
###################################################

# These "F-numbers" point to the correct field in the
# command output for each UNIX flavor.

OS=$(uname)

case $OS in
AIX)
     F1=14
     F2=15
     F3=16
     F4=17
     echo -e "\nThe Operating System is $OS\n"
     ;;
HP-UX)
     F1=16
     F2=17
     F3=18
     F4=1 # This "F4=1" is bogus and not used for HP-UX
     echo -e "\nThe Operating System is $OS\n"
     ;;
Linux)
     F1=13
     F2=14
     F3=15
     F4=16
     echo -e "\nThe Operating System is $OS\n"
     ;;
OpenBSD)
     F1=17
     F2=18
     F3=19
     F4=1 # This "F4=1" is bogus and not used for Linux
     echo -e "\nThe Operating System is $OS\n"
     ;;
SunOS)
     F1=20
     F2=21
     F3=22
     F4=1 # This "F4=1" is bogus and not used for SunOS
     echo -e "\nThe Operating System is $OS\n"
     ;;
*)   echo -e "\nERROR: $OS is not a supported operating system\n"
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

# Use "vmstat" to montor the CPU utilization and
# remove all lines that contain alphabetic characters
# and blank spaces. Then use the previously defined
# field numbers, for example F1=20,to point directly
# to the 20th position, for this example. The syntax
# for this technique is ==> $.$F1. and points directly
# to the $20 positional parameter.

vmstat $SECS $INTERVAL | egrep -v '[a-zA-Z]|^$' \
         | awk '{print $'$F1', $'$F2', $'$F3', $'$F4'}' \
         | while read FIRST SECOND THIRD FOURTH
do
  if ((STATCOUNT == 1)) # Loop counter to get the second set
  then # of data produced by

      case $OS in # Show the results based on the UNIX flavor
      AIX|Linux)
            echo -e "\nUser part is ${FIRST}%"
            echo "System part is ${SECOND}%"
            echo "Idle part is ${THIRD}%"
            echo -e "I/O wait state is ${FOURTH}%\n"
            ;;
      HP-UX|OpenBSD|SunOS)
            echo -e "\nUser part is ${FIRST}%"
            echo "System part is ${SECOND}%"
            echo -e "Idle time is ${THIRD}%\n"
            ;;
      esac
  fi
((STATCOUNT = STATCOUNT + 1)) # Increment the loop counter
done
