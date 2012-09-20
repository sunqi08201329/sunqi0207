#!/bin/ksh
#
# SCRIPT: proc_watch_timed.ksh
# AUTHOR: Randy Michael
# DATE: 09-14-2007
# REV: 1.0.P
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This script is used to monitor and log
#          the status of a process as it starts and stops.
#          Command line options are used to identify the target
#          process to monitor and the length of time to monitor.
#          Each event is logged to the file defined by the
#          $LOGFILE variable. This script also has the ability
#          to execute pre, startup, and post events. These are
#          controlled by the $RUN_PRE_EVENT, $RUN_STARTUP_EVENT,
#          and $RUN_POST_EVENT variables. These variables control
#          execution individually. Whatever is to be executed is to
#          be placed in either the "pre_event_script",
#          startup_event_script, or the
#          "post_event_script" functions, or in any combination.
#          Timing is controlled on the command line.
#
#          USAGE: $SCRIPT_NAME total_seconds target_process
#
#          Will monitor the specified process for the
#          specified number of seconds.
#
#          USAGE: $SCRIPT_NAME [-s|-S seconds] [-m|-M minutes]
#                              [-h|-H hours] [-d|-D days]
#                              [-p|-P process]
#
#          Will monitor the specified process for number of
#          seconds specified within -s seconds, -m minutes,
#          -h hours, and -d days. Any combination of command
#          switches can be used.
#
# REV LIST:
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check syntax without ANY execution
#
####################################################
########## DEFINE FILES AND VARIABLES HERE #########
####################################################

typeset -u RUN_PRE_EVENT # Force to UPPERCASE
typeset -u RUN_STARTUP_EVENT # Force to UPPERCASE
typeset -u RUN_POST_EVENT # force to UPPERCASE

RUN_PRE_EVENT='N' # A 'Y' will execute, anything else will not
RUN_STARTUP_EVENT='Y' # A 'Y' will execute, anything else will not
RUN_POST_EVENT='Y' # A 'Y' will execute, anything else will not

LOGFILE="/tmp/proc_status.log"
[[ ! -s $LOGFILE ]] && touch $LOGFILE

SCRIPT_NAME=$(basename $0)
TTY=$(tty)
INTERVAL="1" # Seconds between sampling
JOBS=

####################################################
############# DEFINE FUNCTIONS HERE ################
####################################################
usage ()
{
echo "\n\n\t*****USAGE ERROR*****"
echo "\n\nUSAGE: $SCRIPT_NAME seconds process"
echo "\nWill monitor the specified process for the"
echo "specified number of seconds."
echo "\nUSAGE: $SCRIPT_NAME [-s|-S seconds] [-m|-M minutes]"
echo " [-h|-H hours] [-d|-D days] [-p|-P process]\n"
echo "\nWill monitor the specified process for number of"
echo "seconds specified within -s seconds, -m minutes,"
echo "-h hours and -d days. Any combination of command"
echo "switches can be used.\n"
echo "\nEXAMPLE: $SCRIPT_NAME 300 dtcalc"
echo "\n\nEXAMPLE: $SCRIPT_NAME -m 5 -p dtcalc"
echo "\nBoth examples will monitor the dtcalc process"
echo "for 5 minutes. Can specify days, hours, minutes"
echo "and seconds, using -d, -h, -m and -s\n\n"
}
####################################################
trap_exit ()
{
# set -x # Uncommant to debug this function
# Log an ending time for process monitoring
echo "INTERRUPT: Program Received an Interrupt...EXITING..." > $TTY
echo "INTERRUPT: Program Received an Interrupt...EXITING..." >> $LOGFILE
TIMESTAMP=$(date +%D@%T) # Get a new timestamp...
echo "MON_STOPPED: Monitoring for $PROCESS ended ==> $TIMESTAMP\n" \
      >> $TTY
echo "MON_STOPPED: Monitoring for $PROCESS ended ==> $TIMESTAMP\n" \
      >> $LOGFILE
echo "LOGFILE: All Events are Logged ==> $LOGFILE \n" > $TTY

# Kill all functions
JOBS=$(jobs -p)
if [[ ! -z $JOBS && $JOBS != '' && $JOBS != '0' ]]
then
    kill $(jobs -p) 2>/dev/null 1>&2
fi
return 2
}
####################################################
pre_event_script ()
{
# Put anything that you want to execute BEFORE the
# monitored process STARTS in this function

:   # No-OP - Needed as a placeholder for an empty function
    # Comment Out the Above colon, ':'

PRE_RC=$?
return $PRE_RC
}
####################################################
startup_event_script ()
{
# Put anything that you want to execute WHEN, or AS, the
# monitored process STARTS in this function

:    # No-OP - Needed as a placeholder for an empty function
     # Comment Out the Above colon, ':'

STARTUP_RC=$?
return $STARTUP_RC
}
####################################################
post_event_script ()
{
# Put anything that you want to execute AFTER the
# monitored process ENDS in this function

:     # No-OP - Need as a placeholder for an empty function
      # Comment Out the Above colon, ':'

POST_RC=$?
return $POST_RC
}
####################################################
# This function is used to test character strings

