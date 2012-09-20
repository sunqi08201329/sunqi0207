#!/usr/bin/ksh
#
# SCRIPT: fs_mon_AIX.ksh
# AUTHOR: Randy Michael
# DATE: 08-22-2007
# REV: 1.1.P
# PURPOSE: This script is used to monitor for full filesystems,
#     which is defined as "exceeding" the FSMAX value.
#     A message is displayed for all "full" filesystems.
#
# PLATFORM: AIX
#
# REV LIST: 
#
# set -n # Uncomment to check syntax without any execution
# set -x # Uncomment to debug this script
#
##### DEFINE FILES AND VARIABLES HERE ####  

FSMAX="85"              # Max. FS percentage value

WORKFILE="/tmp/df.work" # Holds filesystem data
>$WORKFILE              # Initialize to empty
OUTFILE="/tmp/df.outfile" # Output display file
>$OUTFILE		# Initialize to empty
THISHOST=`hostname`	# Hostname of this machine

######## START OF MAIN #############

# Get the data of interest by stripping out /dev/cd#, 
# /proc rows and keeping columns 1, 4 and 7

df -k | tail +2 | egrep -v '/dev/cd[0-9]|/proc' \
   | awk '{print $1, $4, $7}' > $WORKFILE

# Loop through each line of the file and compare column 2

while read FSDEVICE FSVALUE FSMOUNT 
do
      FSVALUE=$(echo "$FSVALUE" | sed s/\%//g) # Remove the % sign
      if [ "$FSVALUE" -gt "$FSMAX" ]
      then
          echo "$FSDEVICE mounted on $FSMOUNT is ${FSVALUE}%" \
                >> $OUTFILE
      fi
done < $WORKFILE

if [[ -s $OUTFILE ]]
then
      echo "\nFull Filesystem(s) on $THISHOST\n"
      cat $OUTFILE
      print
fi
