#!/usr/bin/ksh
#
# SCRIPT: equate_base_10_to_8.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a base 10 number
#          to a base 8 octal representation.
#          This scripts expects that a base 10 number
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
typeset -i8 BASE_8_NUM
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
echo "\nUSAGE: $SCRIPT_NAME base_10_number"
echo "\nEXAMPLE: $SCRIPT_NAME 946"
echo "\nWill return the octal base 8 number 1662 ...EXITING...\n"
}

#################################################
# BEGINNING OF MAIN
#################################################

# Check for a single command line argument

if [ $# -ne 1 ]
then
        echo "\nERROR: A base 10 number must be supplied..."
        usage
        exit 1
fi

BASE_10_NUM="$1"

BASE_8_NUM=$((10#${BASE_10_NUM}))
echo $BASE_8_NUM | grep "#" >/dev/null 2>&1
if [ $? -eq 0 ]
then
        echo $BASE_8_NUM | cut -f2 -d "#"
else
        echo $BASE_8_NUM
fi
