#!/bin/ksh
#
# SCRIPT: SSAidentify.ksh
#
# AUTHOR: Randy Michael
#
# DATE: 11/7/2007
#
# REV: 2.5.A
#
# PURPOSE: This script is used to turn on, or off, the
# identify lights on the system's SSA disks
#
# REV LIST:
#	11/27/2007: Added code to allow the user to turn on/off
#	individual pdisk lights
#
#	12/10/2007: Added code to accept a combination of pdisks
#	and hdisks.  For each hdisk passed the script translates
#	the hdisk# into the associated pdisk#(s).
#
#	12/10/2007: Added code to ALLOW using the currently VARIED ON
#	Volume Group's disks (-v switch), as opposed to ALL DEFINED SSA disks,
#	which is the default behavior.  Very helpful in a HACMP environment.
#
#	12/11/2007: Added the "twirl" function to give the user feedback
#	during long processing periods, i.e. translating a few hundred
#	hdisks into associated pdisks.  The twirl function is just a rotating
#	cursor and it twirls during the translation processing.


# set -x   # Uncomment to debug this script

SCRIPTNAME=$(basename $0)

##############################################

function usage
{
echo "\nUSAGE ERROR...
\nMAN PAGE ==> $SCRIPTNAME  -?
\nTo Turn ALL Lights Either ON or OFF:
\nUSAGE: SSAidentify.ksh [-v] [on] [off]
EXAMPLE: SSAidentify.ksh -v  on
\nWill turn ON ALL of the system's currently VARIED ON
SSA identify lights. NOTE: The default is all DEFINED SSA disks
\nTo Turn SPECIFIC LIGHTS Either ON or OFF Using EITHER
the pdisk#(s) AND/OR the hdisk#(s):
\nUSAGE: SSAidentify.ksh [on] [off] pdisk{#1} [hdisk{#2}]...
EXAMPLE: SSAidentify.ksh on hdisk36 pdisk44 pdisk47
\nWill turn ON the lights to all of the associated pdisk#(s)
that hdisk36 translates to and PDISKS pdisk44 and pdisk47.
\nNOTE: Can use all pdisks, all hdisks or BOTH hdisk
and pdisk together if you want..."
exit 1
}

##############################################

function man_page
{
MAN_FILE="/tmp/man_file.out"
>$MAN_FILE

# Text for the man page...

echo "\n\t\tMAN PAGE FOR SSAidentify.ksh SHELL SCRIPT\n
This script is used to turn on, or off, the system's SSA disk drive
identification lights.  You can use this script in the following ways:\n
To turn on/off ALL DEFINED SSA drive identification lights, ALL VARIED-ON SSA
drive identification lights (-v switch), AN INDIVIDUAL SSA drive identification
light or A LIST OF SSA drive identification lights.\n
SSA disk drives can be specified by EITHER the pdisk OR the hdisk, or
a COMBINATION OF BOTH.  The script translates all hdisks into the
associated pdisk(s) using the system's /usr/sbin/ssaxlate command and turns
the SSA identification light on/off using the system's /usr/sbin/ssaidentify
command.\n

This script has four switches that control its' action:\n
-? - Displays this man page.\n
on - Turns the SSA identify light(s) ON.\n
off - Turns the SSA identify light(s) OFF.\n
-v - Specifies to only act on SSA disks which are in currently varied-on
volume groups.  The default action is to act on ALL DEFINED SSA disks.\n
NOTE: This switch is ignored for turning on/off individual SSA drive lights,
only valid when turning on/off ALL lights.  This option is very helpful in an
HACMP environment since ALL DEFINED, the default action, will turn on/off all
of the SSA drive lights even if the SSA disk is in a volume group which is not
currently varied-on.  This can be confusing in an HA cluster.\n
Using this script is very straight forward.  The following examples show the
correct use of this script:\n" >> $MAN_FILE
echo "\nUSAGE: SSAidentify.ksh [-v] [on] [off] [pdisk#/hdisk#] [pdisk#/hdisk# list]
\n\nTo Turn ALL Lights Either ON or OFF:
\nUSAGE: SSAidentify.ksh [-v] [on] [off]
\nEXAMPLE: $SCRIPTNAME  on
\nWill turn ON ALL of the system's DEFINED SSA identify lights.
This is the default.
EXAMPLE: SSAidentify.ksh -v  on
\nWill turn ON ALL of the system's currently VARIED ON
SSA identify lights.  OVERRIDES THE DEFAULT ACTION OF ALL DEFINED SSA DISKS
\nTo Turn SPECIFIC LIGHTS Either ON or OFF Using EITHER
the pdisk#(s) AND/OR the hdisk#(s):
\nUSAGE: $SCRIPTNAME [on] [off] pdisk{#1} [hdisk{#2}]...
\nEXAMPLE: $SCRIPTNAME on hdisk36 pdisk44 pdisk47
\nWill turn ON the lights to all of the associated pdisk#(s)
that hdisk36 translates to and PDISKS pdisk44 and pdisk47.
\nNOTE: Can use all pdisks, all hdisks or BOTH hdisk
and pdisk together if you want...\n\n" >> $MAN_FILE

more $MAN_FILE

# End of man_page function
}

##############################################

function cleanup
{
echo "\n...Exiting on a trapped signal...EXITING STAGE LEFT...\n"

kill $TWIRL_PID

# End of cleanup function
}

##############################################

function twirl
{
TCOUNT="0" # For each TCOUNT the line twirls one increment

while :    # Loop forever...until you break out of the loop
do
     TCOUNT=$(expr ${TCOUNT} + 1) # Increment the TCOUNT
     case ${TCOUNT} in
     "1") echo '-'"\b\c"
          sleep 1
          ;;
     "2") echo '\\'"\b\c"
          sleep 1
          ;;
     "3") echo "|\b\c"
          sleep 1
          ;;
     "4") echo "/\b\c"
          sleep 1
          ;;
       *) TCOUNT="0" ;;  # Reset the TCOUNT to "0", zero.
     esac
