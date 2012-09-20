#!/usr/bin/ksh
#
# SCRIPT: fs_mon_ALL_OS.ksh
# AUTHOR: Randy Michael
# DATE: 09-25-2007
# REV: 6.0.P
# 
# PURPOSE: This script is used to monitor for full filesystems,
#     which are defined as .exceeding. the MAX_PERCENT value.
#     A message is displayed for all .full. filesystems.
#
# PLATFORM: AIX, Linux, HP-UX, OpenBSD, and Solaris
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
#          It does an .auto-detection. but has override capability
#          of both the trigger level and the monitoring method using
#          the exceptions file pointed to by the $EXCEPTIONS variable
#
#          Randy Michael - 08-28-2007
#          Added code to allow this script to be executed on
#          AIX, Linux, HP-UX, and Solaris
#
#          Randy Michael - 09=25=2007
#          Added code for OpenBSD support
#
# set -n # Uncomment to check syntax without any execution
# set -x # Uncomment to debug this script
#
##### DEFINE FILES AND VARIABLES HERE ####  

MIN_MB_FREE="100MB"    # Min. MB of Free FS Space
MAX_PERCENT="85%"      # Max. FS percentage value
FSTRIGGER="1000MB"     # Trigger to switch from % Used to MB Free

WORKFILE="/tmp/df.work" # Holds filesystem data
>$WORKFILE              # Initialize to empty
OUTFILE="/tmp/df.outfile" # Output display file
>$OUTFILE           # Initialize to empty
EXCEPTIONS="/usr/local/bin/exceptions" # Override data file
DATA_EXCEPTIONS="/tmp/dfdata.out" # Exceptions file w/o # rows
EXCEPT_FILE="N"        # Assume no $EXCEPTIONS FILE
THISHOST=`hostname`    # Hostname of this machine

###### FORMAT VARIABLES HERE ######

