#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains.json"

for ((item=0; item<$(cat ${ASSETCHAINS_FILE} | jq '. | length'); item++));
do
  name=$(cat ${ASSETCHAINS_FILE} | jq -r ".[${item}] | .ac_name")
  if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi
  conffile=<HOME>/.komodo/${name}/${name}.conf

  count=0
  while [[ count -lt 180 ]]; do
    if <HOME>/komodo/src/komodo-cli -ac_name=${name} getinfo &> /dev/null; then
      getinfo=$(<HOME>/komodo/src/komodo-cli -ac_name=${name} getinfo)
      if [[ $(echo $getinfo | jq -r .longestchain) -eq $(echo $getinfo | jq -r .blocks) ]]; then
        echo -e "## assetchain in sync with the network: ${name} ##"
        break
      fi
    fi
    count=${count}+1
    sleep 1
  done&

  sleep 1
done

# Wait for all parallel jobs to finish
while [ 1 ]; do fg >& /dev/null; [ $? == 1 ] && break; done
