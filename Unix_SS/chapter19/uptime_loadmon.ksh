#!/bin/ksh
#
# SCRIPT: uptime_loadmon.ksh
# AUTHOR: Randy Michael
# DATE: 07/26/2007
# REV: 1.0.P
# PLATFORM: AIX, HP-UX, Linux, and Solaris
#
# PURPOSE: This shell script uses the "uptime" command to
#          extract the most current load average data. There
#          is a special need in this script to determine 
#          how long the system has been running since the
#          last reboot. The load average field "floats" 
#          during the first 24 hours after a system restart.
#
# set -x # Uncomment to debug this shell script
# set -n # Uncomment to check script syntax without any execution
#
###################################################
############# DEFINE VARIABLES HERE ###############
###################################################

SECONDS=30
INTERVAL=2
MAXLOAD=2.00
typeset -i INT_MAXLOAD=$MAXLOAD

# Find the correct field to extract based on how long
# the system has been up, or since the last reboot.

if $(uptime | grep day | grep min >/dev/null)
then
     FIELD=11
elif $(uptime | grep day | grep hrs >/dev/null)
then
     FIELD=11
elif $(uptime | grep day >/dev/null)
then
     FIELD=10
elif $(uptime | grep min >/dev/null)
then
     FIELD=9
else
     FIELD=8
fi

###################################################
######## BEGIN GATHERING STATISTICS HERE ##########
###################################################

echo "\nGathering System Load Average using the \"uptime\" command\n"

# This next command statement extracts the latest 
# load statistics no matter what the UNIX flavor is.

LOAD=$(uptime | sed s/,//g | awk '{print $'$FIELD'}')

# We need an integer representation of the $LOAD
# variable to do the test for the load going over 
# the set threshold defince by the $INT_MAXLOAD
# variable

typeset -i INT_LOAD=$LOAD

# If the current load has exceeded the threshold then 
# issue a warning message. The next step always shows
# the user what the current load and threshold values
# are set to.

((INT_LOAD >= INT_MAXLOAD)) && echo "\nWARNING: System load has \
reached ${LOAD}\n" 

echo "\nSystem load value is currently at ${LOAD}"
echo "The load threshold is set to ${MAXLOAD}\n"


