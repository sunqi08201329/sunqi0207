#!/bin/bash
#
# SCRIPT: select_system_info_menu.bash
# AUTHOR: Randy Michael
# DATE: 1/17/2008
# REV: 1.0
# 
# PURPOSE: This shell script uses the shell's select
# command to create a menu to show system information

# Clear the screen
clear

# Display the menu title header
echo -e "\n\tSYSTEM INFORMATION MENU\n"

# Define the menu prompt

PS3="Select an option and press Enter: "

# The select command defines what the menu
# will look like

select i in OS Host Filesystems Date Users Quit
do
   case $i in
      OS)    echo
             uname
             ;;
      Host)  echo
             hostname
             ;;
      Filesystems)
             echo
             df -k | more
             ;;
      Date)  echo
             date
             ;;
      Users) echo
             who
             ;;
      Quit)  break
             ;;
   esac

   # Setting the select command's REPLY variable
   # to NULL causes the menu to be redisplayed

   REPLY=

   # Pause before redisplaying the menu

   echo -e "\nPress Enter to Continue...\c"
   read

   # Ready to redisplay the menu again

   # clear the screen

   clear

   # Display the menu title header

   echo -e "\n\tSYSTEM INFORMATION MENU\n"

done

# Clear the screen before exiting

clear

