#!/usr/bin/ksh
#
# SCRIPT: fs_mon_AIX_excep.ksh
# AUTHOR: Randy Michael
# DATE: 08-22-2007
# REV: 2.1.P
# 
# PURPOSE: This script is used to monitor for full filesystems,
#     which is defined as "exceeding" the FSMAX value.
#     A message is displayed for all "full" filesystems.
#
# PLATFORM: AIX
#
# REV LIST:
#         08-23-2007 - Randy Michael
#         Added code to override the default FSMAX script threshold
#         using an "exceptions" file, defined by the $EXCEPTIONS
#         variable, that list /mount_point and NEW_MAX%
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
BINDIR="/usr/local/bin" # Local bin directory
THISHOST=`hostname`	# Hostname of this machine

EXCEPTIONS="${BINDIR}/exceptions" # Overrides $FSMAX
DATA_EXCEPTIONS="/tmp/dfdata.out" # Exceptions file w/o #, comments

####### DEFINE FUNCTIONS HERE #####

function load_EXCEPTIONS_file
{
# Ignore any line that begins with a pound sign, #
# and omit all blank lines

cat $EXCEPTIONS | grep -v "^#" | sed /^$/d > $DATA_EXCEPTIONS
}

###################################

function check_exceptions
{
# set -x # Uncomment to debug this function

while read FSNAME NEW_MAX # Feeding Ddata from Bottom of Loop!!!
do
        if [[ $FSNAME = $FSMOUNT ]] # Correct /mount_point?
        then    # Get rid of the % sign, if it exists!
                NEW_MAX=$(echo $NEW_MAX | sed s/\%//g)

                if [ $FSVALUE -gt $NEW_MAX ]
                then  # Over Limit...Return a "0", zero
                    return 0 # FOUND MAX OUT - Return 0
                fi
        fi

done < $DATA_EXCEPTIONS # Feed from the bottom of the loop!!

return 1 # Not found in File
}

####################################
######## START OF MAIN #############
####################################

# If there is an exceptions file...load it...

[[ -s $EXCEPTIONS ]] && load_EXCEPTIONS_file

# Get the data of interest by stripping out /dev/cd#, 
# /proc rows and keeping columns 1, 4 and 7

df -k | tail +2 | egrep -v '/dev/cd[0-9]|/proc' \
   | awk '{print $1, $4, $7}' > $WORKFILE

# Loop through each line of the file and compare column 2

while read FSDEVICE FSVALUE FSMOUNT
do   # Feeding the while loop from the BOTTOM!!
     
     # Strip out the % sign if it exists
     FSVALUE=$(echo $FSVALUE | sed s/\%//g) # Remove the % sign
     if [[ -s $EXCEPTIONS ]] # Do we have a non-empty file?
     then # Found it!

        # Look for the current $FSMOUNT value in the file
        # using the check_exceptions function defined above.

        check_exceptions
        RC=$? # Get the return code from the function
        if [ $RC -eq 0 ] # Found Exceeded in Exceptions File!!
        then
            echo "$FSDEVICE mount on $FSMOUNT is ${FSVALUE}%" \
                  >> $OUTFILE
        elif [ $RC -eq 1 ] # Not found in exceptions, use defaults
        then
            if [ $FSVALUE -gt $FSMAX ] # Use Script Default
            then
                echo "$FSDEVICE mount on $FSMOUNT is ${FSVALUE}%" \
                      >> $OUTFILE
            fi
        fi
     else # No exceptions file use the script default
             if [ $FSVALUE -gt $FSMAX ] # Use Script Default
             then
                  echo "$FSDEVICE mount on $FSMOUNT is ${FSVALUE}%" \
                        >> $OUTFILE
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
