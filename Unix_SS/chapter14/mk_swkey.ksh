#!/usr/bin/ksh
#
# SCRIPT: mk_swkey.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to create a software
#          license key based on the IP address of the 
#          system that this shell script is executed on.
#          The system is queried for the system's IP
#          address. The IP address is striped of the
#          dots (.) and each number is converted to 
#          hexadecimal. Then each hex string is combined 
#          into a single hex string, which is the software
#          license key.
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

# Set up the correct echo command usage. Many Linux
# distributions will execute in Bash even if the
# script specifies Korn shell. Bash shell requires
# we use echo -e when we use \n, \c, etc.

case $SHELL in
*/bin/bash) alias echo="echo -e"
            echo -e "\nWARNING: This script is executing in Bash shell."
            echo "This script may fail because of an unsupported typeset"
            echo -e "command option that is only supported in Korn shell\n"
            ;;
esac

# Set up the correct awk usage. Solaris needs to
# use nawk instead of awk.

case $(uname) in
SunOS) alias awk="nawk"
       ;;
esac

#################################################
# DEFINE FUNCTIONS HERE
#################################################

function convert_base_10_to_16
{
# set -x # Uncomment to debug this function

typeset -i16 BASE_16_NUM

BASE_10_NUM=$1

BASE_16_NUM=$((10#${BASE_10_NUM}))

# Strip the number base prefix from the hexadecimal
# number. This prefix is not needed here.

echo $BASE_16_NUM | grep -q '#'
if (($? == 0))
then
        echo $BASE_16_NUM | awk -F '#' '{print $2}'
else
        echo $BASE_16_NUM
fi
}

#############################################################
# BEGINNING OF MAIN 
#############################################################

# Query the system for the IP address using the "host $(hostname)"
# command substitution.

IP=$(host $(hostname) | awk '{print $3}' | awk -F ',' '{print $1}')

# Field delimit the IP address on the dots (.) and assign each
# number to a separate variable in a "while read" loop.

echo $IP | awk -F '.' '{print $1, $2, $3, $4}' | while read a b c d junk
do
     # Convert each of the numbers in the IP address
     # into hexadecimal by calling the "convert_base_10_to16"
     # function.

     FIRST=$(convert_base_10_to_16 $a)
     SECOND=$(convert_base_10_to_16 $b)
     THIRD=$(convert_base_10_to_16 $c)
     FORTH=$(convert_base_10_to_16 $d)
done

# Combine all of the hexadecimal strings into a single
# hexadecimal string, which represents the software key.

echo "${FIRST}${SECOND}${THIRD}${FORTH}"

