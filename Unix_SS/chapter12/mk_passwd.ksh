#!/bin/ksh
#
# AUTHOR: Randy Micahel
# SCRIPT: mk_passwd.ksh
# DATE: 11/12/2007
# REV: 2.5.P
#
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This script is used to create pseudo-random passwords.
#          An extrernal keyboard data file is utilized, which is 
#          defined by the KEYBOARD_FILE variable. This keyboard
#          file is expected to have one character on each line.
#          These characters are loaded into an array, and using
#          pseudo-random numbers generated, the characters are
#          "randomly" put together to form a string of characters.
#          By default, this script produces 8 character passwords,
#          but this length can be changed on the command line by
#          adding an integer value after the script name. There are
#          two command line options, -n, which creates the default
#          KEYBOARD_FILE, and -m, which prints the manager's 
#          password report. This password report is intended 
#          to be lock in a safe for safe keeping.
#
# EXIT CODES:
#               0 - Normal script execution
#               1 - Usage error
#               2 - Trap exit
#               3 - Missing Keyboard data file
#               4 - $DEFAULT_PRINTER is NULL
#               5 - /dev/urandom file does not exist
#
# REV LIST:
#          6/26/2007: Added two command line options, -n, which 
#          creates a new $KEYBOARD_FILE, and -m, which prints 
#          the managers password report.
#
#          8/8/2007: Changed the random number method from the
#          shell RANDOM variable to now use the /dev/urandom
#          character special file in concert with dd and od.
#
# set -x # Uncomment to debug
# set -n # Uncomment to check syntax without any command execution
#
####################################################
########### DEFINE SOME VARIABLES HERE #############
####################################################

LENGTH=8 # Default Password Length

# Notification List for Printing the Manager's
# Password Report for Locking Away Passwords
# Just in Case You are Unavaliable.

NOTIFICATION_LIST="Donald Duck, Yogi Bear, and Mr. Ranger"

# Define the Default Printer for Printing the Manager's 
# Password Report. The user has a chance to change this 
# printer at execution time.

DEFAULT_PRINTER="hp4@yogi"

SCRIPT=$(basename $0)

OUTFILE="/tmp/tmppdw.file"

KEYBOARD_FILE=/scripts/keyboard.keys

PRINT_PASSWORD_MANAGER_REPORT="TO_BE_SET"

# This next test ensures we use the correct
# echo command based on the executing shell

ECHO="echo -e"
[[ $(basename $SHELL) = ksh ]] && ECHO=echo

####################################################
########## DEFINE FUNCTIONS HERE ###################
####################################################
#
function in_range_random_number
{
# Create a pseudo-random number less than or equal
# to the $UPPER_LIMIT value, which is defined in the
# main body of the shell script.

RN=$(dd if=/dev/urandom count=1 2>/dev/null \
    | od -t u2 | awk '{print $2}'| head -n 1)

RANDOM_NUMBER=$(( RN % UPPER_LIMIT + 1))

echo "$RANDOM_NUMBER"
}
#
####################################################
#
function load_default_keyboard
{
# If a keyboard data file does not exist then the user
# prompted to load the standard keyboard data into the 
# $KEYBOARD_FILE, which is defined in the main body of
# the shell script.

clear  # Clear the screen

$ECHO "\nLoad the default keyboard data file? (Y/N): \c"
read REPLY

case $REPLY in
y|Y) :
     ;;
  *) $ECHO "\nSkipping the load of the default keyboard file...\n"
     return
     ;;
esac

cat /dev/null > $KEYBOARD_FILE

$ECHO "\nLoading the Standard Keyboard File...\c"

# Loop through each character in the following list and
# append each character to the $KEYBOARD_FILE file. This
# produces a file with one character on each line.

