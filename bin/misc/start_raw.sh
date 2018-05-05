#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user\n"
   exit 1
fi

cd ${HOME}/misc_scripts

${HOME}/.bitcoin/bin/start.sh &
${HOME}/.chips/bin/start.sh &
${HOME}/.komodo/bin/start.sh -notary -gen &

${HOME}/.bitcoin/bin/status.sh
${HOME}/.chips/bin/status.sh
${HOME}/.komodo/bin/status.sh

${HOME}/.komodo/bin/ac_start.sh &
${HOME}/.komodo/bin/ac_status.sh

cd ${HOME}/SuperNET/iguana
git checkout dev && git pull && ./m_notary && cd ~/komodo/src && ./dpowassets