test_string ()
{
if (( $# != 1 ))
then
     echo 'ERROR'
     return
fi

C_STRING=$1

# Test the character string for its composition

case $C_STRING in

     +([0-9])) echo 'POS_INT' # Integer >= 0
               ;;
     +([-0-9])) echo 'NEG_INT' # Integer < 0
               ;;
     +([a-z])) echo 'LOW_CASE' # lower case text
               ;;
     +([A-Z])) echo 'UP_CASE' # UPPER case text
               ;;
     +([a-z]|[A-Z])) echo 'MIX_CASE' # MIxed CAse text
               ;;
            *) echo 'UNKNOWN' # Anything else
               ;;
esac
}
####################################################
proc_watch ()
{
# set -x # Uncomment to debug this function
# This function does all of the process monitoring!

while : # Loop Forever!!
do
    case $RUN in
    'Y')
        # This will run the startup_event_script, which is a function
        if [[ $RUN_STARTUP_EVENT = 'Y' ]]
        then
           echo "STARTUP EVENT: Executing Startup Event Script..."\
                 > $TTY
           echo "STARTUP EVENT: Executing Startup Event Script..."\
                  >> $LOGFILE

           startup_event_script # USER DEFINED FUNCTION!!!
           RC=$? # Check the Return Code!!
           if (( "RC" == 0 ))
           then
               echo "SUCCESS: Startup Event Script Completed RC - \
${RC}" > $TTY
               echo "SUCCESS: Startup Event Script Completed RC - \
${RC}" >> $LOGFILE

           else
               echo "FAILURE: Startup Event Script FAILED RC - \
${RC}" > $TTY
               echo "FAILURE: Startup Event Script FAILED RC - \
${RC}" >> $LOGFILE
           fi
        fi
        integer PROC_COUNT='-1' # Reset the Counters
        integer LAST_COUNT='-1'
        # Loop until the process(es) end(s)

        until (( "PROC_COUNT" == 0 ))
        do
           # This function is a Co-Process. $BREAK checks to see if
           # "Program Interrupt" has taken place. If so BREAK will
           # be 'Y' and we exit both the loop and function.

           read BREAK
           if [[ $BREAK = 'Y' ]]
           then
               return 3
           fi

           PROC_COUNT=$(ps aux | grep -v "grep $PROCESS" \
                        | grep -v $SCRIPT_NAME \
                        | grep $PROCESS | wc -l) >/dev/null 2>&1

           if (( "LAST_COUNT" > 0 && "LAST_COUNT" != "PROC_COUNT" ))
           then
               # The Process Count has Changed...
               TIMESTAMP=$(date +%D@%T)
               # Get a list of the PID of all of the processes
               PID_LIST=$(ps aux | grep -v "grep $PROCESS" \
                      | grep -v $SCRIPT_NAME \
                      | grep $PROCESS | awk '{print $2}')

               echo "PROCESS COUNT: $PROC_COUNT $PROCESS\
Processes Running ==> $TIMESTAMP" >> $LOGFILE &
               echo "PROCESS COUNT: $PROC_COUNT $PROCESS\
Processes Running ==> $TIMESTAMP" > $TTY
               echo ACTIVE PIDS: $PID_LIST >> $LOGFILE &
