#!/usr/bin/ksh
#
# SCRIPT: equate_base_16_to_2.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a base 16 hexidecimal
#          number to a base 2 binary representation.
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
echo "\nWill return the binary base 2 number 64547 ...EXITING...\n"
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

# Check for a hexidecimal number!

case $1 in
+([-0-9]|[a-f]|[A-F])) BASE_16_NUM=$1
                     ;;
                  *)   usage
                     ;;
esac

BASE_2_NUM=$((16#${BASE_16_NUM}))
typeset -i2 BASE_2_NUM
echo $BASE_2_NUM
