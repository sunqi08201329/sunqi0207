#!/bin/bash
#
# SCRIPT: random_file.bash
# AUTHOR: Randy Michael
# DATE: 8/3/2007
# REV: 1.0
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This script is used to create a
#      specific size file of random characters.
#      The methods used in this script include
#      loading an array with alphanumeric 
#      characters, then using the /dev/random 
#      character special file to seed the RANDOM
#      shell variable, which in turn is used to 
#      extract a random set of characters from the
#      KEYS array to build the OUTFILE of a 
#      specified MB size.
#      
# set -x # Uncomment to debug this script
#
# set -n # Uncomment to check script syntax
#        # without aby execution. Do not forget
#        # to put the comment back in or the
#        # script will never execute.
#
##########################################
# DEFINE FILES AND VARIABLES HERE
##########################################

typeset -i MB_SIZE=$1
typeset -i RN
typeset -i i=1
typeset -i X=0
WORKDIR=/scripts
OUTFILE=${WORKDIR}/largefile.random.txt
>$OUTFILE
THIS_SCRIPT=$(basename $0)
CHAR_FILE=${WORKDIR}/char_file.txt

##########################################
# DEFINE FUNCTIONS HERE
##########################################

build_random_line ()
{
# This function extracts random characters
# from the KEYS array by using the RANDOM
# shell variable

C=1
LINE=
until (( C > 79 ))
do
   LINE="${LINE}${KEYS[$(($RANDOM % X + 1))]}"
   (( C = C + 1 ))
done

# Return the line of random characters

echo "$LINE"
}

##########################################

elasped_time ()
{
SEC=$1

(( SEC < 60 )) && echo -e "[Elasped time: \
$SEC seconds]\c"

(( SEC >= 60  &&  SEC < 3600 )) && echo -e \
"[Elasped time: $(( SEC / 60 )) min $(( SEC % 60 )) sec]\c"

(( SEC > 3600 )) && echo -e "[Elasped time: \
$(( SEC / 3600 )) hr $(( (SEC % 3600) / 60 )) min \
$(( (SEC % 3600) % 60 )) sec]\c"
}

##########################################

load_default_keyboard ()
{
# Loop through each character in the following list and
# append each character to the $CHAR_FILE file. This
# produces a file with one character on each line.

for CHAR in 1 2 3 4 5 6 7 8 9 0 q w e r t y u i o \
             p a s d f g h j k l  z x c v b n m \
             Q W E R T Y U I O P A S D F G H J K L \
             Z X C V B N M 0 1 2 3 4 5 6 7 8 9  
do
     echo "$CHAR" >> $CHAR_FILE
done
}
##########################################

usage ()
{
echo -e "\nUSAGE: $THIS_SCRIPT Mb_size"
echo -e "Where Mb_size is the size of the file to build\n"
}
 
##########################################
# BEGINNING OF MAIN
##########################################

if (( $# != 1 ))
then
     usage
     exit 1
fi

# Test for an integer value

case $MB_SIZE in
[0-9]) : # Do nothing
          ;;
       *) usage
          ;;
esac

# Test for the $CHAR_FILE

if [ ! -s "$CHAR_FILE" ]
then
     echo -e "\nNOTE: $CHAR_FILE does not esist"
     echo "Loading default keyboard data."
     echo -e "Creating $CHAR_FILE...\c"
     load_default_keyboard
     echo "Done"
fi

# Load Character Array

echo -e "\nLoading array with alphanumeric character elements"

while read ARRAY_ELEMENT
do
    (( X = X + 1 ))
    KEYS[$X]=$ARRAY_ELEMENT

done < $CHAR_FILE

echo "Total Array Character Elements: $X"

# Use /dev/random to seed the shell variable RANDOM

echo "Querying the kernel random number generator for a random seed"

RN=$(dd if=/dev/random count=1 2>/dev/null \
    | od -t u4 | awk '{print $2}'| head -n 1)

# The shell variable RANDOM is limited to 32767

echo "Reducing the random seed value to between 1 and 32767"

RN=$(( RN % 32767 + 1 ))

# Initialize RANDOM with a new seed

echo "Assigning a new seed to the RANDOM shell variable"

RANDOM=$RN

echo "Building a $MB_SIZE MB random character file ==> $OUTFILE"
echo "Please be patient, this may take some time to complete..."
echo -e "Executing: .\c"

# Reset the shell SECONDS variable to zero seconds.

SECONDS=0

TOT_LINES=$(( MB_SIZE * 12800 ))

until (( i > TOT_LINES ))
do
     build_random_line >> $OUTFILE
     (( $(( i % 100 )) == 0 )) && echo -e ".\c"
     (( i = i + 1 ))
done

# Capture the total seconds

TOT_SEC=$SECONDS

echo -e "\n\nSUCCESS: $OUTFILE created at $MB_SIZE MB\n"

elasped_time $TOT_SEC

# Calculate the bytes/second file creation rate

(( MB_SEC = ( MB_SIZE * 1024000 ) / TOT_SEC ))

echo -e "\n\nFile Creation Rate: $MB_SEC bytes/second\n"

echo -e "File size:\n"
ls -l $OUTFILE
echo

##########################################
# END OF random_file.bash SCRIPT
##########################################
