#!/bin/ksh
#
# SCRIPT: put_ftp_files_pw_var.ksh
# AUTHOR: Randy Michael
# DATE: July 15, 2007 
# REV: 1.1.P
#
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This shell script uses FTP to put a list of one or more
#          local files to a remote machine. This shell script uses
#          remotely defined password variables
#
# set -n # Uncomment to check the script syntax without any execution
# set -x # Uncomment to debug this shell script
#
###################################################################
################## DEFINE VARIABLES HERE ##########################
###################################################################

LOCALFILES=$1

THISSCRIPT=$(basename $0)
RNODE="wilma"
USER="randy"
LOCALDIR="/scripts"
REMOTEDIR="/scripts/download"

# Set up the correct echo command usage. Many Linux
# distributions will execute in Bash even if the
# script specifies Korn shell. Bash shell requires
# we use echo -e when we use \n, \c, etc.

case $SHELL in
*/bin/bash) alias echo="echo -e"
            ;;
esac

###################################################################
################## DEFINE FUNCTIONS HERE ##########################
###################################################################

pre_event ()
{
# Add anything that you want to execute in this function. You can
# hardcode the tasks in this function or create an external shell
# script and execute the external function here.

:  # No-Op: The colon (:) is a No-Op character. It does nothing and
   # always produces a 0, zero, return code.
}

###################################################################

post_event ()
{
# Add anything that you want to execute in this function. You can
# hardcode the tasks in this function or create an external shell
# script and execute the external function here.

:  # No-Op: The colon (:) is a No-Op character. It does nothing and
   # always produces a 0, zero, return code.
}

###################################################################

usage ()
{
echo "\nUSAGE: $THISSCRIPT \"One or More Filenames to Download\" \n"
exit 1
}

###################################################################

usage_error ()
{
echo "\nERROR: This shell script requires a list of one or more
       files to download from the remote site.\n"

usage
}

###################################################################
##################### BEGINNING OF MAIN ###########################
###################################################################

# Test to ensure that the file(s) is/are specified in the $1
# command-line argument.

(($# != 1)) && usage_error

# Get a password

. /usr/sbin/setlink.ksh


pre_event

# Connect to the remote site and begin the here document.

ftp -i -v -n $RNODE <<END_FTP

user $USER $RANDY
binary
lcd $LOCALDIR
cd $REMOTEDIR
mput $LOCALFILES
bye

END_FTP

post_event

