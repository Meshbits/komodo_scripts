#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user\n"
   exit 1
fi

echo -e "# Starting all services\n"

cd ${HOME}/misc_scripts

${HOME}/.bitcoin/bin/start.sh &
${HOME}/.komodo/bin/start.sh &
${HOME}/.komodo/bin/ac_start.sh &
${HOME}/.chips/bin/start.sh &
${HOME}/.gamecredits/bin/start.sh &

${HOME}/.bitcoin/bin/status.sh
${HOME}/.komodo/bin/status.sh
${HOME}/.komodo/bin/ac_status.sh
${HOME}/.chips/bin/status.sh
${HOME}/.gamecredits/bin/status.sh

cd ${HOME}/SuperNET/iguana
git checkout dev && git pull && ./m_notary && cd ~/komodo/src && ./dpowassets

sudo /etc/init.d/monit start
