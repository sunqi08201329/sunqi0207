#!/bin/ksh
#
# SCRIPT: enable_AIX_classic.ksh
#
# AUTHOR: Randy Michael
# DATE: 03/14/2007
# REV: 1.1.P
#
# PLATFORM: AIX Only
#
# PURPOSE: This script is used to enable print queues on AIX systems. 
#
# REV LIST:
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to check syntax without any execution
#

for Q in $( enq -AW | tail +3 | grep DOWN | awk '{print $1}')
do
     enable $Q
     (( $? == 0 )) || echo "\n$Q print queue FAILED to enable.\n"
done

