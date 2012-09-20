#!/bin/ksh
#
# SCRIPT: get_remote_dir_listing.ksh
# AUTHOR: Randy Michael
# DATE: July 15, 2007 
# REV: 1.1.P
#
# PLATFORM: Not Platform Dependent
#
# PURPOSE: This shell script uses FTP to get a remote directory listing
#          and save this list in a local file. This shell script uses
#          remotely defined passwords.
#
# set -n # Uncomment to check the script syntax without any execution
# set -x # Uncomment to debug this shell script
#
###################################################################
################## DEFINE VARIABLES HERE ##########################
###################################################################

RNODE="wilma"
USER="randy"
LOCALDIR="/scripts/download"
REMOTEDIR="/scripts"
DIRLISTFILE="${LOCALDIR}/${RNODE}.$(basename ${REMOTEDIR}).dirlist.out"
cat /dev/null > $DIRLISTFILE

###################################################################
##################### BEGINNING OF MAIN ###########################
###################################################################

# Get a password

. /usr/sbin/setlink.ksh

ftp -i -v -n $RNODE <<END_FTP
user $USER $RANDY
nlist $REMOTEDIR $DIRLISTFILE 
bye

END_FTP

