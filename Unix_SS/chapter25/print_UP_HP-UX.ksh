#!/bin/ksh
#
# SCRIPT: print_UP_HP-UX.ksh
#
# AUTHOR: Randy Michael
# DATE: 03/14/2007
# REV: 1.1.P
#
# PLATFORM: HP-UX Only
#
# PURPOSE: This script is used to enable printing and queuing separately
# on each print queue on an HP-UX system.
#
# REV LIST:
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check syntax without any execution

lpstat | grep Warning: | while read LINE
do
    if (echo $LINE | grep 'is down') > /dev/null
    then
        enable $(echo $LINE | awk '{print $3}')
    fi

    if (echo $LINE | grep 'queue is turned off') >/dev/null
    then
        accept $(echo $LINE | awk '{print $3}')
    fi
done
