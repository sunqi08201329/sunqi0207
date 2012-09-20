#!/usr/bin/ksh
#
# SCRIPT: equate_base_2_to_10.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a base 2 number
#          to a base 10 decimal representation.
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
typeset -i BASE_2_NUM
typeset -i BASE_10_NUM

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
echo "\nUSAGE: $SCRIPT_NAME base_2_number"
echo "\nEXAMPLE: $SCRIPT_NAME 1110"
echo "\nWill return the decimal base 10 number 14 ...EXITING...\n"
}

#################################################
# BEGINNING OF MAIN
#################################################

# Check for a single command line argument

if [ $# -ne 1 ]
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

# Assign the base 2 number to the BASE_10_NUM variable

BASE_2_NUM="$1"

BASE_10_NUM=$((2#${BASE_2_NUM}))

echo $BASE_10_NUM
