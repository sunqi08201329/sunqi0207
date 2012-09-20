#!/bin/ksh
#
# SCRIPT: sar_loadmon.ksh
# AUTHOR: Randy Michael
# DATE: 07/26/2007
# REV: 1.0.P
# PLATFORM: AIX, HP-UX, Linux, and Solaris
#
# PURPOSE: This shell script take multiple samples of the CPU
#          usage using the "sar" command. The average or
#          sample periods is shown to the user based on the 
#          UNIX operating system that this shell script is
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

SECONDS=30  # Defines the number of seconds for each sample
INTERVAL=10 # Defines the total number of sampling intervals
OS=$(uname) # Defines the UNIX flavor

###################################################
##### SETUP THE ENVIRONMENT FOR EACH OS HERE ######
###################################################

# These "F-numbers" point to the correct field in the
# command output for each UNIX flavor.

case $OS in
AIX|HP-UX|SunOS)   
       F1=2
       F2=3
       F3=4
       F4=5
       echo "\nThe Operating System is $OS\n"
       ;;
Linux)
       F1=3
       F2=4
       F3=5
       F4=6
       echo "\nThe Operating System is $OS\n"
       ;;
*) echo "\nERROR: $OS is not a supported operating system\n"
   echo "\n\t...EXITING...\n"
   exit 1
   ;;
esac

###################################################
######## BEGIN GATHERING STATISTICS HERE ##########
###################################################

echo "Gathering CPU Statistics using sar...\n"
echo "There are $INTERVAL sampling periods with"
echo "each interval lasting $SECONDS seconds"
echo "\n...Please wait while gathering statistics...\n"

# This "sar" command take $INTERVAL samples, each lasting
# $SECONDS seconds. The average of this output is captured.

sar $SECONDS $INTERVAL | grep Average \
          | awk '{print $'$F1', $'$F2', $'$F3', $'$F4'}' \
          | while read FIRST SECOND THIRD FORTH
do
      # Based on the UNIX Flavor, tell the user the 
      # result of the statistics gathered.

      case $OS in
      AIX|HP-UX|SunOS)
            echo "\nUser part is ${FIRST}%"
            echo "System part is ${SECOND}%"
            echo "I/O wait state is ${FORTH}%"
            echo "Idle time is ${FORTH}%\n"
            ;;
      Linux)
            echo "\nUser part is ${FIRST}%"
            echo "Nice part is ${SECOND}%"
            echo "System part is ${THIRD}%"
            echo "Idle time is ${FORTH}%\n"
            ;;
      esac
done