echo ACTIVE PIDS: $PID_LIST > $TTY
           fi
           LAST_COUNT=$PROC_COUNT
           sleep $INTERVAL # Needed to reduce CPU load!
        done

        RUN='N' # Turn the RUN Flag Off
        TIMESTAMP=$(date +%D@%T)
        echo "ENDING PROCESS: $PROCESS END time ==>\
$TIMESTAMP" >> $LOGFILE &
        echo "ENDING PROCESS: $PROCESS END time ==>\
$TIMESTAMP" > $TTY

        # This will run the post_event_script, which is a function

        if [[ $RUN_POST_EVENT = 'Y' ]]
        then
            echo "POST EVENT: Executing Post Event Script..."\
                  > $TTY
            echo "POST EVENT: Executing Post Event Script..."\
                  >> $LOGFILE &

            post_event_script # USER DEFINED FUNCTION!!!
            integer RC=$?
            if (( "RC" == 0 ))
            then
                echo "SUCCESS: Post Event Script Completed RC - \
${RC}" > $TTY
                echo "SUCCESS: Post Event Script Completed RC - \
${RC}" >> $LOGFILE
            else
                echo "FAILURE: Post Event Script FAILED RC - ${RC}"\
                      > $TTY
                echo "FAILURE: Post Event Script FAILED RC - ${RC}"\
                      >> $LOGFILE
            fi
       fi
       ;;

   'N')
       # This will run the pre_event_script, which is a function

       if [[ $RUN_PRE_EVENT = 'Y' ]]
       then
          echo "PRE EVENT: Executing Pre Event Script..." > $TTY
          echo "PRE EVENT: Executing Pre Event Script..." >> $LOGFILE

          pre_event_script # USER DEFINED FUNCTION!!!
          RC=$? # Check the Return Code!!!
          if (( "RC" == 0 ))
          then
              echo "SUCCESS: Pre Event Script Completed RC - ${RC}"\
                    > $TTY
              echo "SUCCESS: Pre Event Script Completed RC - ${RC}"\
                    >> $LOGFILE
          else
              echo "FAILURE: Pre Event Script FAILED RC - ${RC}"\
                    > $TTY
              echo "FAILURE: Pre Event Script FAILED RC - ${RC}"\
                    >> $LOGFILE
          fi
       fi

       echo "WAITING: Waiting for $PROCESS to \
startup...Monitoring..."

       integer PROC_COUNT='-1' # Initialize to a fake value

       # Loop until at least one process starts

       until (( "PROC_COUNT" > 0 ))
       do
           # This is a Co-Process. This checks to see if a "Program
           # Interrupt" has taken place. If so BREAK will be 'Y' and
           # we exit both the loop and function

           read BREAK
           if [[ $BREAK = 'Y' ]]
           then
               return 3
           fi

           PROC_COUNT=$(ps aux | grep -v "grep $PROCESS" \
                        | grep -v $SCRIPT_NAME | grep $PROCESS | wc -l) \
                          >/dev/null 2>&1

           sleep $INTERVAL # Needed to reduce CPU load!
       done

       RUN='Y' # Turn the RUN Flag On

       TIMESTAMP=$(date +%D@%T)

       PID_LIST=$(ps aux | grep -v "grep $PROCESS" \
                  | grep -v $SCRIPT_NAME \
                  | grep $PROCESS | awk '{print $2}')

       if (( "PROC_COUNT" == 1 ))
       then
           echo "START PROCESS: $PROCESS START time ==>\
$TIMESTAMP" >> $LOGFILE &
           echo ACTIVE PIDS: $PID_LIST >> $LOGFILE &
           echo "START PROCESS: $PROCESS START time ==>\
$TIMESTAMP" > $TTY
           echo ACTIVE PIDS: $PID_LIST > $TTY
       elif (( "PROC_COUNT" > 1 ))
       then
           echo "START PROCESS: $PROC_COUNT $PROCESS\
Processes Started: START time ==> $TIMESTAMP" >> $LOGFILE &
           echo ACTIVE PIDS: $PID_LIST >> $LOGFILE &
           echo "START PROCESS: $PROC_COUNT $PROCESS\
Processes Started: START time ==> $TIMESTAMP" > $TTY
           echo ACTIVE PIDS: $PID_LIST > $TTY
       fi
       ;;
    esac
