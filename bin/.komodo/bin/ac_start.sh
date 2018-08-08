#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"
[[ -f "${HOME}/komodo/src/pubkey.txt" ]] && source "${HOME}/komodo/src/pubkey.txt"

# Running Komodo assetchains create files which I'd like to keep contained hence cd'ing to komodo
cd <HOME>/komodo
seed_ip=$(getent hosts zero.kolo.supernet.org | awk '{ print $1 }')
EXTERNALIP="-externalip=<EXTERNALIP>"
ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains.json"

function komodo_asset () {
  <HOME>/komodo/src/komodod -ac_name=$1 -ac_supply=$2 -addnode=$seed_ip -maxconnections=512 ${KOMODO_ASSETCHAINS_STARTUP_OPTIONS} \
    >& ${HOME}/.komodo/log/${name}.log
}

for ((item=1; item<$(cat ${ASSETCHAINS_FILE} | jq '. | length'); item++)); do
do
  name=$(cat ${ASSETCHAINS_FILE} | jq -r ".[${item}] | .ac_name")

  if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi

  supply=$(cat ${ASSETCHAINS_FILE} | jq -r ".[${item}] | .ac_supply")
  conffile=<HOME>/.komodo/${name}/${name}.conf

  if [[ -f ${conffile} ]]; then
    komodo_asset ${name} ${supply} &
  else
    sed -i 's|rpcworkqueue=64|rpcworkqueue=256|' ${conffile}
    RPCPORT=$(grep 'rpcport=' ${conffile} | cut -d'=' -f2)
    if ! $( lsof -Pi :${RPCPORT} -sTCP:LISTEN -t >& /dev/null); then
      if [[ "${EXTERNALIP}" = "-externalip=<EXTERNALIP>" || "${EXTERNALIP}" = "-externalip=" ]]; then
        komodo_asset ${name} ${supply} &
      else
        komodo_asset ${name} ${supply} "${EXTERNALIP}" &
      fi
    fi
  fi
  sleep 1
done

# Go back to the previous directory
cd - >& /dev/null
