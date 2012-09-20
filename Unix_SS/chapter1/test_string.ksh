#!/bin/ksh
#
#  SCRIPT: test_string.ksh
#  AUTHOR: Randy Michael
#  REV: 1.0.D  - Used for developement 
#  DATE: 10/15/2007
#  PLATFORM: Not Platform Dependent
#
#  PURPOSE: This script is used to test a character
#           string, or variable, for its composition.
#           Examples include numeric, lowercase or uppercase
#           characters, alpha-numeric characters, and IP address.
#
#  REV LIST:
#
#
# set -x # Uncomment to debug this script
# set -n # Uncomment to verify syntax without any execution.
#        # REMEMBER: Put the comment back or the script will
#        # NOT EXECUTE!
#
####################################################
############## DEFINE FUNCTIONS HERE ###############
####################################################

test_string ()
{
# This function tests a character string

# Must have one argument ($1)

if (( $# != 1 ))
then
     # This error would be a programming error

     print "ERROR: $(basename $0) requires one argument"
     return 1
fi
# Assign arg1 to the variable --> STRING

STRING=$1

# This is where the string test begins

 

case $STRING in

+([0-9]).+([0-9]).+([0-9]).+([0-9]))
         # Testing for an IP address - valid and invalid
         INVALID=FALSE

         # Separate the integer portions of the "IP" address
         # and test to ensure that nothing is greater than 255
         # or it is an invalid IP address.

         for i in $(echo $STRING | awk -F . '{print $1, $2, $3, $4}')
         do
             if (( i > 255 ))
             then
                  INVALID=TRUE
             fi
         done

         case $INVALID in
         TRUE) print 'INVALID_IP_ADDRESS'
               ;;
        FALSE) print 'VALID_IP_ADDRESS'
               ;;
         esac
         ;;
+([0-1])) # Testing for 0-1 only 
         print 'BINARY_OR_POSITIVE_INTEGER'
         ;;
+([0-7])) # Testing for 0-7  only
         print 'OCTAL_OR_POSITIVE_INTEGER'
         ;;
+([0-9])) # Check for an integer
         print 'INTEGER'
         ;;
+([-0-9])) # Check for a negative whole number
          print 'NEGATIVE_WHOLE_NUMBER'
          ;;
+([0-9]|[.][0-9]))
          # Check for a positive floating point number
          print 'POSITIVE_FLOATING_POINT'
          ;;
+(+[0-9][.][0-9]))
          # Check for a positive floating point number
          # with a + prefix
          print 'POSITIVE_FLOATING_POINT'
          ;;
+(-[0-9][.][0-9]))
          # Check for a negative floating point number
          print 'NEGATIVE_FLOATING_POINT'
          ;;
+([-.0-9]))
          # Check for a negative floating point number
          print 'NEGATIVE_FLOATING_POINT'
          ;;
+([+.0-9]))
          # Check for a positive floating point number
          print 'POSITIVE_FLOATING_POINT'
          ;;
+([a-f])) # Test for hexidecimal or all lowercase characters
         print 'HEXIDECIMAL_OR_ALL_LOWERCASE'
         ;;
+([a-f]|[0-9])) # Test for hexidecimal or all lowercase characters
         print 'HEXIDECIMAL_OR_ALL_LOWERCASE_ALPHANUMERIC'
         ;;
+([A-F])) # Test for hexidecimal or all uppercase characters
         print 'HEXIDECIMAL_OR_ALL_UPPERCASE'
         ;;
+([A-F]|[0-9])) # Test for hexidecimal or all uppercase characters
         print 'HEXIDECIMAL_OR_ALL_UPPERCASE_ALPHANUMERIC'
         ;;
+([a-f]|[A-F]))
         # Testing for hexidecimal or mixed-case characters
         print 'HEXIDECIMAL_OR_MIXED_CASE'
         ;;
+([a-f]|[A-F]|[0-9]))
         # Testing for hexidecimal/alpha-numeric strings only
         print 'HEXIDECIMAL_OR_MIXED_CASE_ALPHANUMERIC'
         ;;
+([a-z])) # Testing for all lowercase characters only
         print 'ALL_LOWERCASE'
         ;;
+([A-Z])) # Testing for all uppercase numbers only
         print 'ALL_UPPERCASE'
         ;;
+([a-z]|[A-Z])) 
         # Testing for mixed case alpha strings only
         print 'MIXED_CASE'
         ;;
+([a-z]|[A-Z]|[0-9]))
         # Testing for any alpha-numeric string only
         print 'ALPHA-NUMERIC'
         ;; 
         *) # None of the tests matched the string coposition
            print 'INVALID_STRING_COMPOSITION'
         ;;
esac
}

####################################################

usage ()
{
echo "\nERROR: Please supply one character string or variable\n"
echo "USAGE: $THIS_SCRIPT {character string or variable}\n"
}

####################################################
############# BEGINNING OF MAIN ####################
####################################################

# Query the system for the name of this shell script.
# This is used for the "usage" function.

THIS_SCRIPT=$(basename $0)

# Check for exactly one command-line argument

if (( $# != 1 ))
then
     usage
     exit 1
fi

# Everything looks okay if we got here. Assign the
# single command-line argument to the variable "STRING"

STRING=$1

# Call the "test_string" function to test the composition
# of the character string stored in the $STRING variable.

test_string $STRING

# End of script
