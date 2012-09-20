#!/bin/ksh
#
# SCRIPT: vmstat_loadmon.ksh
# AUTHOR: Randy Michael
# DATE: 07/26/2002
# REV: 1.0.P
# PLATFORM: AIX, HP-UX, Linux, and Solaris
#
# PURPOSE: This shell script take two samples of the CPU
#          usage using the "vmstat" command. The first set of
#          data is an average since the last system reboot. The
#          second set of data is an average over the sampling
#          period, or $INTERVAL. The result of the data aquired
#          during the sampling perion is shown to the user based
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

SECONDS=300  # Defines the number of seconds for each sample
INTERVAL=2   # Defines the total number of sampling intervals
STATCOUNT=0  # Initialize a loop counter to 0, zero
OS=$(uname)  # Defines the UNIX flavor

###################################################
##### SETUP THE ENVIRONMENT FOR EACH OS HERE ######
###################################################

# These "F-numbers" point to the correct field in the
# command output for each UNIX flavor.

case $OS in
AIX)   # AIX has four relative columns in the output 
       F1=14
       F2=15
       F3=16
       F4=17

       echo "\nThe Operating System is $OS\n"
       ;;
HP-UX) # HP-UX only has three relative columns in the output
       F1=16
       F2=17
       F3=18
       F4=1   # This "F4=1" is bogus and not used for HP-UX

       echo "\nThe Operating System is $OS\n"
       ;;
Linux) # Linux only has three relative columns in the output
       F1=14
       F2=15
       F3=16
       F4=1   # This "F4=1" is bogus and not used for Linux

       echo "\nThe Operating System is $OS\n"
       ;;
SunOS) # SunOS only has three relative columns in the output
       F1=20
       F2=21
       F3=22
       F4=1   # This "F4=1" is bogus and not used for SunOS

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

echo "Gathering CPU Statistics using vmstat...\n"
echo "There are $INTERVAL sampling periods with"
echo "each interval lasting $SECONDS seconds"
echo "\n...Please wait while gathering statistics...\n"

# Use "vmstat" to monitor the CPU utilization and 
# remove all lines that contain alphabetic characters
# and blank spaces. Then use the previously defined 
# field numbers, for example F1=20,to point directly
# to the 20th position, for this example. The syntax
# for this techniques is ==>  $'$F1', and points directly
# to the $20 positional parameter.

vmstat $SECONDS $INTERVAL | egrep -v '[a-zA-Z]|^$' \
          | awk '{print $'$F1', $'$F2', $'$F3', $'$F4'}' \
          | while read FIRST SECOND THIRD FORTH
do
  if ((STATCOUNT == 1)) # Loop counter to get the second set
  then                  # of data produces by "vmstat"

      case $OS in  # Show the results based on the UNIX flavor
      AIX)
            echo "\nUser part is ${FIRST}%"
            echo "System part is ${SECOND}%"
            echo "Idle part is ${THIRD}%"
            echo "I/O wait state is ${FORTH}%\n"
            ;;
      HP-UX|Linux|SunOS)
            echo "\nUser part is ${FIRST}%"
            echo "System part is ${SECOND}%"
            echo "Idle time is ${THIRD}%\n"
            ;;
      esac

  fi
  ((STATCOUNT = STATCOUNT + 1)) # Increment the loop counter
done
