#!/usr/bin/ksh
#
# SCRIPT: equate_base_10_to_16.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a base 10 number
# to a base 16 hexadecimal representation.
# This script expects that a base 10 number
# is supplied as a single argument.
#
# EXIT CODES:
#               0 - Normal script execution
#               1 - Usage error
#
#
# REV LIST:
#
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check command syntax without any execution
#
#
#################################################
# DEFINE FILES AND VARIABLES HERE
#################################################

SCRIPT_NAME=`basename $0`

# Set up the correct echo command usage. Many Linux
# distributions will execute in Bash even if the
# script specifies Korn shell. Bash shell requires
# we use echo -e when we use \n, \c, etc.

case $(basename $SHELL) in
bash) alias echo="echo -e"
      ;;
esac

#################################################
# DEFINE FUNCTIONS HERE
#################################################
function usage
{
echo "\nUSAGE: $SCRIPT_NAME {base 10 number}"
echo "\nEXAMPLE: $SCRIPT_NAME 694"
echo "\nWill return the hexadecimal number 2b6"
echo "\n\t...EXITING...\n"
}

#################################################
# BEGINNING OF MAIN
#################################################

# Check for a single command-line argument

if [ $# -ne 1 ]
then
        echo "\nERROR: A base 10 number must be supplied..."
        usage
        exit 1
fi

# Check that this single command-line argument is a base 10 number!
case $1 in
+([0-9])) BASE_10_NUM=$1
          ;;
*) echo "\nERROR: $1 is NOT a base 10 number"
   usage
   exit 1
   ;;
esac

# Assign the base 10 number to the BASE_16_NUM variable

BASE_16_NUM=10#$BASE_10_NUM

# NOTE: Since base 10 is implied by default,
# the 10# may be omitted as a prefix. Both notations
# are supported

# Now typeset the BASE_16_NUM variable to base 16.
# This step converts the base 10 number to a base 16 number.

typeset -i16 BASE_16_NUM

# Display the resulting base 16 number representation

echo $BASE_16_NUM

# This following code is optional. It removes the number base
# prefix. This may be helpful if using this script with
# other programs and scripts.
#
# Set up the correct awk usage. Solaris needs to
# use nawk instead of awk.
#
# case $(uname) in
# SunOS) AWK="nawk"
#        ;;
#     *) AWK="awk"
#        ;;
# esac
#
# Strip out the base prefix and the pound sign (#). (Optional)
#
# echo $BASE_16_NUM | grep -q "#"
#
# if (($? == 0))
# then
#     echo $BASE_16_NUM | $AWK -F '#' '{print $2}'
# else
#     echo $BASE_16_NUM
# fi