done
# End of twirl finction
}

############################################

function kill_twirl
{
kill `jobs -p` 2>/dev/null
# End of kill_twirl function
}

############################################
function all_defined_pdisks

{
   # TURN ON/OFF ALL LIGHTS:
   # Loop through each of the system.s pdisks by using the "lsdev"
   # command with the "-Cc pdisk" switch while using "awk" to extract
   # out the actual pdisk number. We will either
   # turn the identifier lights on or off, specified by the
   # $SWITCH variable:
   #
   # Turn lights on: -y
   # Turn lights off: -n
   #
   # as the $SWITCH value to the "ssaidentify" command, as used below...

echo "\nTurning $STATE ALL of the system.s pdisks...Please Wait...\n"

for PDISK in $(lsdev -Cc pdisk -s ssar -H | awk .{print $1}. | grep pdisk)
do
    echo "Turning $STATE ==> $PDISK"
    ssaidentify -l $PDISK -${SWITCH} || echo "Turning $STATE $PDISK Failed"
done
echo "\n...TASK COMPLETE...\n"

}

############################################

function all_varied_on_pdisks
{
trap 'kill -9 $TWIRL_PID; return 1' 1 2 3 15

cat /dev/null > $HDISKFILE

echo "\nGathering a list of Varied on system SSA disks...Please wait...\c"

VG_LIST=$(lsvg -o) # Get the list of Varied ON Volume Groups

for VG in $(echo $VG_LIST)
do
     lspv | grep $VG >> $HDISKFILE # List of Varied ON PVs
done

twirl & # Gives the user some feedback during long processing times...

TWIRL_PID=$!

echo "\nTranslating hdisk(s) into the associated pdisk(s)...Please Wait... \c"

for DISK in $(cat $HDISKFILE) # Translate hdisk# into pdisk#(s)
do
    # Checking for an SSA disk
    /usr/sbin/ssaxlate -l $DISK # 2>/dev/null 1>/dev/null

    if (($? == 0))
    then
        /usr/sbin/ssaxlate -l $DISK >> $PDISKFILE # Add to pdisk List
    fi
done

kill -9 $TWIRL_PID # Kill the user feedback function...
echo "\b  "

echo "\nTurning $STATE all VARIED-ON system pdisks...Please Wait...\n"

for PDISK in $(cat $PDISKFILE)
do # Act on each pdisk individually...
    echo "Turning $STATE ==> $PDISK"
    /usr/sbin/ssaidentify -l $PDISK -${SWITCH} || echo "Turning $STATE $PDISK Failed"
done

echo "\n\t...TASK COMPLETE...\n"
}

############################################

function list_of_disks
{
# TURN ON/OFF INDIVDUAL LIGHTS:
# Loop through each of the disks that was passed to this script
# via the positional parameters greater than $1, i.e., $2, $3, $4...
# We first determine if each of the parameters is a pdisk or an hdisk.
# For each hdisk passed to the script we first need to translate
# the hdisk definition into a pdisk definition. This script has
# been set up to accept a combination of hdisks and pdisks.
#
# We will either turn the identifier lights on or off, specified by
# the $SWITCH variable for each pdisk#:
#
#     Turn lights on: -y
#     Turn lights off: -n
#
# as the $SWITCH value to the "ssaidentify" command.

echo "\n"

# The disks passed to this script can be all hdisks, all pdisks
# or a combination of pdisks and hdisks; it just does not matter.
# We translate each hdisk into the associated pdisk(s).

echo "\nTurning $STATE individual SSA disk lights...\n"

for PDISK in $PDISKLIST
do
    # Is it a real pdisk??
    if [ -c /dev/${PDISK} ] 2>/dev/null
    then # Yep - act on it...

        /usr/sbin/ssaidentify -l $PDISK -${SWITCH}
        if [ $? -eq 0 ]
        then
            /usr/bin/ssaxlate -l $PDISK -${SWITCH}
            if (($? == 0))
            then
                echo "Light on $PDISK is $STATE"
            else
                echo "Turning $STATE $PDISK Failed"
            fi
        fi
    else
        echo "\nERROR: $PDISK is not a defined device on $THISHOST\n"
    fi
done

echo "\n...TASK COMPLETE...\n"
}

