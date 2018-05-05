#!/usr/bin/env bash
# Tested on Ubuntu 16.04 LTS
set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "This script needs to run as a root user\n"
   exit 1
fi

if [ -z ${1+x} ]; then
  echo "Please supply a hostname\n"
  exit 1
fi

# Setting up hostname
echo "${1}" > /etc/hostname

if grep -q '127.0.1.1' /etc/hosts; then
  sed -i "s|127\.0\.1\.1.*|127\.0\.1\.1 ${1}" /etc/hosts
else
  echo "127.0.1.1 ${1}" >> /etc/hosts
fi

hostname ${1}
