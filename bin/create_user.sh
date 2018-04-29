#!/usr/bin/env bash
# Tested on Ubuntu 16.04 LTS
set -e

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a root user\n"
   exit 1
fi

if [ -z ${1+x} ]; then
  echo "Please supply a username\n"
  exit 1
fi

# Add the user if doesn't exist
id -u ${1} &>/dev/null || adduser --disabled-password --gecos "" ${1}

# sudoers entry for the user
echo "${1} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${1}
chmod 0400 /etc/sudoers.d/${1}
