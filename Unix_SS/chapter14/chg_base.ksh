#!/bin/ksh
#
# SCRIPT: chg_base.ksh
# AUTHOR: Randy Michael
# DATE: 10/4/2007
# REV: 1.1.A
#
# PURPOSE: This script converts numbers between base
# 2 through base 36. The user is prompted for input.
#
# NOTE: Numbers are in the following format:
#
#     base#number
#
# EXAMPLE:  16#264bf
#
##########################################
# DEFINE FILES AND VARIABLES HERE
##########################################

# Setup the correct awk usage. Solaris needs to
# use nawk instead of awk.

case $(uname) in
SunOS) AWK="nawk"
       ;;
    *) AWK="awk"
       ;;
esac

# Set up the correct echo command usage. Many Linux
# distributions will execute in Bash even if the
# script specifies Korn shell. Bash shell requires
# we use echo -e when we use \n, \c, etc.

case $SHELL in
*/bin/bash) alias echo="echo -e"
            ;;
esac

##########################################
# BEGINNING OF MAIN
##########################################

# Prompt the user for an input number with base

echo "\nInput the number to convert in the following format:

Format: base#number

Example: 16#264BF \n"

read ibase_num

# Extract the base from the ibase_num variable

ibase=$(echo $ibase_num | $AWK -F '#' '{print $1}')

# Test to ensure the input base is an integer

case $ibase in
  [0-9]*) : # do nothing
          ;;
       *) echo "\nERROR: $ibase is not a valid number for input base\n"
          exit 1
          ;;
esac

# Test to ensure the input base is between 2 and 36

if (( ibase < 2 || ibase > 36 ))
then
    echo "\nERROR: Input base must be between 2 and 36\n"
    exit 1
fi

# Ask the user for the output base

echo "\nWhat base do you want to convert $ibase_num to?
NOTE: base 2 through 36 are valid\n"
echo "Output base: \c"
read obase

# Test to ensure the output base is an integer

case $obase in
  [0-9]*) : # do nothing
          ;;
       *) echo "\nERROR: $obase is not a valid number\n"
          exit 1
          ;;
esac

# Test to ensure the output base is between 2 and 36

if (( obase < 2 || obase > 36 ))
then
    echo "\nERROR: Output base must be between 2 and 36\n"
    exit 1
fi

# Save the input number before changing the base

in_base_num=$ibase_num

# Convert the input number to the desire output base

typeset -i$obase ibase_num

# Assign the output base number to an appropriate variable name

obase_num=$ibase_num

# Display the result

echo "\nInput number $in_base_num is equivalent to $obase_num\n"

