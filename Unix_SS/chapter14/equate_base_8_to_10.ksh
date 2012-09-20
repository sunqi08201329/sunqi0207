#!/usr/bin/ksh
#
# SCRIPT: equate_base_8_to_10.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a base 8 number
#          to a base 10 decimal representation.
#          This scripts expects that a base 8 number
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
typeset -i BASE_8_NUM
typeset -i BASE_10_NUM

#################################################
# DEFINE FUNCTIONS HERE
#################################################

function usage
{
echo "\nUSAGE: $SCRIPT_NAME base_8_number"
echo "\nEXAMPLE: $SCRIPT_NAME 2774"
echo "\nWill return the decimal base 10 number 1532 ...EXITING...\n"
}

#################################################
# BEGINNING OF MAIN
#################################################

# Check for a single command line argument

if [ $# -ne 1 ]
then
        echo "\nERROR: A base 8 number must be supplied..."
        usage
        exit 1
fi

# Check that this single command line argument is a octal number!

case $1 in
+([-0-8])) BASE_8_NUM=$1
           ;;
        *) echo "\nERROR: $1 is NOT a base 7 number"
           usage
           exit 1
          ;;
esac

BASE_10_NUM=$((8#${BASE_8_NUM}))

echo $BASE_10_NUM
