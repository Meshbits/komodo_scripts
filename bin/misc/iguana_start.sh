#!/usr/bin/env bash

LOG_FILE="${HOME}/iguana.log"
exec 3>&1 1>${LOG_FILE} 2>&1

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user\n"
   exit 1
fi

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

cd ${HOME}/SuperNET/iguana
git checkout ${IGUANA_BRANCH} && git pull

if ! pgrep iguana >& /dev/null; then
  ./m_notary "" notary_nosplit
  sed -i '/ccl/d' ${HOME}/SuperNET/iguana/m_notary_run
  sed -i '/ccl/d' ${HOME}/SuperNET/iguana/dpowassets

  sleep 120
  if ! pgrep dpowassets >& /dev/null; then
    ./dpowassets
  fi
fi

if ! pgrep dpowassets >& /dev/null; then
  ./dpowassets
fi
