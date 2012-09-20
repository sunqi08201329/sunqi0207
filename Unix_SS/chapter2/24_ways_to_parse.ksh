#!/usr/bin/ksh
#
# SCRIPT: 24_ways_to_parse.ksh
# AUTHOR: Randy Michael
# DATE: 08/15/2007
# REV: 2.5.Q
#
# PURPOSE: This script shows the different ways of reading
#          a file line-by-line. Again there is not just one way
#          to read a file line-by-line and some are faster than
#          others and some are more intuitive than others.
#
# REV LIST:
#
#         03/15/2007 - Randy Michael
#         Set each of the while loops up as functions and the timing
#         of each function to see which one is the fastest.
#
###############
#
#          08/10/2007 - Randy Michael
#          Modified this script to include a total of 24 functions
#          to parse a file line-by-line.
#
#######################################################################
#
# NOTE: To output the timing to a file use the following syntax:
#
#    24_ways_to_parse.ksh file_to_process > output_file_name 2>&1
#
# The actual timing data is sent to standard error, file
# descriptor (2), and the function name header is sent
# to standard output, file descriptor (1).
#
#######################################################################
#
# set -n # Uncomment to check command syntax without any execution
# set -x # Uncomment to debug this script
#

INFILE="$1"
OUTFILE=writefile.out
TIMEFILE="/tmp/loopfile.out"
>$TIMEFILE
THIS_SCRIPT=$(basename $0)

######################################
function usage
{
echo "\nUSAGE: $THIS_SCRIPT file_to_process\n"
echo "OR - To send the output to a file use: "
echo "\n$THIS_SCRIPT file_to_process > output_file_name 2>&1 \n"
exit 1
}
######################################

function verify_files
{
diff $INFILE $OUTFILE >/dev/null 2>&1
if (( $? != 0 ))
then
    echo "ERROR: $INFILE and $OUTFILE do not match"
    ls -l $INFILE $OUTFILE
fi
}
######################################

function cat_while_read_LINE
{
# Method 1

# Zero out the $OUTFILE

>$OUTFILE

cat $INFILE | while read LINE
do
    echo "$LINE" >> $OUTFILE
    :
done
}
######################################

function while_read_LINE_bottom
{
# Method 2

# Zero out the $OUTFILE

>$OUTFILE

while read LINE
do
    echo "$LINE" >> $OUTFILE
    :
done < $INFILE
}
######################################

function cat_while_LINE_line
{
# Method 3

# Zero out the $OUTFILE

>$OUTFILE

cat $INFILE | while LINE=`line`
do
    echo "$LINE" >> $OUTFILE
    :
done
}
######################################

function while_LINE_line_bottom
{
# Method 4

# Zero out the $OUTFILE

>$OUTFILE

while LINE=`line`
do
    echo "$LINE" >> $OUTFILE
    :

done < $INFILE
}
######################################

function cat_while_LINE_line_cmdsub2
{
# Method 5

# Zero out the $OUTFILE

>$OUTFILE

cat $INFILE | while LINE=$(line)
do
    echo "$LINE" >> $OUTFILE
    :
done
}
######################################

function while_LINE_line_bottom_cmdsub2
{
# Method 6

# Zero out the $OUTFILE

>$OUTFILE

while LINE=$(line)
do
    echo "$LINE" >> $OUTFILE
:
done < $INFILE
}
######################################

for_LINE_cat_FILE ()
{
# Method 7

# Zero out the $OUTFILE

>$OUTFILE

for LINE in `cat $INFILE`
do
    echo "$LINE" >> $OUTFILE
    :
done
}
######################################

for_LINE_cat_FILE_cmdsub2 ()
{
# Method 8

# Zero out the $OUTFILE

>$OUTFILE

for LINE in $(cat $INFILE)
do
    echo "$LINE" >> $OUTFILE
    :
done
}
#####################################

while_line_outfile ()
{
# Method 9

# Zero out the $OUTFILE

>$OUTFILE

# This function processes every other
# line of the $INFILE, so do not use
# this method

while read
do
    line >>$OUTFILE
    :
done < $INFILE
}
#####################################

function while_read_LINE_FD_IN
{
# Method 10

# Zero out the $OUTFILE
>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

while read LINE
do
    echo "$LINE" >> $OUTFILE
    :
done

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}
######################################

function cat_while_read_LINE_FD_OUT
{
# Method 11

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

cat $INFILE | while read LINE
do
    echo "$LINE"
    :
done

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}
######################################

function while_read_LINE_bottom_FD_OUT
{
# Method 12

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while read LINE
do
    echo "$LINE"
    :
done < $INFILE

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}
######################################

function while_LINE_line_bottom_FD_OUT
{
# Method 13

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while LINE=`line`
do
    echo "$LINE"
    :
done < $INFILE

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}
######################################

function while_LINE_line_bottom_cmdsub2_FD_OUT
{
# Method 14

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while LINE=$(line)
do
    echo "$LINE"
    :
done < $INFILE

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}
######################################

for_LINE_cat_FILE_FD_OUT ()
{
# Method 15

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

for LINE in `cat $INFILE`
do
    echo "$LINE"
    :
done

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}
######################################

for_LINE_cat_FILE_cmdsub2_FD_OUT ()
{
# Method 16

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

for LINE in $(cat $INFILE)
do
    echo "$LINE"
    :
done

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}
#####################################

while_line_outfile_FD_IN ()
{
# Method 17

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

# This function processes every other
# line of the $INFILE, so do not use
# this method

while read
do
    line >> $OUTFILE
    :
done

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}
#####################################

while_line_outfile_FD_OUT ()
{
# Method 18

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

# This function processes every other
# line of the $INFILE, so do not use
# this method

while read
do
    line
    :
done < $INFILE

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-
}
#####################################

