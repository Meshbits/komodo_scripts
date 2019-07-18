#!/usr/bin/env bash
#set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"
[[ -f ${HOME}/misc_scripts/functions.sh ]] && . ~/misc_scripts/functions.sh

# Lock now - it depends on the functions.sh file being sourced
exlock_now || exit 1

dsatoshis='0.00010000'
dsatoshis_gamecredits='0.00100000'
dsatoshis_einsteinium='0.00100000'

print_txid () {
  echo -n $(echo "$1" | jq .txid)
}

var_coin=KMD
var_value=100
echo -e "\n${var_coin} Split"
if [[ $(komodo-cli listunspent 1 | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=CHIPS
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(chips-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=GAME
var_value=10
echo -e "\n${var_coin} Split"
if [[ $(gamecredits-cli listunspent | grep -c "${dsatoshis_gamecredits},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${item} 100000)"
  print_txid "$RESULT"
fi

var_coin=VRSC
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(${HOME}/veruscoin/src/verus -ac_name=VRSC listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=EMC2
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(${HOME}/einsteinium/src/einsteinium-cli listunspent | grep -c "${dsatoshis_einsteinium},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value} 100000)"
  print_txid "$RESULT"
fi

var_coin=GIN
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(${HOME}/gin/src/gincoin-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
  print_txid "$RESULT"
fi

unlock
