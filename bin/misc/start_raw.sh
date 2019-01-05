#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user\n"
   exit 1
fi

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

echo -e "# Starting all services\n"

cd ${HOME}/misc_scripts

${HOME}/.bitcoin/bin/start.sh &
${HOME}/.komodo/bin/start.sh &

${HOME}/.bitcoin/bin/status.sh
${HOME}/.komodo/bin/status.sh

${HOME}/misc_scripts/iguana_start.sh &

sudo /etc/init.d/monit start

#find ~/ -iname debug.log -exec tail -f ${HOME}/start_raw.log ${HOME}/iguana.log {} \; | grep -i -P "err|fork" > ~/errors &
