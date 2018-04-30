#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user with sudo privileges\n"
   exit 1
fi

# Variables
SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)

# Sync all the scripts
rsync -a "${SCRIPTPATH}/misc" "${HOME}/misc_scripts"