done
}

####################################################
############## START OF MAIN #######################
####################################################

### SET A TRAP ####

trap 'BREAK='Y';print -p $BREAK 2>/dev/null;trap_exit\
2>/dev/null;exit 0' 1 2 3 15

BREAK='N' # The BREAK variable is used in the co-process proc_watch
PROCESS=  # Initialize to null
integer TOTAL_SECONDS=0

# Check commnand line arguments

if (( $# > 10 || $# < 2 ))
then
    usage
    exit 1
fi

# Check to see if only the seconds and a process are
# the only arguments

if [[ ($# -eq 2) && ($1 != -*) && ($2 != -*) ]]
then
    NUM_TEST=$(test_string $1) # Is this an Integer?
    if [[ "$NUM_TEST" = 'POS_INT' ]]
    then
        TOTAL_SECONDS=$1 # Yep - It.s an Integer
        PROCESS=$2 # Can be anything
    else
        usage
        exit 1
    fi
else
    # Since getopts does not care what arguments it gets, let.s
    # do a quick sanity check to make sure that we only have
    # between 2 and 10 arguments and the first one must start
    # with a -* (hyphen and anything), else usage error

    case "$#" in
    [2-10]) if [[ $1 != -* ]]; then
                usage; exit 1
            fi
            ;;
    esac

    HOURS=0 # Initialize all to zero
    MINUTES=0
    SECS=0
    DAYS=0

    # Use getopts to parse the command line arguments
    # For each $OPTARG for DAYS, HOURS, MINUTES and DAYS check to see
    # that each one is an integer by using the check_string function

    while getopts ":h:H:m:M:s:S:d:D:P:p:" OPT_LIST 2>/dev/null
    do
      case $OPT_LIST in
      h|H) [[ $(test_string $OPTARG) != 'POS_INT' ]] && usage && exit 1
           (( HOURS = $OPTARG * 3600 )) # 3600 seconds per hour
           ;;
      m|H) [[ $(test_string $OPTARG) != 'POS_INT' ]] && usage && exit 1
           (( MINUTES = $OPTARG * 60 )) # 60 seconds per minute
           ;;
      s|S) [[ $(test_string $OPTARG) != 'POS_INT' ]] && usage && exit 1
           SECS="$OPTARG" # seconds are seconds
           ;;
      d|D) [[ $(test_string $OPTARG) != 'POS_INT' ]] && usage && exit 1
           (( DAYS = $OPTARG * 86400 )) # 86400 seconds per day
           ;;
      p|P) PROCESS=$OPTARG # process can be anything
           ;;
       \?) usage # USAGE ERROR
           exit 1
           ;;
        :) usage
           exit 1
           ;;
        *) usage
           exit 1
           ;;
      esac
    done
fi

# We need to make sure that we have a process that
# is NOT null or empty! - sanity check - The double quotes are required!

if [[ -z "$PROCESS" || "$PROCESS" = '' ]]
then
    usage
    exit 1
fi

# Check to see that TOTAL_SECONDS was not previously set

