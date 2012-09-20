#!/bin/ksh
#
# SCRIPT: get_ftp_files.ksh
# AUTHOR: Randy Michael
# DATE: July 15, 2007 
# REV: 1.1.P
#
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This shell script uses FTP to get a one or more remote
#          files from a remote machine.
#
# set -n # Uncomment to check the script syntax without any execution
# set -x # Uncomment to debug this shell script
#
###################################################################
################## DEFINE VARIABLES HERE ##########################
###################################################################

REMOTEFILES=$1

THISSCRIPT=$(basename $0)
RNODE="wilma"
USER="randy"
UPASSWD="mypassword"
LOCALDIR="/scripts/download"
REMOTEDIR="/scripts"

# Set up the correct echo command usage. Many Linux
# distributions will execute in Bash even if the
# script specifies Korn shell. Bash shell requires
# we use echo -e when we use \n, \c, etc.

case $(basename $SHELL) in
bash) alias echo="echo -e"
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

# Test for a single command-line argument. This should contain a list
# of one or more files.

(($# != 1)) && usage_error

pre_event

ftp -i -v -n $RNODE <<END_FTP

user $USER $UPASSWD
binary
lcd $LOCALDIR
cd $REMOTEDIR
mget $REMOTEFILES
bye

END_FTP

post_event

