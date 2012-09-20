#!/usr/bin/ksh
#
# SCRIPT: fs_mon.ksh
# AUTHOR: Randy Michael
# DATE: 08-22-2007
# REV: 3.1.P
# PURPOSE: This script is used to monitor for full filesystems,
#     which is defined as "exceeding" the FSMAX value.
#     A message is displayed for all "full" filesystems.
#
# PLATFORM: AIX, at least
#
# REV LIST:
#         08-23-2007 - Randy Michael
#         Added code to override the default FSMAX script threshold
#         using an "exceptions" file, defined by the $EXCEPTIONS
#         variable, that list /mount_point and NEW_MAX%
#
#         08-26-2007 - Randy Michael
#         Added code to check both %USED and MB of Free space
#         with auto detection to switch from %USED to MB Free
#         for filesystems of 3GB and greater.
#
# set -n # Uncomment to check syntax without any execution
# set -x # Uncomment to debug this script
#
##### DEFINE FILES AND VARIABLES HERE ####  

typeset -i FSTOTMB

WORKFILE="/tmp/df.work" # Holds filesystem data
>$WORKFILE              # Initialize to empty file
OUTFILE="/tmp/df.outfile" # Output display file
>$OUTFILE		# Initialize to empty file
BINDIR="/usr/local/bin" # Local bin directory
THISHOST=`hostname`	# Hostname of this machine
FSMAX="85%"              # Max. FS percentage value
EXCEPTIONS="${BINDIR}/exceptions" # Overrides $FSMAX

MBSWITCH="1000MB"	# Number of MB to switch from %USED to MB Free
MBTRIGGER="40MB"        # Minimum MB free before trigger


####### DEFINE FUNCTIONS HERE #####

function check_exceptions
{

# set -x # Uncomment to debug this function

# Define a data file

DATA_EXCEPTIONS="/tmp/dfdata.out"

# Ingore any line that begins with a pound sign, #

cat $EXCEPTIONS |  grep -v "^#" > $DATA_EXCEPTIONS

while read FSNAME NEW_MAX # Feeding Ddata from Bottom of Loop!!!
do
        if [[ "$FSNAME" = "$FSMOUNT" ]] # Correct /mount_point?
        then
            if (( $FSTOTMB >= $MBSWITCH ))
            then
                # MB Free Space - Get rid of "MB" if exists!
                NEW_MIN_MB=$(echo $NEW_MAX | sed s/MB//g)
                (( NEW_MIN_MB = $NEW_MIN_MB * 1024000 )) # In bytes

                if (( $FSFREEMB < $NEW_MIN_MB ))
                then
                        return 2 # Found below MB Trigger Level
                else
                        return 3 # Found but OK
                fi
            else
                # Get rid of the % sign, if it exists!
                NEW_MAX=$(echo $NEW_MAX | sed s/\%//g)

                if [ $FSVALUE -gt $NEW_MAX ]
                then #  Over Limit...Return a "0", zero
                        return 0 # FOUND MAX OUT - Return 0
                fi
            fi
        fi

done < $DATA_EXCEPTIONS # Feed from the bottom of the loop!!

return 1 # Not found in File
}

######## START OF MAIN #############

####### FORMAT VARIABLES ###########

# Get rib of the "MB" letters if they exist
MBTRIGGER=$(echo $MBTRIGGER | sed s/MB//g )
MBSWITCH=$(echo $MBSWITCH | sed s/MB//g )

# Get rid of the "%" if it exists
FSMAX=$(echo $FSMAX | sed s/\%//g )

# Get an "actual" value in Mega Bytes
(( MBSWITCH = $MBSWITCH * 1024000 ))
(( MBTRIGGER = $MBTRIGGER * 1024000 ))

####################################
# Get the data of interest by stripping out /dev/cd#, 
# /proc rows and keeping columns 1, 4 and 7

df -k | tail +2 | egrep -v '/dev/cd[0-9] | /proc' \
   | awk '{print $1, $2, $3, $4, $7}' > $WORKFILE

####################################
# Loop through each line of the file and compare column 2

while read FSDEVICE FSTOTKB FSFREEKB FSVALUE FSMOUNT
do
     # Strip out the % sign if it exists
     FSVALUE=$(echo $FSVALUE | sed s/\%//g) # Remove the % sign
     (( FSTOTMB = $FSTOTKB * 1000 ))
     (( FSFREEMB = $FSFREEKB * 1000 ))
     if [[ -s $EXCEPTIONS ]] # Do we have a non-empty file?
     then # Found it!

        # Look for the current $FSMOUNT value in the file
        # using the check_exceptions function defined above.

        check_exceptions
        RC="$?"
        if [ $RC -eq 0 ] # Found it Exceeded by Percentage
        then
            echo "$FSDEVICE mounted on $FSMOUNT is ${FSVALUE}%" \
                  >> $OUTFILE
        elif [ $RC -eq 2 ] # Found it Exceeded by MB Free
        then
             (( FSFREEMB = $FSFREEMB / 1000000 ))
             echo "$FSDEVICE mounted on $FSMOUNT only has ${FSFREEMB}MB Free" \
                   >> $OUTFILE
        elif [ $RC -ne 3 ]
        then
          if (( $FSTOTMB >= $MBSWITCH ))
          then
             if (( $FSFREEMB < $MBTRIGGER )) # Use MB of Free Space?
             then
                (( FSFREEMB = $FSFREEMB / 1000000 ))
                echo "$FSDEVICE mounted on $FSMOUNT only has ${FSFREEMB}MB Free" \
                      >> $OUTFILE
             elif [ $FSVALUE -gt $FSMAX ] # Use Script Default of % Used
             then
                  echo "$FSDEVICE mounted on $FSMOUNT is ${FSVALUE}%" \
                        >> $OUTFILE
             fi
          fi
        fi
     else # No exceptions file use the script default
          if (( $FSTOTMB >= $MBSWITCH ))
          then
             if (( $FSFREEMB < $MBTRIGGER )) 
             then
                (( FSFREEMB = $FSFREEMB / 1000000 ))
                echo "$FSDEVICE mounted on $FSMOUNT only has ${FSFREEMB}MB Free" \
                      >> $OUTFILE
             fi
          else
             if [ $FSVALUE -gt $FSMAX ] # Use Script Default
             then
                  echo "$FSDEVICE mounted on $FSMOUNT is ${FSVALUE}%" \
                        >> $OUTFILE

             fi
          fi
     fi
done < $WORKFILE # Feed the while loop from the bottom...

# Display output if anything is exceeded...

if [[ -s $OUTFILE ]]
then
      echo "\nFull Filesystem(s) on $THISHOST\n"
      cat $OUTFILE
      print
fi
