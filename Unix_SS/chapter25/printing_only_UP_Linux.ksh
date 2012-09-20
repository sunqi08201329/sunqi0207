#!/bin/ksh
#
# SCRIPT: printing_only_UP_Linux.ksh
#
# AUTHOR: Randy Michael
# DATE: 03/14/2007
# REV: 1.1.P
#
# PLATFORM: Linux Only
#
# PURPOSE: This script is used to enable printing on each printer
#          on a Linux system. Logging is enabled.
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
     # Check the status of printing for each printer
     case ${pqstat[2]} in
     disabled)
               # Printing is disable - print status and restart printing
               echo "${pqstat[1]} Printing is ${pqstat[2]}" \
                    | tee -a$LOGFILE
               lpc start ${pqstat[1]} | tee -a $LOGFILE
               (($? == 0)) && echo "${pqstat[1]} Printing Restarted" \
                              | tee -a $LOGFILE
             ;;
     enabled|*) : # No-Op - Do Nothing
             ;;
     esac
 done

