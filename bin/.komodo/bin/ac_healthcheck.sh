#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains.json"

for ((item=0; item<$(cat ${ASSETCHAINS_FILE} | jq '. | length'); item++));
do
  name=$(cat ${ASSETCHAINS_FILE} | jq -r ".[${item}] | .ac_name")
  if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" || ${name} == "KMDICE" ]]; then continue; fi
  conffile=<HOME>/.komodo/${name}/${name}.conf

  if [[ -f ${conffile} ]]; then
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
