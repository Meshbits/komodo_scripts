#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains"

# Check that we can actually find '^komodo_asset' before doing anything else
if grep -P '^komodo_asset' ${ASSETCHAINS_FILE} >& /dev/null; then
  for name in $(grep -P '^komodo_asset' ${ASSETCHAINS_FILE} | awk '{ print $2 }' );
  do
    if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi
    conffile=<HOME>/.komodo/${name}/${name}.conf

    if [[ -f ${conffile} ]]; then
      echo -e "## Stop daemon: ${name} ##\n"
      <HOME>/komodo/src/komodo-cli -ac_name=${name} stop &
    fi
  done
fi

# Wait for all parallel jobs to finish
while [ 1 ]; do fg >& /dev/null; [ $? == 1 ] && break; done
