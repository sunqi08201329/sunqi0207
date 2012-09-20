#!/usr/bin/ksh
#
# SCRIPT: equate_any_base.ksh
# AUTHOR: Randy Michael
# DATE: 07/07/2007
# REV: 1.2.P
#
# PURPOSE: This script is used to convert a number to any
#          supported number base, which is at least base 36.
#          This script requires that two command line
#          auguments and the "number" to be converted
#          are present on the command line. An example
#          number base conversion is shown here:
#
#          equate_any_base.ksh -f16 -t2 e245c
#          2#11100010010001011100
#
#          This example converts the base 16 number, e245c, to
#          the base 2 equivalent, 2#11100010010001011100.
#          The 2#, which precedes the binary number, shows 
#          the base of the number represented.
#
# EXIT CODES:
#               0 - Normal script execution
#               1 - Usage error
#
# set -x # Uncomment to debug this shell script
# set -n # Uncomment to check syntax without any execution
#
######################################################
# DEFINE FILES AND VARIABLES HERE 
######################################################

SCRIPT_NAME=$(basename $0)
COUNT=0
MAX_COUNT=$#

# Setup the correct echo command usage. Many Linux 
# distributions will execute in BASH even if the
# script specifies Korn shell. BASH shell requires
# we use echo -e when we use \n, \c, etc.

case $SHELL in
*/bin/bash) alias echo="echo -e"
            ;;
esac

######################################################
# DEFINE FUNCTIONS HERE 
######################################################

function usage
{
echo "\nUSAGE: $SCRIPT_NAME -f{starting base} -t{ending base} NUMBER"
echo "\nEXAMPLE: $SCRIPT_NAME -f16 -t10 FC23"
echo "\nWill return the decimal base 10 number 64547"
echo "\t ...EXITING...\n"
}

######################################################
# CHECK COMMAND LINE AUGUMENTS HERE 
######################################################

# The maximum number of command line arguments is five
# and the minimum number is three.

if (($# > 5))
then
     echo "\nERROR: Too many command line arguments\n"
     usage
     exit 1
elif (($# < 3))
then
     echo "\nERROR: Too few command-line arguments\n"
     usage
     exit 1
fi

# Check to see if the command-line switches are present

echo $* | grep -q '\-f' || (usage; exit 1)
echo $* | grep -q '\-t' || (usage; exit 1)

# Use getopts to parse the command line arguments

while getopts ":f:t:" ARGUMENT
do
  case $ARGUMENT in
     f) START_BASE="$OPTARG"
        ;;
     t) END_BASE="$OPTARG"
        ;;
    \?) usage
        exit 1
        ;;
  esac
done

# Ensure that the START_BASE and END_BASE variables
# are not NULL.

if [ -z "$START_BASE" ] || [ "$START_BASE" = '' ] \
   || [ -z "$END_BASE" ] || [ "$END_BASE" = '' ]
then
     echo "\nERROR: Base number conversion fields are empty\n"
     usage
     exit 1
fi

# Ensure that the START_BASE and END_BASE variables
# have integer values for the number base conversion.

case $START_BASE in
+([0-9])) : # Do nothing - Colon is a no-op.
          ;;
       *) echo "\nERROR: $START_BASE is not an integer value"
          usage
          exit 1
          ;;
esac

case $END_BASE in
+([0-9])) : # Do nothing - Colon is a no-op.
          ;;
       *) echo "\nERROR: $END_BASE is not an integer value"
          usage
          exit 1
          ;;
esac

######################################################
# BEGINNING OF MAIN 
######################################################

# Begin by finding the BASE_NUM to be converted.

# Count from 1 to the max number of command line auguments

while ((COUNT  < MAX_COUNT))
do
   ((COUNT == COUNT + 1))
   TOKEN=$1
   case $TOKEN in
   -f) shift; shift
       ((COUNT == COUNT + 1))
       ;;
   -f${START_BASE}) shift
       ;;
   -t) shift; shift
      ((COUNT == COUNT + 1))
       ;;
   -t${END_BASE}) shift
       ;;
   *) BASE_NUM=$TOKEN
      break
      ;;
   esac
done

# Typeset the RESULT variable to the target number base

typeset -i$END_BASE RESULT

# Assign the BASE_NUM variable to the RESULT variable
# and add the starting number base with a pound sign (#)
# as a prefix for the conversion to take place.
# NOTE: If an invalid number is entered a system error
# will be displayed. An example is inputting 1114400 as
# a binary number, which is invalid for a binary number.

RESULT="${START_BASE}#${BASE_NUM}"

# Display the result to the user or calling program.

echo "$RESULT"

# End of script...
