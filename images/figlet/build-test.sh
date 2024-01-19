#!/usr/bin/env sh
set -eu
#set -x

# Do some tests and exit with either 0 for success or 1 for error
figlet -v | grep -A 2 'FIGlet Copyright'  || exit 1

exit 0
