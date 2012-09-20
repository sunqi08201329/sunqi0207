#!/usr/bin/ksh
#
# AUTHOR: Randy Micahel
# SCRIPT: random_number.ksh
# DATE: 11/12/2007
# REV: 1.2.P
#
# PLATFORM: Not Platform Dependent
#
# EXIT CODES:
#		0 - Normal script execution
#		1 - Usage error
#
# REV LIST:
#
#
# set -x # Uncomment to debug
# set -n # Uncomment to check syntax without any command execution
#
####################################################
########## DEFINE FUNCTIONS HERE ###################
####################################################

function usage
{
echo "\nUSAGE: $SCRIPT_NAME [-f] [upper_number_range]"
echo "\nEXAMPLE: $SCRIPT_NAME"
echo "Will return a random number between 0 and 32767" 
echo "\nEXAMPLE: $SCRIPT_NAME 1000"
echo "Will return a random number between 1 and 1000"
echo "\nEXAMPLE: $SCRIPT_NAME -f 1000"
echo "Will add leading zeros to a random number from"
echo "1 to 1000, which keeps the number of digits consistant\n"
}

####################################################

function get_random_number
{
# This function gets the next random number from the
# $RANDOM variable. The range is 0 to 32767.

echo "$RANDOM"
}

####################################################

function in_range_random_number
{
# Create a pseudo-random number less than or equal
# to the $UPPER_LIMIT value, which is user defined

RANDOM_NUMBER=$(($RANDOM % $UPPER_LIMIT + 1))

echo "$RANDOM_NUMBER"
}

####################################################

function in_range_fixed_length_random_number_typeset
{
# Create a pseudo-random number less than or equal
# to the $UPPER_LIMIT value, which is user defined.
# This function will also pad the output with leading
# zeros to keep the number of digits consistent using
# the typeset command.

# Find the length of each character string

UL_LENGTH=$(echo ${#UPPER_LIMIT})

# Fix the length of the RANDOM_NUMBER variable to
# the length of the UPPER_LIMIT variable, specified
# by the $UL_LENGTH variable.

typeset -Z$UL_LENGTH RANDOM_NUMBER

# Create a fixed length pseudo-random number

RANDOM_NUMBER=$(($RANDOM % $UPPER_LIMIT + 1))

# Return the value of the fixed length $RANDOM_NUMBER

echo $RANDOM_NUMBER
}

####################################################
############## BEGINNING OF MAIN ###################
####################################################

SCRIPT_NAME=`basename $0`

RANDOM=$$  # Initialize the RANDOM environment variable
           # using the PID as the initial seed

case $# in
0)   get_random_number
;;

1)  UPPER_LIMIT="$1"

    # Test to see if $UPPER_LIMIT is a number

    case $UPPER_LIMIT in
    +([0-9])) :    # Do Nothing...It's a number
                   # NOTE: A colon (:) is a no-op in Korn shell
            ;;
    *)        echo "\nERROR: $UPPER_LIMIT is not a number..."
              usage
              exit 1
            ;;
    esac
 
    in_range_random_number
;;

2)  # Check for the -f switch to fix the length.

    if [[ $1 = '-f' ]] || [[ $1 = '-F' ]]
    then

         UPPER_LIMIT="$2"

         # Test to see if $UPPER_LIMIT is a number

         case $UPPER_LIMIT in
         +([0-9])) :    # Do Nothing...It's a number
                        # NOTE: A colon (:) is a no-op in Korn shell
               ;;
         *)        echo "\nERROR: $UPPER_LIMIT is not a number..."
                   usage
                   exit 1
               ;;
         esac

         in_range_fixed_length_random_number_typeset

    else 
         echo "\nInvalid argument $1, see usage below..."
         usage
         exit 1
    fi
;;

*)  usage
    exit 1
;;
esac

# End of random_number.ksh Shell Script
