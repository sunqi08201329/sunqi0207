#!/usr/bin/ksh
#
# SCRIPT: hgrep.ksh
# AUTHOR: Randy Michael
# DATE: 03/09/2001
# REV 2.1.P
# 
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This script is used to highlight text in a file.  Given a text
#	string and a file the script will search the file for the specified
#	string and highlight each occurrence of the string by paging
#	a temporary file which has the string text highlighted.
#
# REV LIST:
#
# set -x        # Uncomment to debug
# set -n        # Uncomment to check command syntax without execution
#
# EXIT CODES:
#
#       0 ==> Script exited normally
#       1 ==> Usage error
#       2 ==> Input File Error
#	3 ==> Pattern not found in the file
#
# REV LIST:
#		03/12/2001 - Randy Michael - Sr. Sys. Admin.
#		Added code to just exit if the string is not in
#		the target file.
#
#		03/13/2001 - Randy Michael - Sr. Sys. Admin.
#		Added code to ensure the target file is a readable "regular"
#		non-zero file.
#
#		03/13/2001 - Randy Michael - Sr. Sys. Admin.
#		Added code to highlight the text string and filename 
#		in the error and information messages.
#
#               08-22-2001 - Randy Michael - Sr. Sys. Admin
#               Changed the code to allow this script to accept standard
#               input from a pipe.  This makes the script work more like the
#               grep command

SCRIPT_NAME=`basename $0`

##############################################
########### DEFINE FUNCTIONS HERE ############
##############################################

function usage
{
        echo "\nUSAGE: $SCRIPT_NAME  pattern  [filename]\n"
}

##############################################
########### CHECK COMMAND SYNTAX #############
##############################################


# Input coming from standard input

if [ $# -eq 1 ] 
then
     # Input coming from standard input

     PATTERN="$1" # Pattern to highlight
     FILENAME=    # Assign NULL to FILENAME

elif [ $# -eq 2 ]
then
     # Input coming from $FILENAME file

     PATTERN="$1"  # Pattern to highlight
     FILENAME="$2" # File to use as input

     # Does the file exist as a "regular" file?

     if [ ! -f $FILENAME ]
     then
        echo "\nERROR: $FILENAME does not exist...\n"
        usage
        exit 2
     fi

     # Is the file empty?

     if [ ! -s $FILENAME ]
     then
        echo "\nERROR: \c"
        tput smso
        echo "$FILENAME\c"
        tput sgr0
        echo " file size is zero...nothing to search\n"
        usage
        exit 2
     fi

     # Is the file readable by this script?

     if [ ! -r $FILENAME ]
     then
        echo "\nERROR: \c"
        tput smso
        echo "${FILENAME}\c"
        tput sgr0
        echo " is not readable to this program...\n"
        usage
        exit 2
     fi

     # Is the pattern anywhere in the file?

     grep "$PATTERN" $FILENAME >/dev/null 2>&1
     if [ $? -ne 0 ]
     then
        echo "\nSORRY: The string \c"
        tput smso
        echo "${PATTERN}\c"
        tput sgr0
        echo " was not found in \c"
        tput smso
        echo "${FILENAME}\c"
        tput sgr0
        echo "\n\n....EXITING...\n"
        exit 3
     fi
else
     # Incorrect number of command line arguments

     usage
     exit 1
fi

##############################################
########### DEFINE VARIABLES HERE ############
##############################################

OUTPUT_FILE="/tmp/highlightfile.out"
>$OUTPUT_FILE

##############################################
############ START OF MAIN ###################
##############################################

# There is no $FILENAME if we get input from a pipe...

if [[ ! -z "$FILENAME" && $FILENAME != '' ]]
then
     # Using $FILENAME as input

     cat "$FILENAME" \
     | sed s/"${PATTERN}"/$(tput smso)"${PATTERN}"$(tput sgr0)/g \
       > $OUTPUT_FILE
else
     # Input is from standard input...

     sed s/"${PATTERN}"/$(tput smso)"${PATTERN}"$(tput sgr0)/g \
         > $OUTPUT_FILE

     # Is the pattern anywhere in the file?

     grep "$PATTERN" $OUTPUT_FILE >/dev/null 2>&1
     if [ $? -ne 0 ]
     then
        echo "\nSORRY: The string \c"
        tput smso
        echo "${PATTERN}\c"
        tput sgr0
        echo " was not found in standard input\c"
        echo "\n\n....EXITING...\n"
        exit 3
     fi

fi

# Check the operating system, on AIX and HP-UX we need to
# use the "pg", or "page" command.  The "more" command does
# not work to highlight the text, it will only show the
# characters that make up the escape sequence.  All
# other operating system usr the "more" command.

case $(uname) in
AIX|HP-UX)

     # This is a fancy "pg" command.  It acts similar to the
     # "more" command but instead of showing the percentage
     # displayed it shows the page number of the file

     cat $OUTPUT_FILE | pg -csn -p"Page %d:"
   ;;
*)
     cat $OUTPUT_FILE | more
   ;;
esac
