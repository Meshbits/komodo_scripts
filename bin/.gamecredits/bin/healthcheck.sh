#!/usr/bin/env bash
set -e

DAEMONCONF="<VAR_CONF_FILE>"
RPCUSER=$(grep 'rpcuser' $DAEMONCONF | cut -d'=' -f2)
RPCPASSWORD=$(grep 'rpcpassword' $DAEMONCONF | cut -d'=' -f2)
RPCPORT=$(grep 'rpcport' $DAEMONCONF | cut -d'=' -f2)

curl_output=$(curl --user "${RPCUSER}":"${RPCPASSWORD}" --data-binary \
'{"jsonrpc": "1.0", "id":"curltest", "method": "getnetworkinfo", "params": [] }' \
-H 'content-type: text/plain;' http://127.0.0.1:${RPCPORT}/ 2> /dev/null \
| jq -r .result.networkactive)

[[ ${curl_output} == 'true' ]] || exit 1
