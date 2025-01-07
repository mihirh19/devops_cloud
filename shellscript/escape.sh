#!/bin/bash

# purpose: Print some echo commands with examples of comments and escape characters.

echo "this is Mihir Hadavani" # In-line comment
echo 'this is our first                 shellscript' # Another comment

# This is another comment in the shell script.
# The following lines are commented out:
# echo -e "\033[0;31m fail message # here"
# echo -e "\033[0;32m success message # here"
# echo -e "\033[0;33m warning message here"

echo "my
name
is
mihir"

echo "
########### Script Starting ########
purpose: going to install nginx
####################################
"

# Strong quotes (single quotes):
echo 'my \
name \
is \
mihir'   # The escape character \ is taken literally due to strong quoting.

# Newline escaped:
echo " my \
name \
is \
mihir \
"

# Tab, vertical tab, and newline examples:
echo -e "this is mihir \t hadavani \t test name" # Tab
echo -e "this is mihir \v hadavani \v test name" # Vertical tab
echo -e "this is mihir  \n hadavani \n test name" # Newline
