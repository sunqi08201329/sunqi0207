#!/bin/bash
#
# SCRIPT: random_number_testing.bash
# AUTHOR: Randy Michael
# DATE: 8/8/2007


# For each 1K count we ger 64 lines of random numbers

dd if=/dev/urandom count=1k bs=1 2>/dev/null | od -t u2 \
   | awk '{print $2}' | sed /^$/d > 64random_numbers.txt

# For each 1M count we get 65536 lines of random numbers

dd if=/dev/urandom count=1M bs=1 2>/dev/null | od -t u2 \
   | awk '{print $2}' | sed /^$/d > 65536random_numbers.txt

# The opposite is /dev/zero which will create a null 
# file of a specific size

dd if=/dev/zero of=1MBemptyfile count=1M bs=1  2>/dev/null

