#!/usr/bin/ksh
#
# SCRIPT: equate_base_16_to_10.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a base 16 number
#          to a base 10 decimal representation.
#          This scripts expects that a base 16 number
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
echo "\nUSAGE: $SCRIPT_NAME base_16_number"
echo "\nEXAMPLE: $SCRIPT_NAME FC23"
echo "\nWill return the decimal base 10 number 64547 ...EXITING...\n"
}

#################################################
# BEGINNING OF MAIN
#################################################

# Check for a single command line argument

if [ $# -ne 1 ]
then
     echo "\nERROR: A base 16 number must be supplied..."
     usage
     exit 1
fi

BASE_16_NUM="$1"

BASE_10_NUM=$((16#${BASE_16_NUM}))
echo $BASE_10_NUM
