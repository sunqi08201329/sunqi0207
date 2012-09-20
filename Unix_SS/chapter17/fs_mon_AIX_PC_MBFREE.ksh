#!/usr/bin/ksh
#
# SCRIPT: fs_mon_AIX_PC_MBFREE.ksh
# AUTHOR: Randy Michael
# DATE: 08-22-2007
# REV: 4.3.P
# PURPOSE: This script is used to monitor for full filesystems,
#     which is defined as "exceeding" the MAX_PERCENT value.
#     A message is displayed for all "full" filesystems.
#
# PLATFORM: AIX
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
#          Randy Michael - 08-28-2007
#          Changed the code to handle both %Used and MB of Free Space.
#          It does an "auto-detection" but has override capability
#          of both the trigger level and the monitoring method using
#          the exceptions file pointed to  by the $EXCEPTIONS variable
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
EXCEPT_FILE="N"        # Assume no $EXCEPTIONS FILE
THISHOST=`hostname`    # Hostname of this machine

MIN_MB_FREE="100MB"    # Min. MB of Free FS Space
MAX_PERCENT="85%"      # Max. FS percentage value
FSTRIGGER="1000MB"     # Trigger to switch from % Used to MB Free


###### FORMAT VARIABLES HERE ######

# Both of these variables need to multiplied by 1024 blocks
(( MIN_MB_FREE = $(echo $MIN_MB_FREE | sed s/MB//g) * 1024 ))
(( FSTRIGGER = $(echo $FSTRIGGER | sed s/MB//g)  * 1024 ))

####### DEFINE FUNCTIONS HERE ########

function check_exceptions
{
# set -x # Uncomment to debug this function

while read FSNAME FSLIMIT
do
    IN_FILE="N"

    # Do an NFS sanity check and get rid of any ":".
    # If this is found it is actaully an error entry
    # but we will try to resolve it.  It will only
    # work if it is an NFS cross mount to the same
    # mount point on both machines.
    echo $FSNAME | grep ':' >/dev/null \
         && FSNAME=$(echo $FSNAME | cut -d ':' -f2)

    # Check for empty and null variable
    if [[ ! -z $FSLIMIT && $FSLIMIT != '' ]]
    then
        if [[ $FSNAME = $FSMOUNT ]] # Found it!
        then
            # Check for "MB" Characters...Set IN_FILE=MB
	    echo $FSLIMIT | grep MB >/dev/null && IN_FILE="MB" \
                 && (( FSLIMIT = $(echo $FSLIMIT \
                       | sed s/MB//g) * 1024 ))
            # check for "%" Character...Set IN_FILE=PC, for %
            echo $FSLIMIT | grep "%" >/dev/null && IN_FILE="PC" \
                 && FSLIMIT=$(echo $FSLIMIT | sed s/\%//g)

            case $IN_FILE in
            MB)
                # Up-case the characters, if they exist
                FSLIMIT=$(echo $FSLIMIT | tr '[a-z]' '[A-Z]')
                # Get rid of the "MB" if it exists
                FSLIMIT=$(echo $FSLIMIT | sed s/MB//g)
                # Test for blank and null values
                if [[ ! -z $FSLIMIT && $FSLIMIT != '' ]]
                then
                   # Test for a valid filesystem "MB" limit
                   if (( $FSLIMIT >= 0 && $FSLIMIT < $FSSIZE ))
                   then
                      if (( $FSMB_FREE < $FSLIMIT ))
                      then
                         return 1 # Found out of limit using MB Free method
                      else
                         return 3 # Found OK
                      fi
                   else
                       echo "\nERROR: Invalid filesystem MAX for $FSMOUNT - $FSLIMIT"
                       echo "       Exceptions file value must be less than or"
                       echo "       equal to the size of the filesystem measured"
                       echo "       in 1024 bytes\n"
                   fi
                else
                   echo "\nERROR: Null value specified in excepeptions file"
                   echo "       for the $FSMOUNT mount point.\n"
                fi
                ;;
            PC)
                # Strip out the % sign if it exists
                PC_USED=$(echo $PC_USED | sed s/\%//g)
                # Test for blank and null values
                if [[ ! -z $FSLIMIT && $FSLIMIT != '' ]]
                then
                   # Test for a valid percentage, i.e. 0-100
                   if (( $FSLIMIT >= 0 && $FSLIMIT <= 100 ))
                   then
                      if (( $PC_USED > $FSLIMIT ))
                      then
                         return 2 # Found exceeded by % Used method
                      else
                         return 3 # Found OK
                      fi
                   else
                      echo "\nERROR: Invalid percentage for $FSMOUNT - $FSLIMIT"
                      echo "       Exceptions file values must be"
                      echo "       between 0 and 100%\n"
                   fi
                else
                   echo "\nERROR: Null value specified in excepeptions file"
                   echo "       for the $FSMOUNT mount point.\n"
                fi
                ;;
            N)
                # Method Not Specified - Use Script Defaults
                if (( $FSSIZE >= $FSTRIGGER ))
                then # This is a "large" filesystem
                    if (( $FSMB_FREE < $MIN_MB_FREE ))
                    then
                         return 1 # Found out of limit using MB Free method
                    else
                         return 3 # Found OK
                    fi 
                else # This is a standard filesystem
                    PC_USED=$(echo $PC_USED | sed s/\%//g) # Remove the %
                    FSLIMIT=$(echo $FSLIMIT | sed s/\%//g) # Remove the %
                    if (( $PC_USED > $FSLIMIT ))
                    then
                        return 2 # Found exceeded by % Used method
                    else
                        return 3 # Found OK
                    fi
                fi
                ;;
            esac
        fi
    fi
done < $DATA_EXCEPTIONS # Feed the loop from the bottom!!!

return 4 # Not found in $EXCEPTIONS file
}

####################################

function display_output
{
if [[ -s $OUTFILE ]]
then
      echo "\nFull Filesystem(s) on $THISHOST\n"
      cat $OUTFILE
      print
fi
}

####################################

function load_EXCEPTIONS_data
{
# Ingore any line that begins with a pound sign, #

cat $EXCEPTIONS |  grep -v "^#" > $DATA_EXCEPTIONS
}

####################################

function load_FS_data
{
   df -k | tail +2 | egrep -v '/dev/cd[0-9]|/proc' \
         | awk '{print $1, $2, $3, $4, $7}' > $WORKFILE
}

####################################
######### START OF MAIN ############
####################################

load_FS_data

# Do we have a non-zero size $EXCEPTIONS file?

if [[ -s $EXCEPTIONS ]]
then # Found a non-empty $EXCEPTIONS file

    load_EXCEPTIONS_data
    EXCEP_FILE="Y"
fi

while read FSDEVICE FSSIZE FSMB_FREE PC_USED FSMOUNT
do
     if [[ $EXCEP_FILE = "Y" ]]
     then
         check_exceptions
         CE_RC="$?" # Check Exceptions Return Code (CE_RC)

         case $CE_RC in
         1) # Found exceeded in exceptions file by MB Method
            (( FS_FREE_OUT = $FSMB_FREE / 1000 ))
            echo "$FSDEVICE mounted on $FSMOUNT has ${FS_FREE_OUT}MB Free" \
                  >> $OUTFILE
          ;;
         2) # Found exceeded in exceptions file by %Used method
            echo "$FSDEVICE mount on $FSMOUNT is ${PC_USED}%" \
                  >> $OUTFILE
          ;;
         3) # Found OK in exceptions file
            : # NO-OP Do Nothing
          ;;

         4) # Not found in exceptions file - Use Default Triggers
            if (( $FSSIZE >= $FSTRIGGER ))
            then # This is a "large" filesystem 
              FSMB_FREE=$(echo $FSMB_FREE | sed s/MB//g) # Remove the "MB"
              if (( $FSMB_FREE < $MIN_MB_FREE  ))
              then
                (( FS_FREE_OUT = $FSMB_FREE / 1000 ))
                echo "$FSDEVICE mounted on $FSMOUNT has ${FS_FREE_OUT}MB Free" \
                      >> $OUTFILE
              fi
            else # This is a standard filesystem
                PC_USED=$(echo $PC_USED | sed s/\%//g)
                MAX_PERCENT=$(echo $MAX_PERCENT | sed s/\%//g)
                if (( $PC_USED > $MAX_PERCENT ))
                then
                    echo "$FSDEVICE mount on $FSMOUNT is ${PC_USED}%" \
                          >> $OUTFILE
                fi
            fi
          ;;
         esac


     else # NO $EXECPTIONS FILE USE DEFAULT TRIGGER VALUES

          if (( $FSSIZE >= $FSTRIGGER  )) 
          then # This is a "large" filesystem - Use MB Free Method
            FSMB_FREE=$(echo $FSMB_FREE | sed s/MB//g) # Remove the "MB"
            if (( $FSMB_FREE < $MIN_MB_FREE ))
            then
              (( FS_FREE_OUT = $FSMB_FREE / 1000 ))
              echo "$FSDEVICE mounted on $FSMOUNT has ${FS_FREE_OUT}MB Free" \
                       >> $OUTFILE
            fi
          else # This is a standard filesystem - Use % Used Method
              PC_USED=$(echo $PC_USED | sed s/\%//g)
              MAX_PERCENT=$(echo $MAX_PERCENT | sed s/\%//g)
              if (( $PC_USED > $MAX_PERCENT ))
              then
                  echo "$FSDEVICE mount on $FSMOUNT is ${PC_USED}%" \
                        >> $OUTFILE
              fi
          fi
     fi
done < $WORKFILE

display_output

# End of Script
