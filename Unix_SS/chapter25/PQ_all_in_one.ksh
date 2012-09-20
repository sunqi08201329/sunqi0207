#!/bin/ksh
#
# SCRIPT: PQ_all_in_one.ksh
#
# AUTHOR: Randy Michael
# DATE: 08/14/2007
# REV: 2.1.P
#
# PLATFORM/SYSTEMS: AIX, CUPS, HP-UX, Linux, OpenBSD, and Solaris
#
# PURPOSE: This script is used to enable printing and queuing on
#           AIX, CUPS, HP-UX, Linux, OpenBDS, and Solaris
#
# REV LIST:
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check syntax without any execution
#
###################################################
# DEFINE FUNCTIONS HERE
###################################################

function AIX_classic_printing
{
for Q in $( enq -AW | tail +3 | grep DOWN | awk '{print $1}')
do
     enable $Q
     (( $? == 0 )) || echo "\n$Q print queue FAILED to enable.\n"
done
}

##########################################################

function AIX_SYSV_printing
{
LOOP=0     # Loop Counter - To grab three lines at a time

lpc status all | egrep ':|printing|queueing' | while read LINE
do
     # Load three unique lines at a time
     case $LINE in
     *:) Q=$(echo $LINE | cut -d ':' -f1)
         ;;
     printing*)
         PSTATUS=$(echo $LINE | awk '{print $3}')
         ;;
     queueing*)
         QSTATUS=$(echo $LINE | awk '{print $3}')
         ;;
     esac 

     # Increment the LOOP counter
     (( LOOP = LOOP + 1 ))
     if ((LOOP == 3))  # Do we have all three lines of data?
     then
          # Check printing status
          case $PSTATUS in
          disabled) lpc start $Q >/dev/null
                    (($? == 0)) && echo "\n$Q printing re-started\n"
                    ;;
          enabled|*) :  # No-Op - Do Nothing
                    ;;
          esac

          # Check queuing status
          case $QSTATUS in 
          disabled) lpc enable $Q >/dev/null 
                    (($? == 0)) && echo "\n$Q queueing re-enabled\n"
                    ;;
          enabled|*) :  # No-Op - Do Nothing
                    ;;
          esac
          LOOP=0  # Reset the loop counter to zero
    fi 
done
}

##########################################################

function CUPS_printing
{
LOOP=0 # Loop Counter - To grab three lines at a time

lpc status all | egrep .:|printing|queuing. | while read LINE
do
    # Load three unique lines at a time
    case $LINE in
    *:) Q=$(echo $LINE | cut -d .:. -f1)
        ;;
    printing*)
        PSTATUS=$(echo $LINE | awk .{print $3}.)
        ;;
    queuing*)
        QSTATUS=$(echo $LINE | awk .{print $3}.)
        ;;
    esac

    # Increment the LOOP counter
    (( LOOP = LOOP + 1 ))
    if ((LOOP == 3)) # Do we have all three lines of data?
    then
        # Check printing status
        case $PSTATUS in
        disabled) cupsenable $Q >/dev/null
                  (($? == 0)) && echo -e "\n$Q printing re-started\n"
                  sleep 1
                  ;;
        enabled|*) : # No-Op - Do Nothing
                  ;;
        esac

        # Check queuing status
        case $QSTATUS in
        disabled) accept $Q # >/dev/null
                  (($? == 0)) && echo -e "\n$Q queueing re-enabled\n"
                  ;;
        enabled|*) : # No-Op - Do Nothing
                  ;;
        esac

        LOOP=0 # Reset the loop counter to zero
    fi
done
}

#######################################################


function HP_UX_printing
{
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
}

################################################################33

function Linux_printing
{
lpc status | tail +2 | while read pqstat[1] pqstat[2] pqstat[3] junk
do
     # First check the status of printing for each printer
     case ${pqstat[2]} in
     disabled)
               # Printing is disable - print status and restart printing
               echo "${pqstat[1]} Printing is ${pqstat[2]}"
               lpc start ${pqstat[1]} 
               (($? == 0)) && echo "${pqstat[1]} Printing Restarted"
             ;;
     enabled|*) : # No-Op - Do Nothing
             ;;
     esac
     # Next check the status of queueing for each printer
     case ${pqstat[3]} in
     disabled) 
               echo "${pqstat[1]} Queueing is ${pqstat[3]}"
               lpc enable ${pqstat[1]}
               (($? == 0)) && echo "${pqstat[1]} Printing Restarted"
              ;;
     enabled|*) :   # No-Op - Do Nothing
             ;;
     esac
