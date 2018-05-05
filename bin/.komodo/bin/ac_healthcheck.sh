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
    conffile="<HOME>/.komodo/${name}/${name}.conf"

    if [[ ! -f ${conffile} ]]; then
      RPCPORT=$(grep 'rpcport=' ${conffile} | cut -d'=' -f2)
      RPCUSER=$(grep 'rpcuser=' ${conffile} | cut -d'=' -f2)
      RPCPASSWORD=$(grep 'rpcpassword=' ${conffile} | cut -d'=' -f2)

      curl_output=$(curl --user ${RPCUSER}:${RPCPASSWORD} --data-binary \
      '{"jsonrpc": "1.0", "id":"curltest", "method": "getinfo", "params": [] }' \
      -H 'content-type: text/plain;' http://127.0.0.1:${RPCPORT}/ 2> /dev/null \
      | jq -r .result.testnet)

      if ! [[ ${curl_output} == 'false' ]]; then
        echo -e "## echo assetchain $name not running##\n"
        exit 1
      fi
    fi
  done
fi