############################################
############# BEGINNING OF MAIN ############
############################################

# Set a trap...

# Remember...Cannot trap a "kill -9" !!!

trap 'cleanup; exit 1' 1 2 3 15

##############################################

# Check for the correct number of arguments (1)

if (($# == 0))
then
    usage
fi

##############################################

# See if the system has any pdisks defined before proceeding

PCOUNT=$(lsdev -Cc pdisk -s ssar | grep -c pdisk)

if ((PCOUNT == 0))
then
     echo "\nERROR: This system has no SSA disks defined\n"
     echo "\t\t...EXITING...\n"
     exit 1
fi

##############################################

# Make sure that the ssaidentify program is
# executable on this system...

if [ ! -x /usr/sbin/ssaidentify ]
then
    echo "\nERROR: /usr/sbin/ssaidentify is NOT an executable"
    echo "program on $THISHOST"
    echo "\n...EXITING...\n"
    exit 1
fi

##############################################

# Make sure that the ssaxlate program is
# executable on this system...

if [ ! -x /usr/sbin/ssaxlate ]
then
    echo "\nERROR: /usr/sbin/ssaxlate is NOT an executable"
    echo "program on $THISHOST"
    echo "\n...EXITING...\n"
    exit 1
fi

##############################################
##############################################
#
# Okay, we should have valid data at this point
# Let.s do a light show.
#
##############################################
##############################################

# Always use the UPPERCASED value for the $STATE, $MODE,
# and $PASSED variables...

typeset -u MODE
MODE="DEFINED_DISKS"
typeset -u STATE
STATE=UNKNOWN
typeset -u PASSED

# Use lowercase for the argument list
typeset -l ARGUMENT

# Grab the system hostname

THISHOST=$(hostname)

# Define the hdisk and pdisk FILES

HDISKFILE="/tmp/disklist.out"
>$HDISKFILE
PDISKFILE="/tmp/pdisklist.identify"
>$PDISKFILE

# Define the hdisk and pdisk list VARIABLES

HDISKLIST=
PDISKLIST=

# Use getopts to parse the command-line arguments

while getopts ":vV" ARGUMENT 2>/dev/null
do
    case $ARGUMENT in
    v|V) MODE="VARIED_ON"
         ;;
    \?) man_page
        ;;
    esac
done

##############################################

# Decide if we are to turn the lights on or off...

(echo $@ | grep -i -w on >/dev/null) && STATE=ON
(echo $@ | grep -i -w off >/dev/null) && STATE=OFF

case $STATE in

ON)
     # Turn all of the lights ON...
     SWITCH="y"
     ;;
OFF)
     # Turn all of the lights OFF...
     SWITCH="n"
     ;;
*)
     # Unknown Option...
     echo "\nERROR: Please indicate the action to turn lights ON or OFF\n"
     usage
     exit 1
     ;;
esac

##############################################
##############################################
########## PLAY WITH THE LIGHTS ##############
##############################################
##############################################

if (($# == 1)) && [[ $MODE = "DEFINED_DISKS" ]]
then
    # This function will turn all lights on/off

    all_defined_pdisks

elif [[ $MODE = "VARIED_ON" ]] && (($# = 2))
then
    # This function will turn on/off SSA disk lights
    # in currently varied-on volume groups only

    all_varied_on_pdisks

# Now check for hdisk and pdisk arguments

elif [ $MODE = DEFINED_DISKS ] && (echo $@ | grep disk >/dev/null) \
      && (($# >= 2))
then
    # If we are here we must have a list of hdisks
    # and/or pdisks

    # Look for hdisks and pdisks in the command-line arguments

    for DISK in $(echo $@ | grep disk)
    do
        case $DISK in
        hdisk*) HDISKLIST="$HDISKLIST $DISK"
                ;;
        pdisk*) PDISKLIST="$PDISKLIST $DISK"
                ;;
             *) : # No-Op - Do nothing
                ;;
        esac
    done

    if [[ ! -z "$HDISKLIST" ]] # Check for hdisks to convert to pdisks
    then

    # We have some hdisks that need to be converted to pdisks
    # so start converting the hdisks to pdisks

        # Give the user some feedback

        echo "\nConverting hdisks to pdisk definitions"
        echo "\n ...Please be patient...\n"

        # Start converting the hdisks to pdisks

        for HDISK in $HDISKLIST
        do
            PDISK=$(ssaxlate -l $HDISK)
            if (($? == 0))
            then
                echo "$HDISK translates to ${PDISK}"
            else
                echo "ERROR: hdisk to pdisk translation FAILED for $HDISK"
           fi

           # Build a list of pdisks
           # Add pdisk to the pdisk list

           PDISKLIST="$PDISKLIST $PDISK"
        done
    fi

    if [[ -z "$PDISKLIST" ]]
    then
        echo "\nERROR: You must specify at least one hdisk or pdisk\n"
        man_page
        exit 1
    else
        # Turn on/off the SSA identification lights

        list_of_disks
    fi
fi

##############################################
# END OF SCRIPT #
##############################################
