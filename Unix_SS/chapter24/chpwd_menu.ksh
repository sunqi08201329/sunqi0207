#!/usr/bin/ksh
#
# SCRIPT: chpwd_menu.ksh
# AUTHOR: Randy Michael
# DATE: 11/05/2007
# PLATFORM: AIX
# REV: 1.1.P
#
# PURPOSE: This script was created for the Operations Team
#          to change user passwords. This shell script uses
#          "sudo" to execute the "pwdadm" command as root.
#          Each member of the Operations Team needs to be
#          added to the /etc/sudoers file. CAUTION: When
#          editing the /etc/sudoers file always use the
#          /usr/local/sbin/visudo program editor!!!
#          NEVER DIRECTLY EDIT THE sudoers FILE!!!!
#
# REV LIST:
#
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check syntax without any execution
#
#######################################################
#         DEFINE FUNCTIONS HERE
#######################################################

function chg_pwd
{
USER_NAME="$1"

echo "\nWhen prompted for a password use YOUR NORMAL PASSWORD"
echo "NOT the new password...\n"

# The next command turns off the checking of the password history

/usr/local/bin/sudo /usr/bin/pwdadm -f NOCHECK $USER_NAME
if [ $? -ne 0 ]
then
        echo "\nERROR: Turning off password history failed..."
        usage
        exit 1
fi

# The next command changes the user's password

/usr/local/bin/sudo /usr/bin/pwdadm $USER_NAME
if [ $? -ne 0 ]
then
        echo "\nERROR: Changing $USER_NAME password failed..."
        usage
        exit 1
fi

# The next command forces the user to change his or her password
# at the next login.

/usr/local/bin/sudo /usr/bin/pwdadm -f ADMCHG $USER_NAME

return 0
}

#######################################################
#                   START OF MAIN
#######################################################

case $(uname) in
AIX) :  # Do nothing
     ;;
  *) echo "ERROR: This script only works on AIX...EXITING..."
     exit 10
     ;;
esac

OPT=0      # Initialize to zero

clear      # Clear the screen

while [[ $OPT != 99 ]] # Start a loop
do

# Draw reverse image bar across the top of the screen
# with the system name.

clear
tput smso
echo "                          `hostname`                      "
tput sgr0
echo ""

# Draw menu options.

echo "\n\n\n\n\n\n\n"

print "10. Change Password"

echo "\n\n\n\n\n\n\n\n\n"

print "99. Exit Menu"

# Draw reverse image bar across bottom of screen,
# with error message, if any.

tput smso
echo "             $MSG                    "
tput sgr0

# Prompt for menu option.

read OPT

# Assume invalid selection was taken.  Message is always
# displayed, so blank it out when a valid option is selected.

MSG="       Invalid option selected         "
# Option 10 - Change Password

if [ $OPT -eq 10 ]
then
        echo "\nUsername for password change? \c"
        read USERNAME
        grep $USERNAME /etc/passwd >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
              chg_pwd $USERNAME
              if [ $? -eq 0 ]
              then
                   MSG="$USERNAME password successfully changed"
              else
                   MSG="ERROR: $USERNAME password change failed"
              fi
        else
              MSG="   ERROR: Invalid username $USERNAME   "
        fi      
fi

# End of Option 99 Loop

done

# Erase menu from screen upon exiting.

clear
