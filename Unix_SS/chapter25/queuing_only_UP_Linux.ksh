#!/bin/ksh
#
# SCRIPT: queuing_only_UP_Linux.ksh
#
# AUTHOR: Randy Michael
# DATE: 03/14/2007
# REV: 1.1.P
#
# PLATFORM: Linux Only
#
# PURPOSE: This script is used to enable printing and queuing separately
#          on each print queue on a Linux system. Logging can be enabled.
#
# REV LIST:
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check syntax without any execution
#
#################################################
# Initial Variables Here
#################################################

LOGILE=/usr/local/log/PQlog.log
[ -f $LOGFILE ] || echo /dev/null > $LOGFILE

#################################################

lpc status | tail +2 | while read pqstat[1] pqstat[2] pqstat[3] junk
do
     # check the status of queueing for each printer
     case ${pqstat[3]} in
     disabled) 
               echo "${pqstat[1]} Queueing is ${pqstat[3]}" \
                    | tee -a $LOGFILE
               lpc enable ${pqstat[1]} | tee -a $LOGFILE
               (($? == 0)) && echo "${pqstat[1]} Printing Restarted" \
                              | tee -a $LOGFILE
              ;;
     enabled|*) :   # No-Op - Do Nothing
             ;;
     esac
done

