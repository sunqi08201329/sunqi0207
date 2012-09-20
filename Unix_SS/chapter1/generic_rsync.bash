#!/bin/bash
#
# SCRIPT: generic_rsync.bash
# AUTHOR: Randy Michael
# DATE: 11/18/2007
# REV: 1.0
# PURPOSE: This is a generic shell script to copy files
# using rsync.
#
# set -n # Uncomment to check script syntax without execution
# set -x # Uncomment to debug this script
#
# REV LIST:
#
#
##############################################
# DEFINE FILES AND VARIABLES HERE
##############################################

# Define the source and destination files/directories

SOURCE_FL="/scripts/"
DESTIN_FL="booboo:/scripts"

##############################################
# BEGINNING OF MAIN
##############################################

# Start the rsync copy

rsync -avz "$SOURCE_FL" "$DESTIN_FL"

# End of generic_rsync.bash
