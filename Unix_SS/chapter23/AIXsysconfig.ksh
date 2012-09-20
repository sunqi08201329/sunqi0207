#!/usr/bin/ksh
#
# SCRIPT: AIXsysconfig.ksh
#
# AUTHOR: Randy Michael
# REV: 2.1.A
# DATE: 06/14/2007
#
# PLATFORM: AIX only
#
# PURPOSE:  Take a snapshot of the system for later comparision in the
# 	    event of system problems. All data is stored in 
#           /usr/local/reboot in the file defined to the $SYSINFO_FILE
#           variable below.
#
#
# REV LIST:
#           7/11/2007: Changed this script to use a single output file
#                      that receives data from a series of commands
#                      within a bunch of functions.
#
#           10/11/2007: Added the following commands to capture 
#                      the AIX technology level and patch set, and
#                      print the system configuration
#
#                      oslevel -s   # Show TL and patch levels
#
#                      prtconf  # Print the system configuration
#
############
#
# set -x  # Uncomment to debug this script
# set -n  # Uncomment to verify command syntax without execution
#
#################################################
######### DEFINE VARIABLES HERE #################
#################################################

THISHOST=$(hostname)
DATETIME=$(date +%m%d%y_%H%M%S)
WORKDIR="/usr/local/reboot"
SYSINFO_FILE="${WORKDIR}/sys_snapshot.${THISHOST}.$DATETIME"

#################################################
############ DEFINE FUNCTIONS HERE ##############
#################################################

get_host ()
{
# Hostname of this machine

hostname

# uname -n  # works too
}

#################################################

get_OS ()
{
# Operating System - AIX or exit

uname -s
}

#################################################

get_OS_level ()
{
# Query for the operating system release and version level

oslevel -r

OSL=$(oslevel -r | cut -c1-2)
if (( OSL >= 53 ))
then
    echo "Technology Level:       $(oslevel -s)"
fi
}

#################################################

get_ML_for_AIX ()
{
# Query the system for the maintenance level patch set

instfix -i | grep AIX_ML
}

#################################################

print_sys_config ()
{
prtconf
}

#################################################

get_TZ ()
{
# Get the time zone that the system is operating in.

cat /etc/environment | grep TZ | awk -F'=' '{print $2}'
}

#################################################

get_real_mem ()
{
# Query the system for the total real memory

echo "$(bootinfo -r)KB"

# lsattr -El sys0 -a realmem | awk '{print $2}' #  Works too
}

#################################################

get_arch ()
{
# Query the system for the hardware architecture. Newer
# machines use the -M switch and the older Micro-Channel
# architecture (MCA) machines use the -p option for
# the "uname" command.

ARCH=$(uname -M)
if [[ -z "$ARCH" && "$ARCH" = '' ]]
then
     ARCH=$(uname -p)
fi

echo "$ARCH"
}

#################################################

get_devices ()
{
# Query the system for all configured devices

lsdev -C
}

#################################################

get_long_devdir_listing ()
{
# Long listing of the /dev directory. This shows the
# device major and minor numbers and raw device ownership

ls -l /dev
}

#################################################

get_tape_drives ()
{
# Query the system for all configured tape drives

lsdev -Cc tape
}

#################################################

get_cdrom ()
{
# Query the system for all configured CD-ROM devices

lsdev -Cc cdrom
}

#################################################

get_adapters ()
{
# List all configured adapters in the system

lsdev -Cc adapter
}

#################################################

get_routes ()
{
# Save the network routes defined on the system

netstat -rn
}

#################################################

get_netstats ()
{
# Save the network adapter statistics

netstat -i
}

#################################################

get_fs_stats ()
{
# Save the file system statistics

df -k
echo "\n"
mount
echo "\n"
lsfs
echo "\n"
}

#################################################

get_VGs ()
{
# List all defined Volume Groups

lsvg | sort -r
}

#################################################

get_varied_on_VGs ()
{
# List all varied-on Volume Groups

lsvg -o | sort -r
}

#################################################

get_LV_info ()
{
# List the Logical Volumes in each varied-on Volume Group

for VG in $(get_varied_on_VGs)
do
     lsvg -l $VG
done
}

#################################################

get_paging_space ()
{
# List the paging space definitions and usage

lsps -a
echo "\n"
lsps -s
}

#################################################

get_disk_info ()
{
# List of all "hdisk"s (hard drives) on the system

lspv
}

#################################################

get_VG_disk_info ()
{
# List disks by Volume Group assignment

for VG in $(get_varied_on_VGs)
do
     lsvg -p $VG
done
}

#################################################

get_HACMP_info ()
{
# If the System is running HACMP then save the 
# HACMP configuration

if [ -x /usr/es/sbin/cluster/utilities/cllsif ]
then
     /usr/es/sbin/cluster/utilities/cllsif
     echo "\n\n"
fi

if [ -x /usr/essbin/cluster/utilities/clshowres ]
then
     /usr/es/sbin/cluster/utilities/clshowres
fi
}

#################################################

get_lparstats ()
{
# Listing of the LPAR configuration

lparstat -i
}

#################################################

get_printer_info ()
{
# Wide listing of all defined printers

lpstat -W | tail +3
}

