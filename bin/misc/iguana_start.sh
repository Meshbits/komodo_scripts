#!/usr/bin/env bash

rm -f "${HOME}/iguana.log"
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
git checkout ${IGUANA_BRANCH}
git stash
git pull

if ! pgrep iguana >& /dev/null; then
  git stash pop
  ${HOME}/misc_scripts/iguana/m_notary "" notary_nosplit
  ${HOME}/misc_scripts/dpowassets

  sleep 200
  if ! pgrep dpowassets >& /dev/null; then
    ${HOME}/misc_scripts/dpowassets
  fi
fi

if ! pgrep dpowassets >& /dev/null; then
  ${HOME}/misc_scripts/dpowassets
fi
