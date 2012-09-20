#!/bin/bash
#
# SCRIPT: chg_base_bc.bash
# AUTHOR: Randy Michael
# DATE: 10/4/2007
# REV: 1.1.A
#
# PURPOSE: This script converts numbers between base
# 2 through base 16 using the bc utility. The user 
# is prompted for input.
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

##########################################
# BEGINNING OF MAIN
##########################################

# Prompt the user for an input number with base

echo -e "\nInput the number to convert in the following format:

Format: base#number

Example: 16#264BF \n"

read IBASE_NUM

# Extract the base from the ibase_num variable

IBASE=$(echo $IBASE_NUM | $AWK -F '#' '{print $1}')
INUMBER=$(echo $IBASE_NUM | $AWK -F '#' '{print $2}')

# Test to ensure the input base is between 2 and 16

if (( IBASE < 2 || IBASE > 16 ))
then
    echo -e "\nERROR: Input base must be between 2 and 16\n"
    exit 1
fi

# The bc utility requires all number bases greater
# than 10 use uppercase characters for all 
# non-numeric character numbers, i.e. hex numbers.
# We use the tr command to upcase all lowercase
# characters.

if (( IBASE > 10 ))
then
    INUMBER=$(echo $INUMBER | tr '[a-z]' '[A-Z]')
fi

# Ask the user for the output base

echo -e "\nWhat base do you want to convert $IBASE_NUM to?
NOTE: base 2 through 16 are valid\n"
echo -e "Output base: \c"
read OBASE

# Test to ensure the output base is an integer

case $OBASE in
  [0-9]*) : # do nothing
          ;;
       *) echo -e "\nERROR: $obase is not a valid number\n"
          exit 1
          ;;
esac

# Test to ensure the output base is between 2 and 16

if (( OBASE < 2 || OBASE > 16 ))
then
    echo -e "\nERROR: Output base must be between 2 and 16\n"
    exit 1
fi

# Save the input number before changing the base

IN_BASE_NUM=$IBASE_NUM

# Convert the input number to decimal

DEC_EQUIV=$(echo "ibase=$IBASE; $INUMBER" | bc)

# Convert the number to the desired output base

RESULT=$(echo "obase=$OBASE; $DEC_EQUIV" | bc)

# Display the result

echo -e "\nInput number $IN_BASE_NUM is equivalent to \
${OBASE}#${RESULT}\n"