# Both of these variables need to be multiplied by 1024 blocks
(( MIN_MB_FREE = $(echo $MIN_MB_FREE | sed s/MB//g) * 1024 ))
(( FSTRIGGER = $(echo $FSTRIGGER | sed s/MB//g)  * 1024 ))

###### SHELL SPECIFIC VARIABLES ######

# Set the correct usage for the echo command for found $SHELL

case $SHELL in
*/bin/bash) ECHO="echo -e"
            ;;
 */bin/ksh) ECHO="echo"
            ;;
  */bin/sh) ECHO="echo -e"
            ;;
         *) ECHO="echo"
            ;;
esac

######################################
####### DEFINE FUNCTIONS HERE ########
######################################

function get_OS_info
{
# For a few commands it is necessary to know the OS and its level
# to execute the proper command syntax.  This will always return
# the OS in UPPERCASE

typeset -u OS   # Use the UPPERCASE values for the OS variable
OS=`uname`   # Grab the Operating system, i.e. AIX, HP-UX
print $OS    # Send back the UPPERCASE value
}

####################################

function check_exceptions
{
# set -x # Uncomment to debug this function

while read FSNAME FSLIMIT
do
    IN_FILE="N"

    # Do an NFS sanity check and get rid of any .:..
    # If this is found it is actually an error entry
    # but we will try to resolve it.  It will only
    # work if it is an NFS cross mount to the same
    # mount point on both machines.
    $ECHO $FSNAME | grep ':' >/dev/null \
         && FSNAME=$($ECHO $FSNAME | cut -d ':' -f2)

    # Check for empty and null variable
    if [[ ! -z $FSLIMIT && $FSLIMIT != '' ]]
    then
        if [[ $FSNAME = $FSMOUNT ]] # Found it!
        then
            # Check for "MB" Characters...Set IN_FILE=MB
          $ECHO $FSLIMIT | grep MB >/dev/null && IN_FILE="MB" \
                 && (( FSLIMIT = $($ECHO $FSLIMIT \
                       | sed s/MB//g) * 1024 ))
            # check for '%' Character...Set IN_FILE=PC, for %
            $ECHO $FSLIMIT | grep '%' >/dev/null && IN_FILE="PC" \
                 && FSLIMIT=$($ECHO $FSLIMIT | sed s/\%//g)

            case $IN_FILE in
            MB) # Use MB of Free Space Method
                # Up-case the characters, if they exist
                FSLIMIT=$($ECHO $FSLIMIT | tr '[a-z]' '[A-Z]')
                # Get rid of the 'MB' if it exists
                FSLIMIT=$($ECHO $FSLIMIT | sed s/MB//g)
                # Test for blank and null values
                if [[ ! -z $FSLIMIT && $FSLIMIT != '' ]]
                then
                   # Test for a valid filesystem 'MB' limit
                   if (( FSLIMIT >= 0 && FSLIMIT < FSSIZE ))
                   then
                      if (( FSMB_FREE < FSLIMIT ))
                      then
                         return 1 # Found out of limit
                                  # using MB Free method
                      else
                         return 3 # Found OK
                      fi
                   else
                       $ECHO "\nERROR: Invalid filesystem MAX for\
 $FSMOUNT - $FSLIMIT"
                       $ECHO "       Exceptions file value must be less\
 than or"
                       $ECHO "       equal to the size of the filesystem\
 measured"
                       $ECHO "       in 1024 bytes\n"
                   fi
                else
                   $ECHO "\nERROR: Null value specified in exceptions\
 file"
                   $ECHO "       for the $FSMOUNT mount point.\n"
                fi
                ;;
            PC) # Use Filesystem %Used Method
                # Strip out the % sign if it exists
                PC_USED=$($ECHO $PC_USED | sed s/\%//g)
                # Test for blank and null values
                if [[ ! -z "$FSLIMIT" && "$FSLIMIT" != '' ]]
                then
                   # Test for a valid percentage, i.e. 0-100
                   if (( FSLIMIT >= 0 && FSLIMIT <= 100 ))
                   then
                      if (( $PC_USED > $FSLIMIT ))
                      then
                         return 2 # Found exceeded by % Used method
                      else
                         return 3 # Found OK
                      fi
                   else
                      $ECHO "\nERROR: Invalid percentage for $FSMOUNT -\
 $FSLIMIT"
                      $ECHO "       Exceptions file values must be"
                      $ECHO "       between 0 and 100%\n"
                   fi
                else
                   $ECHO "\nERROR: Null value specified in exceptions\
 file"
                   $ECHO "       for the $FSMOUNT mount point.\n"
                fi
                ;;
            N)  # Method Not Specified - Use Script Defaults
                if (( FSSIZE >= FSTRIGGER ))
                then # This is a "large" filesystem
                    if (( FSMB_FREE < MIN_MB_FREE ))
                    then
                         return 1 # Found out of limit
                                  # using MB Free method
                    else
                         return 3 # Found OK
                    fi 
                else # This is a standard filesystem
                    PC_USED=$($ECHO $PC_USED | sed s/\%//g) # Remove %
                    FSLIMIT=$($ECHO $FSLIMIT | sed s/\%//g) # Remove %
                    if (( PC_USED > FSLIMIT ))
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
      $ECHO "\nFull Filesystem(s) on $THISHOST\n"
      cat $OUTFILE
      print
fi
}

####################################

function load_EXCEPTIONS_data
{
# Ignore any line that begins with a pound sign, #
# and omit all blank lines

cat $EXCEPTIONS |  grep -v "^#" | sed /^$/d > $DATA_EXCEPTIONS
}

####################################

function load_AIX_FS_data
{

   df -k | tail +2 | egrep -v "/dev/cd[0-9]|/proc" \
         | awk '{print $1, $2, $3, $4, $7}' > $WORKFILE
}

####################################

function load_HP_UX_FS_data
{

   bdf | tail +2 | egrep -v "/cdrom" \
         | awk '{print $1, $2, $4, $5, $6}' > $WORKFILE
}

####################################

function load_LINUX_FS_data
{

   df -k | tail -n +2 | egrep -v "/cdrom"\
         | awk '{print $1, $2, $4, $5, $6}' > $WORKFILE
}

####################################

function load_OpenBSD_FS_data
{
   df -k | tail +2 | egrep -v "/mnt/cdrom"\
         | awk '{print $1, $2, $4, $5, $6}' > $WORKFILE
}

####################################

function load_Solaris_FS_data
{

   df -k | tail +2 | egrep -v "/dev/fd|/etc/mnttab|/proc"\
         | awk '{print $1, $2, $4, $5, $6}' > $WORKFILE
}

####################################
######### START OF MAIN ############
####################################

# Query the operating system to find the Unix flavor, then
# load the correct filesystem data for the resident OS

case $(get_OS_info) in
   AIX)   # Load filesystem data for AIX
          load_AIX_FS_data
      ;;
   HP-UX) # Load filesystem data for HP-UX
          load_HP_UX_FS_data
      ;;
   LINUX) # Load filesystem data for Linux
          load_LINUX_FS_data
      ;;
   OPENBSD) # Load filesystem data for OpenBSD
          load_OpenBSD_FS_data
      ;;
   SUNOS) # Load filesystem data for Solaris
          load_Solaris_FS_data
      ;;
   *)     # Unsupported in script
          $ECHO "\nUnsupported Operating System for this Script...EXITING\n"
          exit 1
esac

# Do we have a nonzero size $EXCEPTIONS file?

if [[ -s $EXCEPTIONS ]]
then # Found a nonempty $EXCEPTIONS file

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
            (( FS_FREE_OUT = FSMB_FREE / 1000 ))
            $ECHO "$FSDEVICE mounted on $FSMOUNT has ${FS_FREE_OUT}MB Free" >> $OUTFILE
          ;;
         2) # Found exceeded in exceptions file by %Used method
            $ECHO "$FSDEVICE mount on $FSMOUNT is ${PC_USED}%" \
                  >> $OUTFILE
          ;;
         3) # Found OK in exceptions file
            : # NO-OP Do Nothing.  A ':' is a no-op!
          ;;

         4) # Not found in exceptions file - Use Default Triggers
            if (( FSSIZE >= FSTRIGGER ))
            then # This is a "large" filesystem 
              FSMB_FREE=$($ECHO $FSMB_FREE | sed s/MB//g) # Remove the "MB"
              if (( FSMB_FREE < MIN_MB_FREE  ))
              then
                (( FS_FREE_OUT = FSMB_FREE / 1000 ))
                $ECHO "$FSDEVICE mounted on $FSMOUNT has {FS_FREE_OUT}MB Free" >> $OUTFILE
              fi
            else # This is a standard filesystem
                PC_USED=$($ECHO $PC_USED | sed s/\%//g)
                MAX_PERCENT=$($ECHO $MAX_PERCENT | sed s/\%//g)
                if (( PC_USED > MAX_PERCENT ))
                then
                    $ECHO "$FSDEVICE mount on $FSMOUNT is ${PC_USED}%" \
                          >> $OUTFILE
                fi
            fi
          ;;
         esac

     else # NO $EXCEPTIONS FILE USE DEFAULT TRIGGER VALUES

          if (( FSSIZE >= FSTRIGGER  )) 
          then # This is a "large" filesystem - Use MB Free Method
            FSMB_FREE=$($ECHO $FSMB_FREE | sed s/MB//g) # Remove the 'MB'
            if (( FSMB_FREE < MIN_MB_FREE ))
            then
              (( FS_FREE_OUT = FSMB_FREE / 1000 ))
              $ECHO "$FSDEVICE mounted on $FSMOUNT has ${FS_FREE_OUT}MB Free" \
                       >> $OUTFILE
            fi
          else # This is a standard filesystem - Use % Used Method
              PC_USED=$($ECHO $PC_USED | sed s/\%//g)
              MAX_PERCENT=$($ECHO $MAX_PERCENT | sed s/\%//g)
              if (( PC_USED > MAX_PERCENT ))
              then
                  $ECHO "$FSDEVICE mount on $FSMOUNT is ${PC_USED}%" \
                        >> $OUTFILE
              fi
          fi
     fi
done < $WORKFILE # Feed the while loop from the bottom!!!!!

display_output

# End of Script

