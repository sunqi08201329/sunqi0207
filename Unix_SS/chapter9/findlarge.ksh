#!/usr/bin/ksh
#
# SCRIPT:findlarge.ksh
#
# AUTHOR: Randy Michael
#
# DATE: 11/30/2007
#
# REV: 1.0.A
#
# PURPOSE: This script is used to search for files which
# are larger than $1 Meg. Bytes.  The search starts at
# the current directory that the user is in, `pwd`, and
# includes files in and below the user's current directory.
# The output is both displayed to the user and stored
# in a file for later review.
#
# REVISION LIST:
#
#
#
# set -x   # Uncomment to debug this script


############################################

function usage
{
echo "\n***************************************"
echo "\n\nUSAGE:    findlarge.ksh  [Number_Of_Meg_Bytes]"
echo "\nEXAMPLE:  filelarge.ksh  5"
echo "\n\nWill Find Files Larger Than 5 Mb in, and Below, the 
Current Directory..."
echo "\n\nEXITING...\n"
echo "\n***************************************"
exit
}

############################################

function cleanup
{
echo "\n********************************************************"
echo "\n\nEXITING ON A TRAPPED SIGNAL..."
echo "\n\n********************************************************\n"
exit
}

############################################

# Set a trap to exit.  REMEMBER - CANNOT TRAP ON kill -9 !!!!

trap 'cleanup' 1 2 3 15

############################################

# Check for the correct number of arguments and a number
# Greater than zero

if [ $# -ne 1 ]
then
        usage
fi

if [ $1 -lt 1 ]
then
	usage
fi

############################################

# Define and initialize files and variables here...

THISHOST=`hostname` 	# Hostname of this machine

DATESTAMP=`date +"%h%d:%Y:%T"`

SEARCH_PATH=`pwd`	# Top level directory to search

MEG_BYTES=$1		# Number of Mb for file size trigger

DATAFILE="/tmp/filesize_datafile.out" # Data storage file
>$DATAFILE		# Initialize to a null file

OUTFILE="/tmp/largefiles.out" # Output user file
>$OUTFILE		# Initialize to a null file

HOLDFILE="/tmp/temp_hold_file.out" # Temporary storage file
>$HOLDFILE		# Initialize to a null file

############################################

# Prepare the output user file

echo "\nSearching for Files Larger Than ${MEG_BYTES}Mb starting in:"
echo "\n==> $SEARCH_PATH"
echo "\nPlease Standby for the Search Results..."
echo "\nLarge Files Search Results:" >> $OUTFILE
echo "\nHostname of Machine: $THISHOST" >> $OUTFILE
echo "\nTop Level Directory of Search:" >> $OUTFILE
echo "==> $SEARCH_PATH" >> $OUTFILE
echo "\nDate/Time of Search: `date`" >> $OUTFILE
echo "\n\nSearch Results Sorted by Time:" >> $OUTFILE

############################################

# Search for files > $MEG_BYTES starting at the $SEARCH_PATH

find $SEARCH_PATH -type f -size +${MEG_BYTES}000000c \
	 -print > $HOLDFILE

# How many files were found?

if [ -s $HOLDFILE ]
then
    NUMBER_OF_FILES=`cat $HOLDFILE | wc -l`

    echo "\nNumber of Files Found: ==> $NUMBER_OF_FILES\n" >> $OUTFILE

    # Append to the end of the Output File...

    ls -lt `cat $HOLDFILE` >> $OUTFILE

    # Display the Time Sorted Output File...

    more $OUTFILE

    echo "\nThese Search Results are Stored in ==> $OUTFILE"
    echo "\nSearch Complete...EXITING...\n\n\n"
else
    cat $OUTFILE
    echo "\nNo Files were Found in the Search Path that"
    echo "are Larger than ${MEG_BYTES}Mb\n"
    echo "\nEXITING...\n\n"
fi
