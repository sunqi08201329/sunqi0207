#!/bin/bash
#
# SCRIPT: sftp-scp-getfile.bash
# AUTHOR: Randy Michael
# DATE: 11/15/2007
# REV: 1.0
#
# PURPOSE: This is a simple script to show how
# Secure FTP and Secure Copy work with and
# without passwords. This is done by removing
# and adding the remote host's key in the local
# $HOME/.ssh/known_hosts file.
#
####################################
# DEFINE FILES AND VARIABLES HERE
####################################

COPYMGR=ftpadmin
REM_MACHINE=booboo
REM_FILE=/home/ftpadmin/getall.sh
LOC_FILE=$HOME # Use the same filename but
               # store the file in $COPYMGR
               # $HOME directory.

####################################
# BEGINNING OF MAIN
####################################

echo -e "\nSecure FTP Method\n"

sftp ${COPYMGR}@${REM_MACHINE}:$REM_FILE $LOC_FILE

echo -e "\nSecure Copy Method\n" 

scp ${COPYMGR}@${REM_MACHINE}:$REM_FILE $LOC_FILE

echo -n