for CHAR in \` 1 2 3 4 5 6 7 8 9 0 - = \\ q w e r t y u i o \
             p \[ \] a s d f g h j k l \; \' z x c v b n m \, \
             \. \/ \\ \~ \! \@ \# \$ \% \^ \& \* \( \) _ \+ \| \
             Q W E R T Y U I O P \{ \} A S D F G H J K L \: \" \
             Z X C V B N M \< \> \? \| \. 0 1 2 3 4 5 6 7 8 9 \/ \
             \* \- \+
do
     $ECHO "$CHAR" >> $KEYBOARD_FILE
done
$ECHO "\n\n\t...Done...\n"

sleep 1
}
#
####################################################
#
function check_for_and_create_keyboard_file
{
# If the $KEYBOARD_FILE does not exist then
# ask the user to load the "standard" keyboard
# layout, which is done with the load_default_keyboard
# function.

if [ ! -s $KEYBOARD_FILE ]
then
     $ECHO "\n\nERROR: Missing Keyboard File"
     $ECHO "\n\nWould You Like to Load the"
     $ECHO "Default Keyboard Layout?"
     $ECHO "\n\t(Y/N): \c"
     typeset -u REPLY=FALSE
     read REPLY
     if [ $REPLY != Y ]
     then
          $ECHO "\n\nERROR: This shell script cannot operate"
          $ECHO "without a keyboard data file located in"
          $ECHO "\n==>  $KEYBOARD_FILE\n"
          $ECHO "\nThis file expects one character per line."
          $ECHO "\n\t...EXITING...\n"
          exit 3
     else
          load_default_keyboard
          $ECHO "\nPress ENTER when you are you ready to continue: \c"
          read REPLY
          clear
     fi
fi
}
#
####################################################
#
function build_manager_password_report
{
# Build a file to print for the secure envelope
(
$ECHO "\n                RESTRICTED USE!!!"
$ECHO "\n\n\tImmediately send an e-mail to:\n"

$ECHO "    $NOTIFICATION_LIST"

$ECHO "\n\tif this password is revealed!"
$ECHO "\n\tAIX root password:  $PW\n"

$ECHO "\n\n"

$ECHO "\n                RESTRICTED USE!!!"
$ECHO "\n\n\tImmediately send an e-mail to:\n"

$ECHO "    $NOTIFICATION_LIST"

$ECHO "\n\tif this password is revealed!"
$ECHO "\n\tAIX root password:  $PW\n"

$ECHO "\n\n"

$ECHO "\n                RESTRICTED USE!!!"
$ECHO "\n\n\tImmediately send an e-mail to:\n"

$ECHO "    $NOTIFICATION_LIST"

$ECHO "\n\tif this password is revealed!"
$ECHO "\n\tAIX root password:  $PW\n"

    ) > $OUTFILE

}
#
####################################################
#
function usage
{
$ECHO "\nUSAGE: $SCRIPT [-m] [-n]  [password_length]\n"
$ECHO "   Where:

     -m  Creates a password printout for Security

     -n  Loads the default keyboard data keys file

     password_length - Interger value that overrides
                       the default 8 character
                       password length.\n"
}
#
####################################################
#
function trap_exit
{
rm -f $OUTFILE >/dev/null 2>&1
}

####################################################
########## END OF FUNCTION DEFINITIONS #############
####################################################

####################################################
########## ENSURE /dev/urandom EXISTS ##############
####################################################

if ! [ -c /dev/urandom ]
then
    echo "\nERROR: This version of $(uname) does not have a /dev/urandom
character special file. This script requires this file to create 
pseudo random numbers."
    echo "\n...EXITING...\n"
    usage
    exit 5
fi

####################################################
####### VALIDATE EACH COMMAND LINE ARGUMENT ########
####################################################
 
# Check command line arguments - $# < 3

if (($# > 3))
then
     usage
     exit 1
fi

####################################################
#
# Test for valid command line arguments - 
# Valid auguments are "-n, -N, -m, -M, and any integer

if (($# != 0))
then
   for CMD_ARG in $@
   do
         case $CMD_ARG in
         +([-0-9]))
               # The '+([-0-9]))' test notation is looking for
               # an integer. Any integer is assigned to the
               # length of password variable, LENGTH

               LENGTH=$CMD_ARG
               ;;
         -n) :
               ;;
         -N)  : 
               ;;
         -m)  :
               ;;
         -M)  :
               ;;
         *)
               usage
               exit 1
               ;;
         esac
   done
fi

####################################################
#
# Ensure that the $LENGTH variable is an integer

case $LENGTH in
+([0-9])) : # The '+([-0]))' test notation is looking for
            # an integer. If an integer then the
            # No-Op, specified by a colon, (Do Nothina)i
            # command is executed, otherwise this script
            # exits with a return code of 1, one.
          ;;
*) usage
   exit 1
   ;;
esac

####################################################
#
# Use the getopts function to parse the command
# line arguments. 

while getopts ":nNmM" ARGUMENT 2>/dev/null
do
     case $ARGUMENT in
     n|N)
         # Create a new Keyboard Data file
         load_default_keyboard
         $ECHO "\nPress ENTER when you are you ready to continue: \c"
         read REPLY
         clear
         ;;
     m|M)
         # Print the Manager Password Report
         PRINT_PASSWORD_MANAGER_REPORT=TRUE
         ;;
     \?) # Show the usage message
         usage
         exit 1
     esac 
done

####################################################
################ START OF MAIN #####################
####################################################

# Set a trap

trap 'trap_exit;exit 2' 1 2 3 15

####################################################
#
# Check for a keyboard data file

check_for_and_create_keyboard_file

####################################################
############### LOAD THE ARRAY #####################
####################################################

X=0 # Initialize the array counter to zero

# Load the array called "KEYS" with keyboard elements
# located in the $KEYBOARD_FILE.

while read ARRAY_ELEMENT
do
     ((X = X + 1)) # Increment the counter by 1

     # Load an array element in the the array

     KEYS[$X]=$ARRAY_ELEMENT

done < $KEYBOARD_FILE


UPPER_LIMIT=$X  # Random Number Upper Limit

####################################################
#
# Create the pseudo-random password in this section



clear   # Clear the screen

PW=     # Initialize the password to NULL

# Build the password using random numbers to grab array
# elements from the KEYS array.

X=0
while ((X < LENGTH))
do
    # Increment the password length counter
    (( X = X + 1 ))

    # Build the password one char at a time in this loop
    PW=${PW}${KEYS[$(in_range_random_number $UPPER_LIMIT)]}
done

# Done building the password

####################################################
#
# Display the new pseudo-random password to the screen

$ECHO "\n\n     The new $LENGTH character password is:\n"
$ECHO "\n          ${PW}\n"

####################################################
#
# Print the Manager's password report, if specified
# on the command with the -m command switch.

if [ $PRINT_PASSWORD_MANAGER_REPORT = TRUE ]
then

  typeset -u REPLY=N

  $ECHO "\nPrint Password Sheet for the Secure Envelope? (Y/N)? \c"
  read REPLY

  if [[ $REPLY = 'Y' ]]
  then
     build_manager_password_report

     REPLY=    # Set REPLY to NULL

     $ECHO "\nPrint to the Default Printer ${DEFAULT_PRINTER} (Y/N)? \c"
     read REPLY
     if [[ $REPLY = 'Y' ]]
     then
          $ECHO "\nPrinting to $DEFAULT_PRINTER\n"
          lp -c -d $DEFAULT_PRINTER $OUTFILE
          
     else
          $ECHO "\nNEW PRINT QUEUE: \c"
          read DEFAULT_PRINTER 
          if [ -z "$DEFAULT_PRINTER" ]
          then
              echo "ERROR: Default printer canot be NULL...Exiting..."
              exit 5
          fi
          $ECHO "\nPrinting to $DEFAULT_PRINTER\n"
          lp -c -d $DEFAULT_PRINTER $OUTFILE
     fi
  else
     $ECHO "\n\n\tO.K. - Printing Skipped..."
  fi
fi

####################################################
#
# Remove the $OUTFILE, if it exists and has a size
# greater than zero bytes.

[ -s $OUTFILE ] && rm $OUTFILE

####################################################
#
# Clear the screen and exit

$ECHO "\n\nPress ENTER to Clear the Screen and EXIT: \c"
read X
clear

# End of mk_passwd.ksh shell script
