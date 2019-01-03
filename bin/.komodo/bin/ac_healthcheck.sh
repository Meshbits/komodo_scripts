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
  if [[ "${ignore_list[@]}" =~ "${item}" ]]; then continue fi
  conffile=<HOME>/.komodo/${item}/${item}.conf

  if [[ -f ${conffile} ]]; then
    RPCPORT=$(grep 'rpcport=' ${conffile} | cut -d'=' -f2)
    RPCUSER=$(grep 'rpcuser=' ${conffile} | cut -d'=' -f2)
    RPCPASSWORD=$(grep 'rpcpassword=' ${conffile} | cut -d'=' -f2)

    curl_output=$(curl --user ${RPCUSER}:${RPCPASSWORD} --data-binary \
    '{"jsonrpc": "1.0", "id":"curltest", "method": "getinfo", "params": [] }' \
    -H 'content-type: text/plain;' http://127.0.0.1:${RPCPORT}/ 2> /dev/null \
    | jq -r .result.testnet)

    if ! [[ ${curl_output} == 'false' ]]; then
      echo -e "## echo assetchain ${item} not running##\n"
      exit 1
    fi
  fi
done