#################################################

get_process_info ()
{
# List of all active processes

ps -ef
}

#################################################

get_sna_info ()
{
# If the system is using SNA save the SNA configuration

sna -d s               # Syntax for 2.x SNA 
if (( $? != 0 ))
then
     lssrc -s sna -l   # must be SNA 1.x
fi
}

#################################################

get_udp_x25_procs ()
{
# Listing of all "udp" and "x25" processes, if
# any are running

ps -ef | egrep 'udp|x25' | grep -v grep
}

#################################################

get_sys_cfg ()
{
# Short listing of the system configuration

lscfg
}

#################################################

get_long_sys_config ()
{
# Long detailed listing of the system configuration

lscfg -vp
}

#################################################

get_installed_filesets ()
{
# Listing of all installed LPP filesets (system installed)

lslpp -L
}

#################################################

check_for_broken_filesets ()
{
# Check the system for broken filesets

lppchk -vm3 2>&1
}

################################################

last_logins ()
{
# List the last 100 system logins

last | tail -100
}

#################################################
############## START OF MAIN  ###################
#################################################

# Check for AIX as the operating system

if [[ $(get_OS) != 'AIX' ]]
then
     echo "\nERROR: Incorrect operating system. This
       shell script is written for AIX.\n"
     echo "\n\t...EXITING...\n"
     exit 1
fi

#################################################

# Define the working directory and create this
# directory if it does not exist.

if [ ! -d $WORKDIR ]
then
     mkdir -p $WORKDIR >/dev/null 2>&1
     if (($? != 0))
     then
          echo "\nERROR: Permissions do not allow you to create the
       $WORKDIR directory. This script must exit.
       Please create the $WORKDIR directory and
       execute this script again.\n"
          echo "\n\t...EXITING...\n"
          exit 2
     fi
fi

#################################################

{   # Everything enclosed between this opening bracket and the
    # later closing bracket is both displayed on the screen and
    # also saved in the log file defined as $SYSINFO_FILE.


echo "\n\n[ $(basename $0) - $(date) ]\n"

echo "Saving system information for $THISHOST..."

echo "\nSystem:\t\t\t$(get_host)"
echo "Time Zone:\t\t$(get_TZ)"
echo "Real Memory:\t\t$(get_real_mem)" 
echo "Machine Type:\t\t$(get_arch)"
echo "Operating System:\t$(get_OS)"
echo "AIX Version Level:\t$(get_OS_level)"
echo "\nCurrent Maintenance/Technology Level:\n \
$(get_ML_for_AIX)"

echo "\n#################################################\n"
echo "Print System Configuration\n"
print_sys_config
echo "\n#################################################\n"
echo "Installed and Configured Devices\n"
get_devices
echo "\n#################################################\n"
echo "Long Device Directory Listing - /dev\n"
get_long_devdir_listing
echo "\n#################################################\n"
echo "System Tape Drives\n"
get_tape_drives
echo "\n#################################################\n"
echo "System CD-ROM Drives\n"
get_cdrom
echo "\n#################################################\n"
echo "Defined Adapters in the System\n"
get_adapters
echo "\n#################################################\n"
echo "Network Routes\n"
get_routes
echo "\n#################################################\n"
echo "Network Interface Statictics\n"
get_netstats
echo "\n#################################################\n"
echo "Filesystem Statistics\n"
get_fs_stats
echo "\n#################################################\n"
echo "Defined Volume Groups\n"
get_VGs
echo "\n#################################################\n"
echo "Varied-on Volume Groups\n"
get_varied_on_VGs
echo "\n#################################################\n"
echo "Logical Volume Information by Volume Group\n"
get_LV_info
echo "\n#################################################\n"
echo "Paging Space Information\n"
get_paging_space
echo "\n#################################################\n"
echo "Hard Disks Defined\n"
get_disk_info
echo "\n#################################################\n"
echo "Volume Group Hard Drives\n"
get_VG_disk_info
echo "\n#################################################\n"
echo "HACMP Configuration\n"
get_HACMP_info
echo "\n#################################################\n"
echo "LPAR Statistics for this host\n"
get_lparstats
echo "\n#################################################\n"
echo "Printer Information\n"
get_printer_info
echo "\n#################################################\n"
echo "Active Process List\n"
get_process_info
echo "\n#################################################\n"
echo "SNA Information\n"
get_sna_info
echo "\n#################################################\n"
echo "x25 and udp Processes\n"
get_udp_x25_procs
echo "\n#################################################\n"
echo "System Configuration Overview\n"
get_sys_cfg
echo "\n#################################################\n"
echo "Detailed System Configuration\n"
get_long_sys_config
echo "\n#################################################\n"
echo "System Installed Filesets\n"
get_installed_filesets
echo "\n#################################################\n"
echo "Looking for Broken Filesets\n"
check_for_broken_filesets
echo "\n#################################################\n"
echo "List of the last 100 users to login to $THISHOST\n"
last_logins

echo "\n\nThis report is save in: $SYSINFO_FILE \n"

# Send all output to both the screen and the $SYSINFO_FILE
# using a pipe to the "tee -a" command"

} | tee -a $SYSINFO_FILE
