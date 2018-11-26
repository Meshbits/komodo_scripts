#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains.json"

for ((item=0; item<$(cat ${ASSETCHAINS_FILE} | jq '. | length'); item++));
do
  name=$(cat ${ASSETCHAINS_FILE} | jq -r ".[${item}] | .ac_name")
  if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" || ${name} == "CCL" ]]; then continue; fi
  conffile=<HOME>/.komodo/${name}/${name}.conf

  if [[ -f ${conffile} ]]; then
    echo -e "## Stop daemon: ${name} ##\n"
    <HOME>/komodo/src/komodo-cli -ac_name=${name} stop &
  fi
done

# Wait for all parallel jobs to finish
while [ 1 ]; do fg >& /dev/null; [ $? == 1 ] && break; done
