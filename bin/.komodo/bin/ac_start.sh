#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Running Komodo assetchains create files which I'd like to keep contained hence cd'ing to komodo
cd <HOME>/komodo

[[ -f <HOME>/komodo/src/pubkey.txt ]] || source <HOME>/komodo/src/pubkey.txt
args=("$@")
seed_ip=$(getent hosts zero.kolo.supernet.org | awk '{ print $1 }')
EXTERNALIP="-externalip=<EXTERNALIP>"
ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains"

function komodo_asset () {
  <HOME>/komodo/src/komodod -pubkey=$pubkey -ac_name=$1 -ac_supply=$2 -addnode=$seed_ip -maxconnections=512 -gen $args \
    >& ${HOME}/.komodo/log/${name}
}

# Check that we can actually find '^komodo_asset' before doing anything else
if grep -P '^komodo_asset' ${ASSETCHAINS_FILE} >& /dev/null; then
  for list in $(grep -P '^komodo_asset' ${ASSETCHAINS_FILE} | awk '{ print $2 ":" $3 }' );
  do
    name=$(echo $list | awk -F':' '{ print $1 }')
    if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi

    supply=$(echo $list | awk -F':' '{ print $2 }')
    conffile=<HOME>/.komodo/${name}/${name}.conf

    if [[ ! -f ${conffile} ]]; then
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
fi

# Go back to the previous directory
cd - >& /dev/null
