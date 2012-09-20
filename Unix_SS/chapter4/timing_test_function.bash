#!/bin/bash

# SCRIPT: timing_test_function.bash
# AUTHOR: Randy Michael

######## DEFINE VARIABLES HERE ########

# Ready script for ksh or bash
ECHO=echo
[[ $(basename $SHELL) == bash ]] && ECHO="echo -e"


elasped_time ()
{
SEC=$1
(( SEC < 60 )) && $ECHO "[Elasped time: $SEC seconds]\c"

(( SEC >= 60  &&  SEC < 3600 )) && $ECHO "[Elasped time: $(( SEC / 60 )) min $(( SEC % 60 )) sec]\c"

(( SEC > 3600 )) && $ECHO "[Elasped time: $(( SEC / 3600 )) hr $(( (SEC % 3600) / 60 )) min $(( (SEC % 3600) % 60 )) sec]\c" 
}

###### BEGINNING OF MAIN

SECONDS=15
elasped_time $SECONDS
$ECHO
SECONDS=60
elasped_time $SECONDS
$ECHO
SECONDS=3844
elasped_time $SECONDS
$ECHO
sleep 10
elasped_time $SECONDS
$ECHO
