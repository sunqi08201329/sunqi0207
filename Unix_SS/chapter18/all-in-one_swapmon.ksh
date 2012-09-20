#!/usr/bin/ksh
#
# SCRIPT: all-in-one_swapmon.ksh
#
# AUTHOR: Randy Michael
# DATE: 5/31/2007
# REV: 3.0.P
#
# PLATFORM: AIX, Solaris, HP-UX, Linux, and OpenBSD Only
#
# PURPOSE: This shell script is used to produce a report of
#          the system's paging or swap space statistics including:
#
#       Total paging space in MB, MB of Free paging space,
#       MB of Used paging space, % of paging space Used, and
#       % of paging space Free
#
# REV LIST:
#
# 11/5/2007 -- Randy Michael
#
# REVISION: Added a function for OpenBSD swap monitoring and changed the case
# statement controlling correct usage depending on the OS.
# 
##############
#
# set -x # Uncomment to debug this shell script
# set -n # Uncomment to check command syntax without any execution
#
###########################################################
################ DEFINE VARIABLES HERE ####################

PC_LIMIT=65            # Upper limit of Swap space percentage
                       # before notification

THISHOST=$(hostname)   # Host name of this machine

case $(basename $SHELL) in
bash) alias echo="echo -e"
      ;;
esac

###########################################################
################ INITIALIZE THE REPORT ####################

echo "\nSwap Space Report for $THISHOST\n"
date

###########################################################
################ DEFINE FUNCTIONS HERE ####################

function SUN_swap_mon
{
############# CAPTURE AND PROCESS THE DATA ################

# Use two awk statements to extract the $9 and $11 fields
# from the swap -s command output

SW_USED=$(swap -s | awk '{print $9}' | cut -dk -f1)
SW_FREE=$(swap -s | awk '{print $11}' | cut -dk -f1)

# Add SW_USED to SW_FREE to get the total swap space

((SW_TOTAL = SW_USED + SW_FREE))

# Calculate the percent used and percent free using the
# bc utility in a here documentation with command substitution

PERCENT_USED=$(bc <<EOF
scale=4
($SW_USED / $SW_TOTAL) * 100
EOF
)

PERCENT_FREE=$(bc <<EOF
scale=4
($SW_FREE / $SW_TOTAL) * 100
EOF
)

# Convert the KB measurements to MB measurements

((SW_TOTAL_MB = SW_TOTAL / 1000))
((SW_USED_MB  = SW_USED / 1000))
((SW_FREE_MB  = SW_FREE / 1000))

# Produce the remaining part of the report

echo "\nTotal Amount of Swap Space:\t${SW_TOTAL_MB}MB"
echo "Total KB of Swap Space Used:\t${SW_USED_MB}MB"
echo "Total KB of Swap Space Free:\t${SW_FREE_MB}MB"
echo "\nPercent of Swap Space Used:\t${PERCENT_USED}%"
echo "\nPercent of Swap Space Free:\t${PERCENT_FREE}%"

# Grab the integer portion of the percent used

INT_PERCENT_USED=$(echo $PERCENT_USED | cut -d. -f1)

# Check to see if the percentage used maxmum threshold
# has beed exceeded

if (( PC_LIMIT <= INT_PERCENT_USED ))
then
    # Percent used has exceeded the threshold, send notification

    tput smso # Turn on reverse video!
    echo "\n\nWARNING: Swap Space has Exceeded the ${PC_LIMIT}% Upper Limit!\n"
    tput rmso # Turn off reverse video!
fi

echo "\n"
}

###########################################################

function Linux_swap_mon
{
############# CAPTURE AND PROCESS THE DATA ################

free -m | grep -i swap | while read junk SW_TOTAL SW_USED SW_FREE
do

# Use the bc utility in a here document to calculate
# the percentage of free and used swap space.

PERCENT_USED=$(bc <<EOF
scale=4
($SW_USED / $SW_TOTAL) * 100
EOF
)

PERCENT_FREE=$(bc <<EOF
scale=4
($SW_FREE / $SW_TOTAL) * 100
EOF
)

     # Produce the rest of the paging space report:
     echo "\nTotal Amount of Swap Space:\t${SW_TOTAL}MB"
     echo "Total KB of Swap Space Used:\t${SW_USED}MB"
     echo "Total KB of Swap Space Free:\t${SW_FREE}MB"
     echo "\nPercent of Swap Space Used:\t${PERCENT_USED}%"
     echo "\nPercent of Swap Space Free:\t${PERCENT_FREE}%"

     # Grap the integer portion of the percent used to
     # test for the over limit threshold

     INT_PERCENT_USED=$(echo $PERCENT_USED | cut -d. -f1)

     if (( PC_LIMIT <= INT_PERCENT_USED ))
     then
          tput smso
          echo "\n\nWARNING: Paging Space has Exceeded the ${PC_LIMIT}% Upper Limit!\n"
          tput rmso
     fi

done

echo "\n"
}

###########################################################

