#!/bin/bash
#
# SCRIPT: parse_record_files.bash
# AUTHOR: Randy Michael
# DATE: 12/7/2007
# REV: 1.0
# PURPOSE: This script is used to parse both
# fixed-length and variable-length record files.
# Before we parse the records we first merge the
# files into a single file for batch processing.
#
# set -n # Uncomment to check script syntax 
#        # without any execution
# set -x # Uncomment to debug
#
# REV LIST:
#
# Revised by:
# Revision date:
# Revision:
#
#
#
##########################################
# VERIFY INPUT
##########################################

if (( $# != 1 ))
then
    echo -e "\nUSAGE: $(basename $0) -f|-v"
    echo -e "\nWhere -f = fixed-length records"
    echo -e "and   -v = variable-length records\n"
    exit 1
else
    case $1 in
    -f) RECORD_TYPE=fixed
        ;;
    -v) RECORD_TYPE=variable
        ;;
     *) echo -e "\nUSAGE: $(basename $0) -f|-v"
        echo -e "\nWhere -f = fixed-length records"
        echo -e "and   -v = variable-length records\n"
        exit 1
        ;;
    esac
fi

##########################################
# DEFINE FILES AND VARIABLES HERE
##########################################

DATADIR=/data # This variable defines the directory to use for data

if [ $RECORD_TYPE = fixed ]
then
   MERGERECORDFILE=${DATADIR}/mergedrecords_fixed.$(date +%m%d%y)
   >$MERGERECORDFILE # Zero out the file to start
   RECORDFILELIST=${DATADIR}/branch_records_fixed.lst
   OUTFILE=${DATADIR}/post_processing_fixed_records.dat
   >$OUTFILE  # Zero out the file to start
else
   MERGERECORDFILE=${DATADIR}/mergedrecords_variable.$(date +%m%d%y)
   >$MERGERECORDFILE # Zero out the file to start
   RECORDFILELIST=${DATADIR}/branch_records_variable.lst
   OUTFILE=${DATADIR}/post_processing_variable_records.dat
   >$OUTFILE # Zero out the file to start
fi

# Test for Solaris to alias awk to nawk

case $(uname) in
SunOS) alias awk=nawk
       ;;
esac

FD=:  # This variable defines the field delimiter for fixed-length records

NEW_DATEDUE=01312008

##########################################

function process_fixedlength_data_new_duedate
{
# set -x
# Local positional variables
branch=$1
account=$2
name=$3
total=$4
datedue=$5
recfile=$6
new_datedue=$7

echo "${branch}${account}${name}${total}${new_datedue}${recfile}" \
      >> $OUTFILE
}

##########################################

function process_variablelength_data_new_duedate
{
# set -x
# Local positional variables
branch=$1
account=$2
name=$3
total=$4
datedue=$5
recfile=$6
new_datedue=$7

echo "${branch}${FD}${account}${FD}${name}${FD}${total}\
${FD}${new_datedue}${FD}${recfile}" >> $OUTFILE
}

##########################################

function merge_fixed_length_records
{
# set -x
while read RECORDFILENAME
do

    sed s/$/$(basename $RECORDFILENAME 2>/dev/null)/g $RECORDFILENAME >> $MERGERECORDFILE

done  < $RECORDFILELIST
}

##########################################

function merge_variable_length_records
{
# set -x
while read RECORDFILENAME
do

sed s/$/${FD}$(basename $RECORDFILENAME 2>/dev/null)/g $RECORDFILENAME >> $MERGERECORDFILE

done  < $RECORDFILELIST
}

##########################################

function parse_fixed_length_records
{
# set -x
# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while read RECORD
do
    # On each loop iteration extract the data fields
    # from the record as we process the record file
    # line by line
    BRANCH=$(echo "$RECORD" | cut -c1-6)
    ACCOUNT=$(echo "$RECORD" | cut -c7-25)
    NAME=$(echo "$RECORD" | cut -c26-45)
    TOTAL=$(echo "$RECORD" | cut -c46-70)
    DUEDATE=$(echo "$RECORD" | cut -c71-78)
    RECFILE=$(echo "$RECORD" | cut -c79-)

    # Perform some action on the data

    process_fixedlength_data_new_duedate $BRANCH $ACCOUNT $NAME \
           $TOTAL $DUEDATE $RECFILE $NEW_DATEDUE
    if (( $? != 0 ))
      then
          # Note that $LOGFILE is a global variable
          echo "Record Error: $RECORD" | tee -a $LOGFILE
    fi
done < $MERGERECORDFILE

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}

##########################################

function parse_variable_length_records
{
# set -x
# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while read RECORD
do
   # On each loop iteration extract the data fields
   # from the record as we process the record file
   # line by line

   echo $RECORD | awk -F : '{print $1, $2, $3, $4, $5, $6}' \
                | while read BRANCH ACCOUNT NAME TOTAL DATEDUE RECFILE
   do
       # Perform some action on the data

       process_variablelength_data_new_duedate $BRANCH $ACCOUNT $NAME \
               $TOTAL $DATEDUE $RECFILE $NEW_DATEDUE
       if (( $? != 0 ))
       then
           # Note that $LOGFILE is a global variable
           echo "Record Error: $RECORD" | tee -a $LOGFILE
       fi
   done

done < $MERGERECORDFILE

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}

##########################################
# BEGINNING OF MAIN
##########################################

case $RECORD_TYPE in
fixed)    merge_fixed_length_records
          parse_fixed_length_records
          ;;
variable) merge_variable_length_records
          parse_variable_length_records 
          ;;
esac