if (( TOTAL_SECONDS == 0 ))
then
    # Add everything together if anything is > 0
    if [[ $SECS -gt 0 || $MINUTES -gt 0 || $HOURS -gt 0 \
          || $DAYS -gt 0 ]]
    then
        (( TOTAL_SECONDS = SECS + MINUTES + HOURS + DAYS ))
    fi
fi

# Last Sanity Check!

if (( TOTAL_SECONDS <= 0 )) || [ -z $PROCESS ]
then
    # Either There are No Seconds to Count or the
    # $PROCESS Variable is Null...USAGE ERROR...

    usage
    exit 1
fi

########### START MONITORING HERE!###########

echo "\nCurrently running $PROCESS processes:\n" > $TTY
ps aux | grep -v "grep $PROCESS" | grep -v $SCRIPT_NAME \
       | grep $PROCESS > $TTY

PROC_RC=$? # Get the initial state of the monitored function

echo >$TTY # Send a blank line to the screen

(( PROC_RC != 0 )) && echo "\nThere are no $PROCESS processes running\n"

if (( PROC_RC == 0 )) # The Target Process(es) is/are running...
then
    RUN='Y' # Set the RUN flag to true, or yes.

    integer PROC_COUNT # Strips out the "padding" for display

    PROC_COUNT=$(ps aux | grep -v "grep $PROCESS" | grep -v \
                 $SCRIPT_NAME | grep $PROCESS | wc -l) >/dev/null 2>&1
    if (( PROC_COUNT == 1 ))
    then
        echo "The $PROCESS process is currently\
running...Monitoring...\n"
    elif (( PROC_COUNT > 1 ))
    then
        print "There are $PROC_COUNT $PROCESS processes currently\
running...Monitoring...\n"
    fi
else
    echo "The $PROCESS process is not currently running...monitoring..."
    RUN='N' # Set the RUN flag to false, or no.
fi

TIMESTAMP=$(date +%D@%T) # Time that this script started monitoring

# Get a list of the currently active process IDs

PID_LIST=$(ps aux | grep -v "grep $PROCESS" \
           | grep -v $SCRIPT_NAME \
           | grep $PROCESS | awk '{print $2}')

echo "MON_STARTED: Monitoring for $PROCESS began ==> $TIMESTAMP" \
      | tee -a $LOGFILE
echo ACTIVE PIDS: $PID_LIST | tee -a $LOGFILE

##### NOTICE ####
# We kick off the "proc_watch" function below as a "Co-Process"
# This sets up a two way communications link between the
# "proc_watch" background function and this "MAIN BODY" of
# the script. This is needed because the function has two
# "infinite loops", with one always executing at any given time.
# Therefore we need a way to break out of the loop in case of
# an interrupt, i.e. CTRL+C, and when the countdown is complete.
# The "pipe appersand", |&, creates the background Co-Process
# and we use "print -p $VARIABLE" to transfer the variable.s
# value back to the background co-process.
###################################

proc_watch |& # Create a Background Co-Process!!
WATCH_PID=$! # Get the process ID of the last background job!

# Start the Count Down!

integer SECONDS_LEFT=$TOTAL_SECONDS

while (( SECONDS_LEFT > 0 ))
do
    # Next send the current value of $BREAK to the Co-Process
    # proc_watch, which was piped to the background...

    print -p $BREAK 2>/dev/null
    (( SECONDS_LEFT = SECONDS_LEFT - 1 ))
    sleep 1 # 1 Second Between Counts
done

# Finished - Normal Timeout Exit...
TIMESTAMP=$(date +%D@%T) # Get a new timestamp...
echo "MON_STOPPED: Monitoring for $PROCESS ended ==> $TIMESTAMP\n" \
      | tee -a $LOGFILE

echo "LOGFILE: All Events are Logged ==> $LOGFILE \n"

# Tell the proc_watch function to break out of the loop and die
BREAK='Y'
print -p $BREAK 2>/dev/null

kill $WATCH_PID 2>/dev/null

exit 0

# End of Script
