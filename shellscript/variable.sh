#!/bin/bash
# variable.sh
# User-defined variables.

name="Mihir"
age="20"

echo ${name}
echo "My name is ${name} and my age is ${age}"
# echo 'My name is ${name} and my age is ${age}'

work="programm"
var="ing"

# Concatenating variables
echo "I am $working"           # Undefined variable, will result in an empty output
echo "I am ${work}ing"         # Correct usage, will print "programming"
echo "I am ${work}${var}"      # Correct usage, will also print "programming"
