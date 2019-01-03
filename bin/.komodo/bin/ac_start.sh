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

ignore_list=(
VOTE2018
PIZZA
BEER
CCL
)

${HOME}/komodo/src/listassetchainparams | while read args; do
  name=$(echo ${args} | awk -F '-ac_name=' '{ print $2 }' | awk '{ print $1 }')
  if [[ "${ignore_list[@]}" =~ "${name}" ]]; then continue fi

  # If a fork happens and we need to sync everything again
  # if $(echo ${name} | grep -q -P "DSEC|SEC|MGNX|COQUI|RFOX|PIRATE|GLXT" ); then
  #     ${HOME}/komodo/src/komodod $args -addnode=$seed_ip -maxconnections=512 -resync &>> /tmp/tmplogfile &
  #     sleep 1
  #     continue
  # fi
  # for list in DSEC SEC MGNX COQUI RFOX PIRATE GLXT; do ${HOME}/komodo/src/komodo-cli -ac_name=$list stop; done

  conffile=<HOME>/.komodo/${name}/${name}.conf

  if [[ ! -f ${conffile} ]]; then
    ${HOME}/komodo/src/komodod $args -addnode=$seed_ip -maxconnections=256 ${KOMODO_ASSETCHAINS_STARTUP_OPTIONS} \
      >& ${HOME}/.komodo/log/${name}.log &
  else
    sed -i 's|rpcworkqueue=64|rpcworkqueue=128|' ${conffile}
    RPCPORT=$(grep 'rpcport=' ${conffile} | cut -d'=' -f2)
    if ! $( lsof -Pi :${RPCPORT} -sTCP:LISTEN -t >& /dev/null); then
      if [[ "${EXTERNALIP}" = "-externalip=<EXTERNALIP>" || "${EXTERNALIP}" = "-externalip=" ]]; then
        ${HOME}/komodo/src/komodod $args -addnode=$seed_ip -maxconnections=256 ${KOMODO_ASSETCHAINS_STARTUP_OPTIONS} \
          >& ${HOME}/.komodo/log/${name}.log &
      else
        ${HOME}/komodo/src/komodod $args -addnode=$seed_ip -maxconnections=256 ${KOMODO_ASSETCHAINS_STARTUP_OPTIONS} \
          "${EXTERNALIP}" >& ${HOME}/.komodo/log/${name}.log &
      fi
    fi
  fi

  sleep 1
done

# Go back to the previous directory
cd - >& /dev/null
