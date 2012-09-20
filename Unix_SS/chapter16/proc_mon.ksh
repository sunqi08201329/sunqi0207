#!/usr/bin/ksh
#
# SCRIPT: proc_mon.ksh
# AUTHOR: Randy Michael
# DATE: 02/14/2007
# REV: 1.1.P
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This script is used to monitor a process to end
#   specified by ARG1 if a single command-line argument is
#   used. There is also a "verbose" mode where the monitored
#   process is displayed and ARG2 is monitored.
#
# USAGE: proc_mon.ksh [-v] process-to-monitor
#
# EXIT STATUS:
#    0 ==> Monitored process has terminated
#    1 ==> Script usage error
#    2 ==> Target process to monitor is not active
#    3 ==> This script exits on a trapped signal
#
# REV. LIST:
#
#    02/22/2007 - Added code for a "verbose" mode to output the
#                 results of the .ps aux. command. The verbose
#                 mode is set using a "-v" switch.
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to debug without any command execution

SCRIPT_NAME=`basename $0`

########################################################
############ DEFINE FUNCTIONS HERE #####################
########################################################

function usage
{
    echo "\n\n"
    echo "USAGE: $SCRIPT_NAME [-v] {Process_to_monitor}"
    echo "\nEXAMPLE: $SCRIPT_NAME my_backup\n"
    echo "OR"
    echo "\nEXAMPLE: $SCRIPT_NAME -v my_backup\n"
    echo "Try again...EXITING...\n"
}
########################################################

function exit_trap
{
    echo "\n...EXITING on trapped signal...\n"
}
########################################################
################ START OF MAIN##########################
########################################################

################
# Set a trap...#
################

trap 'exit_trap; exit 3' 1 2 3 15

# First Check for the Correct Number of Arguments
# One or Two is acceptable

if (( $# != 1 && $# != 2 ))
then
    usage
    exit 1
fi

# Parse through the command-line arguments and see if verbose
# mode has been specified. NOTICE that we assign the target
# process to the PROCESS variable!!!
# Embedded case statement...

case $# in
      1) case $1 in
         '-v') usage
               exit 1
               ;;
            *) PROCESS=$1
               ;;
         esac
         ;;
      2) case $1 in
         '-v') continue
               ;;
         esac

         case $2 in
         '-v') usage
               exit 1
               ;;
            *) PROCESS=$2
               ;;
         esac
         ;;
      *) usage
         exit 1
         ;;
esac

# Check if the process is running or exit!

ps aux | grep "$PROCESS" | grep -v "grep $PROCESS" \
| grep -v $SCRIPT_NAME >/dev/null

if (( $? != 0 ))
then
    echo "\n\n$PROCESS is NOT an active process...EXITING...\n"
    exit 2
fi

# Show verbose mode if specified...

if (( $# == 2 )) && [[ $1 = "-v" ]]
then
    # Verbose mode has been specified!
    echo "\n"

    # Extract the columns heading from the ps aux output
    ps aux | head -n 1

    ps aux | grep "$PROCESS" | grep -v "grep $PROCESS" \
           | grep -v $SCRIPT_NAME
fi

##### O.K. The process is running, start monitoring...

SLEEP_TIME="1" # Seconds between monitoring

RC="0" # RC is the Return Code
echo "\n\n" # Give a couple of blank lines

echo "$PROCESS is currently RUNNING...`date`\n"

####################################
# Loop UNTIL the $PROCESS stops...

while (( RC == 0 )) # Loop until the return code is not zero
do
     ps aux | grep $PROCESS | grep -v "grep $PROCESS" \
            | grep -v $SCRIPT_NAME >/dev/null 2>&1
     if (( $? != 0 )) # Check the Return Code!!!!!
     then
         echo "\n...$PROCESS has COMPLETED...`date`\n"
         exit 0
     fi
     sleep $SLEEP_TIME # Needed to reduce CPU Load!!!
done

# End of Script
