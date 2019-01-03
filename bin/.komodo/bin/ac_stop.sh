#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

ignore_list=(
VOTE2018
PIZZA
BEER
CCL
)

${HOME}/komodo/src/listassetchains | while read item; do
  if [[ "${ignore_list[@]}" =~ "${item}" ]]; then continue; fi
  conffile=<HOME>/.komodo/${item}/${item}.conf

  if [[ -f ${conffile} ]]; then
    echo -e "## Stop daemon: ${item} ##\n"
    <HOME>/komodo/src/komodo-cli -ac_name=${item} stop &
  fi
done

# Wait for all parallel jobs to finish
while [ 1 ]; do fg >& /dev/null; [ $? == 1 ] && break; done