function HP_UX_swap_mon
{
############# CAPTURE AND PROCESS THE DATA ################

# Start a while read loop by using the piped in input from
# the swapinfo -tm command output.


swapinfo -tm | grep dev | while read junk SW_TOTAL SW_USED \
                               SW_FREE PERCENT_USED junk2
do
    # Calculate the percentage of free swap space

    ((PERCENT_FREE = 100 - $(echo $PERCENT_USED | cut -d% -f1) ))

    echo "\nTotal Amount of Swap Space:\t${SW_TOTAL}MB"
    echo "Total MB of Swap Space Used:\t${SW_USED}MB"
    echo "Total MB of Swap Space Free:\t${SW_FREE}MB"
    echo "\nPercent of Swap Space Used:\t${PERCENT_USED}"
    echo "\nPercent of Swap Space Free:\t${PERCENT_FREE}%"

    # Check for paging space exceeded the predefined limit

    if (( PC_LIMIT <= $(echo $PERCENT_USED | cut -d% -f1) ))
    then
        # Swap space is over the predefined limit, send notification

       tput smso # Turn on reverse video!
         echo "\n\nWARNING: Swap Space has Exceeded the ${PC_LIMIT}% Upper Limit!\n"
         tput rmso # Turn reverse video off!
    fi

done

echo "\n"
}

###########################################################

function AIX_paging_mon
{
################ DEFINE VARIABLES HERE ####################

PAGING_STAT=/tmp/paging_stat.out # Paging Stat hold file

###########################################################
############# CAPTURE AND PROCESS THE DATA ################

# Load the data in a file without the column headings

lsps -s | tail +2 > $PAGING_STAT

# Start a while loop and feed the loop from the bottom using
# the $PAGING_STAT file as redirected input

while read TOTAL PERCENT
do
     # Clean up the data by removing the suffixes
     PAGING_MB=$(echo $TOTAL | cut -d 'MB' -f1)
     PAGING_PC=$(echo $PERCENT | cut -d% -f1)

     # Calculate the missing data: %Free, MB used and MB free
     (( PAGING_PC_FREE = 100 - PAGING_PC ))
     (( MB_USED = PAGING_MB * PAGING_PC / 100 ))
     (( MB_FREE = PAGING_MB - MB_USED ))

     # Produce the rest of the paging space report:
     echo "\nTotal MB of Paging Space:\t$TOTAL"
     echo "Total MB of Paging Space Used:\t${MB_USED}MB"
     echo "Total MB of Paging Space Free:\t${MB_FREE}MB"
     echo "\nPercent of Paging Space Used:\t${PERCENT}"
     echo "\nPercent of Paging Space Free:\t${PAGING_PC_FREE}%"

     # Check for paging space exceeded the predefined limit
     if ((PC_LIMIT <= PAGING_PC))
     then
          # Paging space is over the limit, send notification

          tput smso  # Turn on reverse video!

          echo "\n\nWARNING: Paging Space has Exceeded the ${PC_LIMIT}% Upper Limit!\n"

          tput rmso  # Turn off reverse video
     fi

done < $PAGING_STAT

rm -f $PAGING_STAT

# Add an extra new line to the output

echo "\n"
}

###########################################################

function OpenBSD_swap_mon
{
###########################################################
############# CAPTURE AND PROCESS THE DATA ################

# Load the data in a file without the column headings

swapctl -lk | tail +2 | awk '{print $2, $3, $4, $5}' \
            | while read KB_TOT KB_USED KB_AVAIL PC_USED
do
     (( TOTAL = KB_TOT / 1000 ))
     (( MB_USED = KB_USED / 1000 ))
     (( MB_FREE = KB_AVAIL / 1000 ))
     PC_FREE_NO_PC=$(echo $PC_USED | awk -F '%' '{print $1}')
     (( PC_FREE = 100 - PC_FREE_NO_PC ))

     # Produce the rest of the paging space report:
     echo "\nTotal MB of Paging Space:\t${TOTAL}MB"
     echo "Total MB of Paging Space Used:\t${MB_USED}MB"
     echo "Total MB of Paging Space Free:\t${MB_FREE}MB"
     echo "\nPercent of Paging Space Used:\t${PC_USED}"
     echo "\nPercent of Paging Space Free:\t${PC_FREE}%\n"
done


# Check for paging space exceeded the predefined limit

if (( PC_LIMIT <= PC_FREE_NO_PC ))
then
     echo "\n\nWARNING: Paging Space has Exceeded the ${PC_LIMIT}% Upper Limit!\n"
fi
}

###########################################################
################## BEGINNING OF MAIN ######################
###########################################################

# Find the Operating System and execute the correct function

case $(uname) in

     AIX) AIX_paging_mon
     ;;
     HP-UX) HP_UX_swap_mon
     ;;
     Linux) Linux_swap_mon
     ;;
     SunOS) SUN_swap_mon
     ;;
     OpenBSD) OpenBSD_swap_mon
     ;;
     *) echo "\nERROR: Unsupported Operating System...EXITING\n"
        exit 1
     ;;
esac

# End of all-in-one_swapmon.ksh