done
}

###############################################################

function OpenBSD_printing
{
LOOP=0 # Loop Counter - To grab three lines at a time

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
    if ((LOOP == 3)) # Do we have all three lines of data?
    then
        # Check queuing status
        case $QSTATUS in
        disabled) lpc enable $Q >/dev/null
                  (($? == 0)) && echo "\n$Q queueing re-enabled\n"
                  sleep 1
                  ;;
        enabled|*) : # No-Op - Do Nothing
                  ;;
        esac

        # Check printing status
        case $PSTATUS in
        disabled) lpc up $Q >/dev/null
                  (($? == 0)) && echo "\n$Q printing re-started\n"
                  ;;
        enabled|*) : # No-Op - Do Nothing
                  ;;
        esac
        LOOP=0 # Reset the loop counter to zero
    fi
done
}

#######################################################

function Solaris_printing
{
LOOP=0     # Loop Counter - To grab three lines at a time

lpc status all | egrep ':|printing|queueing' | while read LINE
do
     # Load three unique lines at a time
     case $LINE in
     *:) Q=$(echo $LINE | cut -d ':' -f1)
         ;;
     printing*)
         PSTATUS=$(echo $LINE | awk '{print $3}')
         ;;
     queueing*)
         QSTATUS=$(echo $LINE | awk '{print $3}')
         ;;
     esac 

     # Increment the LOOP counter
     (( LOOP = LOOP + 1 ))
     if ((LOOP == 3))  # Do we have all three lines of data?
     then
          # Check printing status
          case $PSTATUS in
          disabled) lpc start $Q >/dev/null
                    (($? == 0)) && echo "\n$Q printing re-started\n"
                    ;;
          enabled|*) :  # No-Op - Do Nothing
                    ;;
          esac

          # Check queuing status
          case $QSTATUS in 
          disabled) lpc enable $Q >/dev/null 
                    (($? == 0)) && echo "\n$Q queueing re-enabled\n"
                    ;;
          enabled|*) :  # No-Op - Do Nothing
                    ;;
          esac
          LOOP=0  # Reset the loop counter to zero
    fi 
done
}

######################################################
############### BEGINNING OF MAIN ####################
######################################################

# Is CUPS Running? If CUPS is running we can just
# run the CUPS standard commands.

ps auxw | grep -q [c]upsd
if (( $? == 0 ))
then
    CUPS_printing
    exit $?
fi

# What OS are we running?

# To start with we need to know the UNIX flavor.
# This case statement runs the uname command to
# determine the OS name. Different functions are
# used for each OS to restart printing and queuing.

case $(uname) in

AIX) # AIX okay...Which printer subsystem?
     # Starting with AIX 5L we support System V printing also!
     
     # Check for an active qdaemon using the SRC lssrc command

     if (ps -ef | grep '/usr/sbin/qdaemon' | grep -v grep) >/dev/null 2>&1
     then
           # Standard AIX printer subsystem found
           AIX_PSS=CLASSIC
     elif (ps -ef | grep '/usr/lib/lp/lpsched' | grep -v grep)
     then
           # AIX System V printer service is running
           AIX_PSS=SYSTEMV
     fi

     # Call the correct function for Classic AIX or SysV printing

     case $AIX_PSS in
     CLASSIC)  # Call the classic AIX printing function
               AIX_classic_printing
              ;;
     SYSTEMV)  # Call the AIX SysV printing function
               AIX_SYSV_printing
              ;;
     esac 

      ;;
HP-UX)  # Call the HP-UX printing function
        HP_UX_printing

      ;;
Linux)  # Call the Linux printing function
        Linux_printing

      ;;
OpenBSD) # Call the OpenBSD printing function
        OpenBSD_printing
      ;;
SunOS)  # Call the Soloris printing function
        Solaris_printing

      ;;
*)      # Anything else is unsupported.
 	echo "\nERROR: Unsupported Operating System: $(uname)\n"
        echo "\n\t\t...EXITING...\n"
      ;;
esac
