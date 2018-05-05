#!/usr/bin/env bash
set -e

ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains"

# Check that we can actually find '^komodo_asset' before doing anything else
if grep -P '^komodo_asset' ${ASSETCHAINS_FILE} >& /dev/null; then
  for name in $(grep -P '^komodo_asset' ${ASSETCHAINS_FILE} | awk '{ print $2 }' );
  do
    conffile=<HOME>/.komodo/${name}/${name}.conf

    count=0
    while [[ count -lt 180 ]]; do
      if <HOME>/komodo/src/komodo-cli -ac_name=${name} getinfo &> /dev/null; then
        getinfo=$(<HOME>/komodo/src/komodo-cli -ac_name=${name} getinfo)
        if [[ $(echo $getinfo | jq -r .longestchain) -eq $(echo $getinfo | jq -r .blocks) ]]; then
          echo -e "$name assetchain in sync with the network"
          break
        fi
      fi
      count=${count}+1
      sleep 1
    done&

    sleep 1
  done
fi

# Wait for all parallel jobs to finish
while [ 1 ]; do fg >& /dev/null; [ $? == 1 ] && break; done
