#!/usr/bin/ksh
#
# SCRIPT: fs_mon.ksh
# AUTHOR: Randy Michael
# DATE: 08-22-2007
# REV: 2.1.P
# PURPOSE: This script is used to monitor for full filesystems,
#     which is defined as "exceeding" the FSMAX value.
#     A message is displayed for all "full" filesystems.
#
# REV LIST:
#          Randy Michael - 08-27-2007
#          Changed the code to use MB of free space instead of
#          the %Used method.
#
#          Randy Michael - 08-27-2007
#          Added code to allow you to override the set script default
#          for MIN_MB_FREE of FS Space
#
# set -n # Uncomment to check syntax without any execution
# set -x # Uncomment to debug this script
#
##### DEFINE FILES AND VARIABLES HERE ####  

WORKFILE="/tmp/df.work" # Holds filesystem data
>$WORKFILE              # Initialize to empty
OUTFILE="/tmp/df.outfile" # Output display file
>$OUTFILE		# Initialize to empty
EXCEPTIONS="/usr/local/bin/exceptions" # Override data file
DATA_EXCEPTIONS="/tmp/dfdata.out" # Exceptions file w/o # rows
THISHOST=`hostname`	# Hostname of this machine
MIN_MB_FREE="50MB"     # Min. MB of Free FS Space

####### DEFINE FUNCTIONS HERE ########

function check_exceptions
{
# set -x # Uncomment to debug this function

while read FSNAME FSLIMIT
do
    # Do an NFS sanity check
    echo $FSNAME | grep ":" >/dev/null \
         && FSNAME=$(echo $FSNAME | cut -d ":" -f2)
    if [[ ! -z $FSLIMIT && $FSLIMIT != '' ]]
    then
        (( FSLIMIT = $(echo $FSLIMIT | sed s/MB//g) * 1024 ))
        if [[ $FSNAME = $FSMOUNT ]]
        then
            # Get rid of the "MB" if it exists
            FSLIMIT=$(echo $FSLIMIT | sed s/MB//g)
            if (( $FSMB_FREE < $FSLIMIT ))
            then
                return 1 # Found out of limit
            else
                return 2 # Found OK
            fi
        fi
    fi
done < $DATA_EXCEPTIONS # Feed the loop from the bottom!!!

return 3 # Not found in $EXCEPTIONS file
}

######## START OF MAIN #############

if [[ -s $EXCEPTIONS ]]
then
    # Ignore all line beginning with a pound sign, #.
    cat $EXCEPTIONS | grep -v "^#" > $DATA_EXCEPTIONS
fi

# Get the data of interest by stripping out /dev/cd#, 
# /proc rows and keeping columns 1, 4 and 7

df -k | tail +2 | egrep -v '/dev/cd[0-9] | /proc' \
   | awk '{print $1, $3, $7}' > $WORKFILE

# Format Variables for the proper MB value
(( MIN_MB_FREE = $(echo $MIN_MB_FREE | sed s/MB//g) * 1024 ))

# Loop through each line of the file and compare column 2

while read FSDEVICE FSMB_FREE FSMOUNT
do
    if [[ -s $EXCEPTIONS ]]
    then
      check_exceptions
      RC="$?"
      if [ $RC -eq 1 ] # Found out of exceptions limit
      then
          (( FS_FREE_OUT = $FSMB_FREE / 1000 ))
           echo "$FSDEVICE mounted on $FSMOUNT only has ${FS_FREE_OUT}MB Free" \
                >> $OUTFILE
      elif [ $RC -eq 2 ] # Found in exceptions to be OK
      then # Just a sanity check - We really do nothing here...
           # The colon, :, is a NO-OP operator in KSH

          : # No-Op - Do Nothing!

      elif [ $RC -eq 3 ] # Not found in the exceptions file
      then
          FSMB_FREE=$(echo $FSMB_FREE | sed s/MB//g) # Remove the "MB"
          if (( $FSMB_FREE < $MIN_MB_FREE ))
          then
              (( FS_FREE_OUT = $FSMB_FREE / 1000 ))
              echo "$FSDEVICE mounted on $FSMOUNT only has ${FS_FREE_OUT}MB Free" \
                    >> $OUTFILE
          fi
      fi
    else # No Exceptions file use the script default
      FSMB_FREE=$(echo $FSMB_FREE | sed s/MB//g) # Remove the "MB"
      if (( $FSMB_FREE < $MIN_MB_FREE ))
      then
          (( FS_FREE_OUT = $FSMB_FREE / 1000 ))
          echo "$FSDEVICE mounted on $FSMOUNT only has ${FS_FREE_OUT}MB Free" \
                >> $OUTFILE
      fi
    fi
done < $WORKFILE

if [[ -s $OUTFILE ]]
then
      echo "\nFull Filesystem(s) on $THISHOST\n"
      cat $OUTFILE
      print
fi
