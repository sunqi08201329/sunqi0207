#!/usr/bin/ksh
#
# SCRIPT: equate_base_2_to_16.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a base 2 number 
#          to a base 16 hexadecimal representation.
#          This scripts expects that a base 2 number
#          is supplied as a single argument.
#
# EXIT CODES:
#               0 - Normal script execution
#               1 - Usage error
#
# REV LIST:
#
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check command syntax without any execution
#
#################################################
# DEFINE FILES AND VARIABLES HERE
#################################################

SCRIPT_NAME=`basename $0`

# Set up the correct echo command usage. Many Linux
# distributions will execute in Bash even if the
# script specifies Korn shell. Bash shell requires
# we use echo -e when we use \n, \c, etc.

case $SHELL in
*/bin/bash) alias echo="echo -e"
            ;;
esac

#################################################
# DEFINE FUNCTIONS HERE
#################################################

function usage
{
echo "\nUSAGE: $SCRIPT_NAME {base 2 number}"
echo "\nEXAMPLE: $SCRIPT_NAME 1100101101"
echo "\nWill return the hexadecimal base 16 number 32d"
echo "\n\t ...EXITING...\n"
}

#################################################
# BEGINNING OF MAIN
#################################################

# Check for a single command line argument

if (($# != 1))
then
        echo "\nERROR: A base 2 number must be supplied..."
        usage
        exit 1
fi

# Check that this single command line argument is a binary number!

case $1 in
+([-0-1])) BASE_2_NUM=$1
           ;;
        *) echo "\nERROR: $1 is NOT a base 2 number"
           usage
           exit 1
          ;;
esac

# Assign the base 2 number to the BASE_16_NUM variable

BASE_16_NUM=$((2#${BASE_2_NUM}))

# Now typeset the BASE_16_NUM variable to base 16.
# This step converts the base 2 number to a base 16 number.

typeset -i16 BASE_16_NUM

# Display the resulting base 16 representation

echo $BASE_16_NUM

