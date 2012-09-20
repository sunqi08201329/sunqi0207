#!/bin/ksh
#
# SCRIPT: uptime_fieldtest.ksh
# AUTHOR: Randy Michael
# DATE: 07/28/2002
# PLATFORM: Any UNIX
# PURPOSE: This shell script is used to demonstrate how the 
#          average load statistics field shift depending on
#          how long it has been since the last system reboot.
#          The options are "min", "day", "hr" and combinations.
#          If all other tests fail then the system has been running
#          for 1-23 hours.

echo "\n" # Write one blank new line to the screen

# Show a current uptime output

uptime

# Find the correct field bases on how long the system has been up.

if $(uptime | grep day | grep min >/dev/null)
then
     FIELD=11
elif $(uptime | grep day | grep hr >/dev/null)
then
     FIELD=11
elif $(uptime | grep day >/dev/null)
then
     FIELD=10 
elif $(uptime | grep min >/dev/null) 
then
     FIELD=9 
else
     FIELD=8
fi

# Display the correct field.

echo "\nField is $FIELD \n"

