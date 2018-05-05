#!/usr/bin/env bash
set -e

source <HOME>/komodo/src/pubkey.txt
args=("$@")
seed_ip=$(getent hosts zero.kolo.supernet.org | awk '{ print $1 }')
EXTERNALIP="-externalip=<EXTERNALIP>"
ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains"

function komodo_asset () {
  <HOME>/komodo/src/komodod -pubkey=$pubkey -ac_name=$1 -ac_supply=$2 -addnode=$seed_ip -maxconnections=512 $args
}

# Check that we can actually find '^komodo_asset' before doing anything else
if grep -P '^komodo_asset' ${ASSETCHAINS_FILE} >& /dev/null; then
  for list in $(grep -P '^komodo_asset' ${ASSETCHAINS_FILE} | awk '{ print $2 ":" $3 }' );
  do
    name=$(echo $list | awk -F':' '{ print $1 }')
    supply=$(echo $list | awk -F':' '{ print $2 }')
    conffile=<HOME>/.komodo/${name}/${name}.conf

    if [[ ! -f ${conffile} ]]; then
      komodo_asset $list $supply -gen &
    else
      sed -i 's|rpcworkqueue=64|rpcworkqueue=128|' ${conffile}
      RPCPORT=$(grep 'rpcport=' ${conffile} | cut -d'=' -f2)
      if ! $( lsof -Pi :${RPCPORT} -sTCP:LISTEN -t >& /dev/null); then
        if [[ "$EXTERNALIP" = "-externalip=<EXTERNALIP>" || "$EXTERNALIP" = "-externalip=" ]]; then
          komodo_asset $list $supply -gen &
        else
          komodo_asset $list $supply "$EXTERNALIP" -gen &
        fi
      fi
    fi
    sleep 1
  done
fi
