#!/usr/bin/env bash

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user\n"
   exit 1
fi

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

if pgrep iguana >& /dev/null; then
  cd ${HOME}/SuperNET/iguana
  git checkout ${IGUANA_BRANCH} && git pull && ./m_notary "" notary_nosplit && ./dpowassets
fi
