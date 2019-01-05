#!/usr/bin/env bash
# Installing EMC2 on Ubuntu 16.04 LTS
# Reference: https://gist.github.com/emc2foundation/cdd1b4d7c91675f51965116257024736
set -e

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user with sudo privileges\n"
   exit 1
fi

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Functions
# Capture real time taken
function time_taken() {
  /usr/bin/time -f "## Time taken=%e\n" "$@"
}

# Variables
SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)
VAR_THING=einsteinium

# Copy monit configuration
sudo rm -f /etc/monit/conf.d/monitd_${VAR_THING}
