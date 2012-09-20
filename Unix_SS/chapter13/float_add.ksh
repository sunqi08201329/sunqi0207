#!/usr/bin/ksh
#
# SCRIPT: float_add.ksh
# AUTHOR: Randy Michael
# DATE: 03/01/2007
# REV: 1.1.A
#
# PURPOSE: This shell script is used to add a list of numbers
#          together. The numbers can be either integers or floating-
#          point numbers. For floating-point numbers the user has
#          the option of specifying a scale of the number of digits to
#          the right of the decimal point. The scale is set by adding
#          a -s or -S followed by an integer number.
#
# EXIT CODES:
#      0 ==> This script completed without error
#      1 ==> Usage error
#      2 ==> This script exited on a trapped signal
#
# REV. LIST:
#
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to debug without any command execution
#
########################################################
############## DEFINE VARIABLE HERE ####################
########################################################

SCRIPT_NAME=$(basename $0) # The name of this shell script
SCALE="0"     # Initialize the scale value to zero
NUM_LIST=     # Initialize the NUM_LIST variable to NULL
COUNT=0       # Initialize the counter to zero
MAX_COUNT=$#  # Set MAX_COUNT to the total number of
              # command-line arguments.

########################################################
################ FUNCTIONS #############################
########################################################

function usage
{
echo "\nPURPOSE: Adds a list of numbers together\n"
echo "USAGE: $SCRIPT_NAME [-s scale_value] N1 N2...Nn"
echo "\nFor an integer result without any significant decimal places..."
echo "\nEXAMPLE: $SCRIPT_NAME 2048.221 65536 \n"
echo "OR for 4 significant decimal places"
echo "\nEXAMPLE: $SCRIPT_NAME -s 4 8.09838 2048 65536 42.632"
echo "\n\t...EXITING...\n"
}

########################################################

function exit_trap
{
echo "\n...EXITING on trapped signal...\n"
}

########################################################
################# START OF MAIN ########################
########################################################

###### Set a Trap ######

trap 'exit_trap; exit 2' 1 2 3 15

########################################################

# Check for at least two command-line arguments

if [ $# -lt 2 ]
then
    echo "\nERROR: Please provide a list of numbers to add"
    usage
    exit 1
fi

# Parse the command-line arguments to find the scale value, if present.

while getopts ":s:S:" ARGUMENT
do
    case $ARGUMENT in
    s|S) SCALE=$OPTARG
         ;;
     \?) # Because we may have negative numbers we need
         # to test to see if the ARGUMENT that begins with a
         # hyphen (-) is a number, and not an invalid switch!!!

         for TST_ARG in $*
         do
            if [[ $(echo $TST_ARG | cut -c1) = '-' ]] \
            && [ $TST_ARG != '-s' -a $TST_ARG != '-S' ]
            then
                case $TST_ARG in
                +([-0-9])) : # No-op, do nothing
                           ;;
                +([-0-9].[0-9]))
                           : # No-op, do nothing
                           ;;
                +([-.0-9])) : # No-op, do nothing
                           ;;
                        *) echo "\nERROR: Invalid argument \
on the command line"
                           usage
                           exit 1
                           ;;
                esac
            fi
         done
         ;;
    esac
done

########################################################

# Parse through the command-line arguments and gather a list
# of numbers to add together and test each value.

while ((COUNT < MAX_COUNT))
do
    ((COUNT = COUNT + 1))
    TOKEN=$1   # Grab a command-line argument on each loop iteration
    case $TOKEN in   # Test each value and look for a scale value.
    -s|-S) shift 2
           ((COUNT = COUNT + 1))
           ;;
    -s${SCALE}) shift
           ;;
    -S${SCALE}) shift
           ;;
        *) # Add the number ($TOKEN) to the list
           NUM_LIST="${NUM_LIST} $TOKEN"
           ((COUNT < MAX_COUNT)) && shift
           ;;
    esac
done

########################################################

# Ensure that the scale is an integer value

case $SCALE in
     # Test for an integer
     +([0-9])) : # No-Op - Do Nothing
               ;;
            *) echo "\nERROR: Invalid scale - $SCALE - \
Must be an integer"
               usage
               exit 1
               ;;
esac

########################################################

# Check each number supplied to ensure that the "numbers"
# are either integers or floating-point numbers.

for NUM in $NUM_LIST
do
    case $NUM in
    +([0-9])) # Check for an integer
              : # No-op, do nothing.
              ;;
    +([-0-9])) # Check for a negative whole number
              : # No-op, do nothing
              ;;
    +([0-9]|[.][0-9]))
              # Check for a positive floating-point number
              : # No-op, do nothing
              ;;
    +(+[0-9][.][0-9]))
              # Check for a positive floating-point number
              # with a + prefix
              : # No-op, do nothing
              ;;
    +(-[0-9][.][0-9]))
              # Check for a negative floating-point number
              : # No-op, do nothing
              ;;
    +([-.0-9]))
              # Check for a negative floating-point number
              : # No-op, do nothing
              ;;
    +([+.0-9]))
              # Check for a positive floating-point number
              : # No-op, do nothing
              ;;
    *) echo "\nERROR: $NUM is NOT a valid number"
       usage
       exit 1
       ;;
    esac
done

########################################################

# Build the list of numbers to add

ADD=    # Initialize the ADD variable to NULL
PLUS=   # Initialize the PLUS variable to NULL

# Loop through each number and build a math statement that
# will add all of the numbers together.

for X in $NUM_LIST
do
    # If the number has a + prefix, remove it!
    if [[ $(echo $X | cut -c1) = '+' ]]
    then
        X=$(echo $X | cut -c2-)
    fi
    ADD="$ADD $PLUS $X"
    PLUS="+"
done

########################################################
# Do the math here by using a here document to supply
# input to the bc command. The sum of the numbers is
# assigned to the SUM variable.

echo "\nSCALE is $SCALE\n"


SUM=$(bc <<EOF
scale=$SCALE
(${ADD})
EOF)

########################################################

# Present the result of the addition to the user.

echo "\nThe sum of: $ADD"
echo "\nis: ${SUM}\n"
