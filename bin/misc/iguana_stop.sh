#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user\n"
   exit 1
fi

if pgrep iguana >& /dev/null; then
  echo -e "\nStopping iguana using SIGTERM\n"
  pkill -15 iguana
fi
