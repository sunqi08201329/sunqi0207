#!/usr/bin/ksh
#
# SCRIPT: float_aaverage.ksh
# AUTHOR: Randy Michael
# DATE: 03/01/2007
# REV: 1.1.A
#
# PURPOSE: This script is used to average a list of 
#   floating-point numbers. 
#      
# EXIT STATUS:
#       0 ==> This script completed without error
#       1 ==> Usage error
#       2 ==> This script exited on a trapped signal
#
# REV. LIST:
#
#
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to debug without any command execution

SCRIPT_NAME=`basename $0`
ARG1="$1"
ARG2="$2"
ARG_LIST="$*"
TOTAL_TOKENS="$#"
SCALE="0"

########################################################
################ FUNCTIONS #############################
########################################################

function usage
{
echo "\n\n"
echo "Numbers to average...\n"
echo "USAGE: $SCRIPT_NAME [-s scale_value]  N1 N2...N#"
echo "\nFor an integer result without any significant decimal places..."
echo "\nEXAMPLE: $SCRIPT_NAME 2048.221 65536 \n"
echo "OR for 4 significant decimal places"
echo "\nEXAMPLE: $SCRIPT_NAME -s 4  8.09838 2048 65536 42.632\n"
echo "Try again...EXITING...\n"
}
########################################################

function exit_trap
{
echo "\n...EXITING on trapped signal...\n"
}

########################################################
################ START OF MAIN #########################
########################################################

###### Set a Trap ######

trap 'exit_trap; exit 2' 1 2 3 15

########################

if [ $# -lt 2 ]
then
    echo "\nIncorrect number of command auguments...Nothing to average..."
    usage
    exit 1
fi

if [ $ARG1 = "-s" ] || [ $ARG1 = "-S" ]
then
    echo $ARG2 | grep [[:digit:]] >/dev/null 2>&1
    if [ $? -ne "0" ]
    then
        echo "\nERROR: Invalid argument - $ARG2 ... Must be an integer...\n"
        usage
        exit 1
    fi
    echo $ARG2 | grep "\." >/dev/null 2>&1
    if [ $? -ne "0" ]
    then
        SCALE="$ARG2"
        NUM_LIST=`echo $ARG_LIST | cut -f 3- -d " "`
        (( TOTAL_TOKENS = $TOTAL_TOKENS - 2 ))
    else
        echo "\nERROR: Invalid scale - $ARG2 ... Scale must be an integer...\n"
        usage
        exit 1
    fi
else
    NUM_LIST=$ARG_LIST
fi

for TOKEN in $NUM_LIST
do
    echo $TOKEN | grep [[:digit:]] >/dev/null 2>&1
    RC=$?
    case $RC in
    0) cat /dev/null
       ;;
    *) echo "\n$TOKEN is not a number...Invalid argument list"
       usage
       exit 1
       ;;
    esac
done


# Build the list of numbers to add for averaging...

ADD=""
PLUS=""
for X in $NUM_LIST
do
    ADD="$ADD $PLUS $X"
    PLUS="+"
done

# Do the math here

AVERAGE=`bc <<EOF
scale=$SCALE
(${ADD}) / $TOTAL_TOKENS
EOF`

########################################################

# Present the result of the average to the user.

echo "\nThe averaging equation: (${ADD}) / $TOTAL_TOKENS"
echo "\nto a scale of $SCALE is: ${AVERAGE}\n"

