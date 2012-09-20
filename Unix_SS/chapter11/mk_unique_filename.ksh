#!/usr/bin/ksh
#
# AUTHOR: Randy Micahel
# SCRIPT: mk_unique_filename.ksh
# DATE: 11/12/2007
# REV: 1.2.P
#
# PLATFORM: Not Platform Dependent
#
# EXIT CODES:
#               0 - Normal script execution
#               1 - Usage error
#
# REV LIST:
#
#
# set -x # Uncomment to debug
# set -n # Uncomment to debug without any execution
#
####################################################
########## DEFINE FUNCTIONS HERE ###################
####################################################

function usage
{
echo "\nUSAGE: $SCRIPT_NAME base_file_name\n"
}

####################################################

function get_date_time_stamp
{
DATE_STAMP=$(date +'%m%d%y.%H%M%S')
echo $DATE_STAMP
}

####################################################

function get_second
{
THIS_SECOND=$(date +%S)
echo $THIS_SECOND
}

####################################################

function in_range_fixed_length_random_number_typeset
{
# Create a pseudo-random number less than or equal
# to the $UPPER_LIMIT value, which is user defined.
# This function will also pad the output with leading
# zeros to keep the number of digits consistent using
# the typeset command.

# Find the length of each character string

UL_LENGTH=$(echo ${#UPPER_LIMIT})

# Fix the length of the RANDOM_NUMBER variable to
# the length of the UPPER_LIMIT variable, specified
# by the $UL_LENGTH variable.

typeset -Z$UL_LENGTH RANDOM_NUMBER

# Create a fixed length pseudo-random number

RANDOM_NUMBER=$(($RANDOM % $UPPER_LIMIT + 1))

# Return the value of the fixed length $RANDOM_NUMBER

echo $RANDOM_NUMBER
}

####################################################

function my_program
{
# Put anything you want to process in this function. I
# recommend that you specify an external program of shell
# script to execute.

echo "HELLO WORLD - $DATE_ST" > $UNIQUE_FN &

#    :  # No-Op - Does nothing but has a return code of zero
}

####################################################
################ BEGINNING OF MAIN #################
####################################################

SCRIPT_NAME=$(basename $0) # Query the system for this script name

# Check for the correct number of arguments - exactly 1

if (( $# != 1 ))
then
      echo "\nERROR: Usage error...EXITING..."
      usage
      exit 1
fi

# What filename do we need to make unique?

BASE_FN=$1    # Get the BASE filenaname to make unique

RANDOM=$$      # Initialize the RANDOM environment variable
               # with the current process ID (PID)

UPPER_LIMIT=32767 # Set the UPPER_LIMIT

CURRENT_SECOND=99 # Initialize to a non-second
LAST_SECOND=98    # Initialize to a non-second

USED_NUMBERS=     # Initialize to null

PROCESSING="TRUE" # Initialize to run mode

while [[ $PROCESSING = "TRUE" ]]
do
     DATE_ST=$(get_date_time_stamp) # Get the current date/time
     CURRENT_SECOND=$(get_second)   # Get the current second

     RN=$(in_range_fixed_length_random_number_typeset) # Get a new number

     # Check to see if we have already used this number this second

     if (( CURRENT_SECOND == LAST_SECOND ))
     then
          UNIQUE=FALSE # Initialize to FALSE
          while [[ "$UNIQUE" != "TRUE" ]] && [[ ! -z $UNIQUE ]]
          do
             # Has this number already been used this second?
             echo $USED_NUMBERS | grep $RN >/dev/null 2>&1
             if (( $? == 0 ))
             then
                 # Has been used...Get another number
                 RN=$(in_range_fixed_length_random_number_typeset)
             else
                 # Number is unique this second...
                 UNIQUE=TRUE
                 # Add this numner to the used number list
                 USED_NUMBERS="$USED_NUMBERS $RN"
             fi
          done
     else
          USED_NUMBERS=   # New second...Reinitialize to null
     fi
     # Assign the unique filename to the UNIQUE_FN variable

     UNIQUE_FN=${BASE_FN}.${DATE_ST}.$RN

     echo $UNIQUE_FN # Comment out this line!!

     LAST_SECOND=$CURRENT_SECOND # Save the last second value

     # We have a unique filename...
     #
     # PROCESS SOMETHING HERE AND REDIRECT OUTPUT TO $UNIQUE_FN
     #
     my_program
     #
     # IF PROCESSING IS FINISHED ASSIGN "FALSE" to the PROCESSING VARIABLE
     #
     # if [[ $MY_PROCESS = "done" ]]
     # then
     #      PROCESSING="FALSE"
     # fi
done
