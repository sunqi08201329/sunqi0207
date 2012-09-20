#!/bin/ksh
#
# SCRIPT: tst_ftp.ksh
# AUTHOR: Randy Michael
# DATE: 6/12/2007
# REV: 1.1.A
# PLATOFRM: Not platform dependent
#
# PURPOSE: This shell script is a simple demostration of 
#          using a here document in a shell script to automate
#          an FTP file transfer.
#

# Connect to the remote machine and begin a here document.

ftp -i -v -n wilma <<END_FTP

user randy mypassword
binary
lcd /scripts/download
cd /scripts
get auto_ftp_xfer.ksh
bye

END_FTP

