#!/usr/bin/env bash
# Setup global configuration for notary node setup
set -e

COMMON_ROOT="${HOME}/.common"
COMMON_CONFIG="${COMMON_ROOT}/config"

[[ -f "${HOME}/komodo/src/pubkey.txt" ]] && source "${HOME}/komodo/src/pubkey.txt"


[[ -d ${COMMON_ROOT} ]] || mkdir ${COMMON_ROOT}
[[ -f ${COMMON_CONFIG} ]] || touch ${COMMON_CONFIG}

function verifyvalue() {
  VARKEY="${1}"
  VARVALUE="${2}"
  if [[ ! -z "${VARVALUE+x}" ]]; then
    if ! grep -q "${VARKEY}" ${COMMON_CONFIG} >& /dev/null; then
      echo "${VARKEY}=\"${VARVALUE}\"" >> ${COMMON_CONFIG}
    fi
  fi
}

verifyvalue USERNAME ${USER}
verifyvalue EXTERNALIP ${EXTERNALIP}
# verifyvalue SLACK_CHANNEL xxxxxxxxx
# verifyvalue SLACK_USERNAME 'jalim-chucha'
# verifyvalue SLACK_URL xxxxxxxxx
# verifyvalue SLACK_EMOJI ':chicken:'

# verifyvalue BTC_NOTARISATION_ADDRESS xxxxxxxxx
# verifyvalue KMD_NOTARISATION_ADDRESS xxxxxxxxx

verifyvalue NN_BITCOIN_ADDRESS ''
verifyvalue NN_KOMODO_ADDRESS ''
verifyvalue NN_VERUSCOIN_ADDRESS ''
verifyvalue NN_GAMECREDITS_ADDRESS ''
verifyvalue VAULT_KOMODO_ADDRESS ''
verifyvalue VAULT_VERUSCOIN_ADDRESS ''
verifyvalue VAULT_GAMECREDITS_ADDRESS ''
verifyvalue TEMP_BITCOIN_ADDRESS ''
verifyvalue TEMP_KOMODO_ADDRESS ''
verifyvalue TEMP_VERUSCOIN_ADDRESS ''
verifyvalue TEMP_GAMECREDITS_ADDRESS ''


verifyvalue KOMODO_BRANCH ${KOMODO_BRANCH}
verifyvalue KOMODO_REPOSITORY ${KOMODO_REPOSITORY}
verifyvalue KOMODO_SRC_DIR ${KOMODO_SRC_DIR}
verifyvalue KOMODO_RPCPORT 7771
verifyvalue KOMODO_STARTUP_OPTIONS "-notary -pubkey=${pubkey} -gen -genproclimit=-1"
verifyvalue KOMODO_ASSETCHAINS_STARTUP_OPTIONS "-pubkey=${pubkey} -gen -genproclimit=-1"

verifyvalue BITCOIND_BRANCH ${BITCOIND_BRANCH}
verifyvalue BITCOIND_REPOSITORY ${BITCOIND_REPOSITORY}
verifyvalue BITCOIND_SRC_DIR ${BITCOIND_SRC_DIR}
verifyvalue BITCOIND_RPCPORT 8332

verifyvalue IGUANA_BRANCH ${IGUANA_BRANCH}
verifyvalue IGUANA_REPOSITORY ${IGUANA_REPOSITORY}
verifyvalue IGUANA_SRC_DIR ${IGUANA_SRC_DIR}
verifyvalue IGUANA_RPCPORT 7778

verifyvalue CHIPS_BRANCH ${CHIPS_BRANCH}
verifyvalue CHIPS_REPOSITORY ${CHIPS_REPOSITORY}
verifyvalue CHIPS_SRC_DIR ${CHIPS_SRC_DIR}
verifyvalue CHIPS_STARTUP_OPTIONS "-pubkey=${pubkey} -gen -genproclimit=1"

verifyvalue GAMECREDITS_BRANCH ${GAMECREDITS_BRANCH}
verifyvalue GAMECREDITS_REPOSITORY ${CHIPS_REPOSITORY}
verifyvalue GAMECREDITS_SRC_DIR ${GAMECREDITS_SRC_DIR}
verifyvalue GAMECREDITS_STARTUP_OPTIONS "-pubkey=${pubkey} -gen -genproclimit=1"

verifyvalue VERUSCOIN_BRANCH ${VERUSCOIN_BRANCH}
verifyvalue VERUSCOIN_REPOSITORY ${VERUSCOIN_REPOSITORY}
verifyvalue VERUSCOIN_SRC_DIR ${VERUSCOIN_SRC_DIR}
verifyvalue VERUSCOIN_STARTUP_OPTIONS "-ac_name=VRSC -ac_algo=verushash -ac_cc=1 -ac_veruspos=50 -ac_supply=0 -ac_eras=3 -ac_reward=0,38400000000,2400000000 -ac_halving=1,43200,1051920 -ac_decay=100000000,0,0 -ac_end=10080,226080,0 -ac_timelockgte=19200000000 -ac_timeunlockfrom=129600 -ac_timeunlockto=1180800 -addnode=185.25.48.236 -addnode=185.64.105.111 -pubkey=${pubkey} -gen -genproclimit=-1"

verifyvalue HUSH_STARTUP_OPTIONS "-pubkey=${pubkey} -gen -genproclimit=1"
verifyvalue EINSTEINIUM_STARTUP_OPTIONS "-pubkey=${pubkey} -gen -genproclimit=1"
