#!/bin/ksh
#
# SCRIPT: print_UP_CUPS.ksh
#
# AUTHOR: Randy Michael
# DATE: 08/27/2007
# REV: 2.1.P
#
# PLATFORM: ANY RUNNING CUPS DAEMON
#
# PURPOSE: This script is used to enable printing and queuing separately
#          on each print queue for CUPS printing. 
#
# REV LIST:
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check syntax without any execution
#
#################################################

LOOP=0     # Loop Counter - To grab three lines at a time

lpc status all | egrep ':|printing|queuing' | while read LINE
do
     # Load three unique lines at a time
     case $LINE in
     *:) Q=$(echo $LINE | cut -d ':' -f1)
         ;;
     printing*)
         PSTATUS=$(echo $LINE | awk '{print $3}')
         ;;
     queuing*)
         QSTATUS=$(echo $LINE | awk '{print $3}')
         ;;
     esac

     # Increment the LOOP counter
     (( LOOP = LOOP + 1 ))
     if ((LOOP == 3))  # Do we have all three lines of data?
     then

          # Check printing status
          case $PSTATUS in
          disabled) cupsenable $Q >/dev/null
                    (($? == 0)) && echo -e "\n$Q printing re-started\n"
                    sleep 1
                    ;;
          enabled|*) :  # No-Op - Do Nothing
                    ;;
          esac

          # Check queuing status
          case $QSTATUS in
          disabled) accept $Q # >/dev/null
                    (($? == 0)) && echo -e "\n$Q queueing re-enabled\n"
                    ;;
          enabled|*) :  # No-Op - Do Nothing
                    ;;
          esac

          LOOP=0  # Reset the loop counter to zero
    fi
done
