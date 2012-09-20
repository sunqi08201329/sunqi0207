#!/usr/bin/ksh
#
# SCRIPT: proc_wait.ksh
#
# AUTHOR: Randy Michael
#
# DATE: 02/14/2007
#
# REV: 1.1.A
#
# PURPOSE: This script is used to wait for a process to start.
#       The process, specified by ARG 1 as passed to this script, should not
#	currently be running when this is started.  This script waits for the
#	process to start and exits.
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to debug without any command execution

################ FUNCTIONS #############################
########################################################
function usage
{
	echo "\n\n"
	echo "USAGE: `basename $0` {Process_to_monitor}"
	echo "\nEXAMPLE: `basename $0` bffcreate\n"
	echo "Try again...EXITING...\n"
}
########################################################
function exit_trap
{
	echo "\n...EXITING on trapped signal...\n"
}
########################################################


################ START OF MAIN##########################

if [ $# -ne 1 ]
then
	usage
	exit 1
else
	ARG1="$1"
fi

# Set a trap...
trap 'exit_trap; exit 2' 1 2 3 15

# Check to execute or just exit...
ps -ef | grep $ARG1 | grep -v "grep $ARG1" | grep -v `basename $0` \
 >/dev/null

if [ $? -eq 0 ]
then
	echo "\n\n$ARG1 is an active process...EXITING...\n"
	exit 1
fi

##### O.K. The process is NOT running, start monitoring for startup...

SLEEP_TIME="1" # Seconds between monitoring
RC="1"		 # RC is the Return Code
echo "\n\n"	 # Give a couple of blank lines

echo "WAITING for $ARG1 to start...`date`\n"

until [ $RC -eq 0 ] # Loop until the return code is zero
do
	ps -ef | grep $ARG1 | egrep -v "grep $ARG1" | grep -v `basename $0` \
	 >/dev/null 2>&1
	RC="$?"
	if [ $RC -eq 0 ]
	then
		echo "$ARG1 is RUNNING...`date`\n"
		exit 0
	fi
	sleep $SLEEP_TIME
done 
