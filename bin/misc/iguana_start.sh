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
git checkout ${IGUANA_BRANCH}
git stash
git pull
git am < "/usr/local/src/komodo_scripts/patches/only_kmd_notarisation.patch"

if ! pgrep iguana >& /dev/null; then
  ./m_notary "" notary_nosplits
  git stash pop
fi
