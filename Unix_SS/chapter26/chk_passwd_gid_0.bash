#!/bin/bash
#
# SCRIPT: chk_passwd_gid_0.bash
#
# PURPOSE: This script searches the /etc/passwd
# for all non-root users who are a member of
# the system/root group, GID=0
#
###########################################
# DECLARE FILES AND VARIABLES HERE
###########################################

case $(uname) in
SunOS) alias awk=nawk
       ;;
esac

###########################################
# BEGINNING OF MAIN
###########################################

awk -F ':' '{print $1, $3}' /etc/passwd | while read U G
do
    # If the user is root skip the test
    if [ $U != 'root' ]
    then
        # Test for GID=0
        if $(id $U | grep -q 'gid=0' )
        then
            echo "WARNING: $U is a member of the root/system group"
        fi
    fi
done
