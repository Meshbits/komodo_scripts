#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user with sudo privileges\n"
   exit 1
fi

# Variables
SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)

# Sync all the scripts
rsync -a "${SCRIPTPATH}/misc/" "${HOME}/misc_scripts/"

# Sync profile.d
sudo rsync -a "${SCRIPTPATH}/profile.d/meshbits" "/etc/profile.d/"

# Start everything after system reboot
if ! grep 'misc_scripts/start_raw.sh' /etc/rc.local; then
  sudo sed -i '1 a exec 2> /tmp/rc.local.log      # send stderr from rc.local to a log file' /etc/rc.local
  sudo sed -i '2 a exec 1>&2                      # send stdout to the same log file' /etc/rc.local
  sudo sed -i '3 a set -x                         # tell sh to display commands before execution' /etc/rc.local
  sudo sed -i "$ i /usr/local/bin/sudo_wrapper \"/home/${USER}/misc_scripts/start_raw.sh &>> /home/${USER}/start_raw.log\"" /etc/rc.local
fi