while_line_outfile_FD_IN_AND_OUT ()
{
# Method 19

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while read
do
    line
    :
done

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}
#####################################

function while_LINE_line_FD_IN
{
# Method 20

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

while LINE=`line`
do
    echo "$LINE" >> $OUTFILE
    :
done

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}
######################################

function while_LINE_line_cmdsub2_FD_IN
{
# Method 21

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

while LINE=$(line)
do
    echo "$LINE" >> $OUTFILE
    :
done

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}
######################################

function while_read_LINE_FD_IN_AND_OUT
{
# Method 22

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while read LINE
do
    echo "$LINE"
    :
done

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}
######################################

function while_LINE_line_FD_IN_AND_OUT
{
# Method 23

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while LINE=`line`
do
    echo "$LINE"
    :
done

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}
######################################

function while_LINE_line_cmdsub2_FD_IN_AND_OUT
{
# Method 24

# Zero out the $OUTFILE

>$OUTFILE

# Associate standard input with file descriptor 3
# and redirect standard input to $INFILE

exec 3<&0
exec 0< $INFILE

# Associate standard output with file descriptor 4
# and redirect standard output to $OUTFILE

exec 4<&1
exec 1> $OUTFILE

while LINE=$(line)
do
    echo "$LINE"
    :
done

# Restore standard output and close file
# descriptor 4

exec 1<&4
exec 4>&-

# Restore standard input and close file
# descriptor 3

exec 0<&3
exec 3>&-
}

######################################
########### START OF MAIN ############
######################################

# Test the Input

# Looking for exactly one parameter
(( $# == 1 )) || usage

# Does the file exist as a regular file?
[[ -f $1 ]] || usage

echo "\nStarting File Processing of each Method\n"

echo "Method 1:"
echo "function cat_while_read_LINE"
time cat_while_read_LINE
verify_files
sleep 1
echo "\nMethod 2:"
echo "function while_read_LINE_bottom"
time while_read_LINE_bottom
verify_files
sleep 1
echo "\nMethod 3:"
echo "function cat_while_LINE_line"
time cat_while_LINE_line
verify_files
sleep 1
echo "\nMethod 4:"
echo "function while_LINE_line_bottom"
time while_LINE_line_bottom
verify_files
sleep 1
echo "\nMethod 5:"
echo "function cat_while_LINE_line_cmdsub2"
time cat_while_LINE_line_cmdsub2
verify_files
sleep 1
echo "\nMethod 6:"
echo "function while_LINE_line_botton_cmdsub2"
time while_LINE_line_bottom_cmdsub2
verify_files
sleep 1
echo "\nMethod 7:"
echo "function for_LINE_cat_FILE"
time for_LINE_cat_FILE
verify_files
sleep 1
echo "\nMethod 8:"
echo "function for_LINE_cat_FILE_cmdsub2"
time for_LINE_cat_FILE_cmdsub2
verify_files
sleep 1
echo "\nMethod 9:"
echo "function while_line_outfile"
time while_line_outfile
verify_files
sleep 1
echo "\nMethod 10:"
echo "function while_read_LINE_FD_IN"
time while_read_LINE_FD_IN
verify_files
sleep 1
echo "\nMethod 11:"
echo "function cat_while_read_LINE_FD_OUT"
time cat_while_read_LINE_FD_OUT
verify_files
sleep 1
echo "\nMethod 12:"
echo "function while_read_LINE_bottom_FD_OUT"
time while_read_LINE_bottom_FD_OUT
verify_files
sleep 1
echo "\nMethod 13:"
echo "function while_LINE_line_bottom_FD_OUT"
time while_LINE_line_bottom_FD_OUT
verify_files
sleep 1
echo "\nMethod 14:"
echo "function while_LINE_line_bottom_cmdsub2_FD_OUT"
time while_LINE_line_bottom_cmdsub2_FD_OUT
verify_files
sleep 1
echo "\nMethod 15:"
echo "function for_LINE_cat_FILE_FD_OUT"
time for_LINE_cat_FILE_FD_OUT
verify_files
sleep 1
echo "\nMethod 16:"
echo "function for_LINE_cat_FILE_cmdsub2_FD_OUT"
time for_LINE_cat_FILE_cmdsub2_FD_OUT
verify_files
sleep 1
echo "\nMethod 17:"
echo "function while_line_outfile_FD_IN"
time while_line_outfile_FD_IN
verify_files
sleep 1
echo "\nMethod 18:"
echo "function while_line_outfile_FD_OUT"
time while_line_outfile_FD_OUT
verify_files
sleep 1
echo "\nMethod 19:"
echo "function while_line_outfile_FD_IN_AND_OUT"
time while_line_outfile_FD_IN_AND_OUT
verify_files
sleep 1
echo "\nMethod 20:"
echo "function while_LINE_line_FD_IN"
time while_LINE_line_FD_IN
verify_files
sleep 1
echo "\nMethod 21:"
echo "function while_LINE_line_cmdsub2_FD_IN"
time while_LINE_line_cmdsub2_FD_IN
verify_files
sleep 1
echo "\nMethod 22:"
echo "function while_read_LINE_FD_IN_AND_OUT"
time while_read_LINE_FD_IN_AND_OUT
verify_files
sleep 1
echo "\nMethod 23:"
echo "function while_LINE_line_FD_IN_AND_OUT"
time while_LINE_line_FD_IN_AND_OUT
verify_files
sleep 1
echo "\nMethod 24:"
echo "function while_LINE_line_cmdsub2_FD_IN_AND_OUT"
time while_LINE_line_cmdsub2_FD_IN_AND_OUT
verify_files

