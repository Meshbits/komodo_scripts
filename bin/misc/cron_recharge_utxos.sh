#!/usr/bin/env bash
#set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

lockfile -r 0 /tmp/the.cron.lock || exit 1

dsatoshis='0.00010000'
dsatoshis_gamecredits='0.00100000'
dsatoshis_einsteinium='0.00100000'

print_txid () {
  echo -n $(echo "$1" | jq .txid)
}

var_coin=BTC
var_value=25
if [[ $(bitcoin-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  echo -e "\n${var_coin} Split"
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
  #/usr/local/bin/slack_alert testing "$(echo -n -e \"${var_coin} utxos after split:\t\"; bitcoin-cli listunspent | grep -c \"${dsatoshis},\")"
fi

var_coin=KMD
var_value=100
if [[ $(komodo-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  echo -e "\n${var_coin} Split"
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=CHIPS
var_value=25
if [[ $(chips-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  echo -e "\n${var_coin} Split"
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=VRSC
var_value=25
if [[ $(${HOME}/veruscoin/src/komodo-cli -ac_name=VRSC listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  echo -e "\n${var_coin} Split"
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=KMDICE
var_value=25
if [[ $(${HOME}/kmdice/src/komodo-cli -ac_name=KMDICE listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  echo -e "\n${var_coin} Split"
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=HUSH
var_value=25
if [[ $(hush-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  echo -e "\n${var_coin} Split"
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
  print_txid "$RESULT"
fi

var_coin=GAME
var_value=10
for ((item=0; item<${var_value}; item++));
do
  if [[ $(gamecredits-cli listunspent | grep -c "${dsatoshis_gamecredits},") -lt ${var_value} ]]; then
    echo -e "\n${var_coin} Split"
    RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${item} 100000)"
    print_txid "$RESULT"
  else
    break
    rm -f
  fi
done &

var_coin=EMC2
var_value=25
if [[ $(${HOME}/einsteinium/src/einsteinium-cli listunspent | grep -c "${dsatoshis_einsteinium},") -lt ${var_value} ]]; then
  echo -e "\n${var_coin} Split"
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value} 100000)"
  print_txid "$RESULT"
fi

ignore_list=(
VOTE2018
PIZZA
BEER
KMDICE
)

# Only assetchains
var_value=25
${HOME}/komodo/src/listassetchains | while read item; do
  if [[ "${ignore_list[@]}" =~ "${item}" ]]; then
    continue
  fi

  if [[ $(komodo-cli -ac_name=${item} listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
    #/usr/local/bin/slack_alert testing \
    #  "$(echo -n ${name}; echo -n -e ' utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
    echo -e "${item} Split"
    RESULT="$(${HOME}/misc_scripts/acsplit.sh ${item} ${var_value})"
    print_txid "$RESULT"
  fi
done

rm -f /tmp/the.cron.lock
