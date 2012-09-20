#!/usr/bin/ksh
#
# SCRIPT: float_multiply.ksh
# AUTHOR: Randy Michael
# DATE: 02/23/2007
# REV: 1.1.P
#
# PURPOSE: This shell script is used to multiply a list of numbers
#          together. The numbers can be either integers or floating-
#          point numbers. For floating-point numbers the user has
#          the option of specifying a scale of the number of digits to
#          the right of the decimal point. The scale is set by adding
#          a -s or -S followed by an integer number.
#
# EXIT STATUS:
#      0 ==> This script/function exited normally
#      1 ==> Usage or syntax error
#      2 ==> This script/function exited on a trapped signal
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
NUM_LIST=     # Initialize the NUM_LIST to NULL
COUNT=0       # Initialize the counter to zero
MAX_COUNT=$#  # Set MAX_COUNT to the total number of
              # command-line arguments

########################################################
################ FUNCTIONS #############################
########################################################

function usage
{
echo "\nPURPOSE: Multiplies a list of numbers together\n"
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

if (($# < 2))
then
    echo "\nERROR: Please provide a list of numbers to multiply"
    usage
    exit 1
fi

########################################################

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
                *) echo "\nERROR: $TST_ARG is an invalid argument\n"
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
# of numbers to multiply together.

while ((COUNT < MAX_COUNT))
do
    ((COUNT = COUNT + 1))
    TOKEN=$1
    case $TOKEN in
    -s|-S) shift 2
           ((COUNT = COUNT + 1))
           ;;
    -s${SCALE}) shift
           ;;
    -S${SCALE}) shift
           ;;
    *) NUM_LIST="${NUM_LIST} $TOKEN"
       ((COUNT < MAX_COUNT)) && shift
       ;;
    esac
done

########################################################

# Ensure that the scale is an integer value

case $SCALE in
+([0-9])) : # No-Op - Do Nothing
          ;;
       *) echo "\nERROR: Invalid scale - $SCALE - Must be an integer"
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
    +(+[0-9]|[.][0-9]))
              # Check for a positive floating-point number
              # with a + prefix
              : # No-op, do nothing
              ;;
    +([-0-9]|.[0-9]))
              # Check for a negative floating-point number
              : # No-op, do nothing
              ;;
    +(-.[0-9]))
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

# Build the list of numbers to multiply

MULTIPLY=  # Initialize the MULTIPLY variable to NULL
TIMES=     # Initialize the TIMES variable to NULL

# Loop through each number and build a math statement that
# will multiply all of the numbers together.

for X in $NUM_LIST
do
    # If the number has a + prefix, remove it!
    if [[ $(echo $X | cut -c1) = '+' ]]
    then
        X=$(echo $X | cut -c2-)
    fi
    MULTIPLY="$MULTIPLY $TIMES $X"
    TIMES='*'
done

########################################################

# Do the math here by using a here document to supply
# input to the bc command. The product of the multiplication
# of the numbers is assigned to the PRODUCT variable.

echo "\nSCALE is $SCALE\n"


PRODUCT=$(bc <<EOF
scale=$SCALE
$MULTIPLY
EOF)

########################################################

# Present the result of the multiplication to the user.

echo "\nThe product of: $MULTIPLY"
echo "\nto a scale of $SCALE is ${PRODUCT}\n"
