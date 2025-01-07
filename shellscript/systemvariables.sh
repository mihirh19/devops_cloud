#!/bin/bash
# 🖥️ System-defined variables.

# Print the home directory of the current user
echo "🏠 Home Directory: ${HOME}"

# Print the type of operating system
echo "🖥️ OS Type: ${OSTYPE}"

# Print the PATH variable
echo "📂 Path: $PATH"

# Print the process ID of the current shell
echo "🔢 Process ID: $$"

# Print the parent process ID
echo "🔙 Parent Process ID: ${PPID}"

# Print the present working directory
echo "📁 Current Directory: $PWD"

# Print the hostname of the machine
echo "💻 Hostname: $HOSTNAME"

# Print the user ID
echo "🆔 User ID: $UID"

# Sleep for 5 seconds
sleep 5

# Print the number of seconds since the script started
echo "⏱️ Seconds Since Start: ${SECONDS}"
