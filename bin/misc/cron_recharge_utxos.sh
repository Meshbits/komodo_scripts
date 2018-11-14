#!/usr/bin/env bash
#set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# https://stackoverflow.com/questions/24388009/linux-flock-how-to-just-lock-a-file
LOCKFILE=/tmp/the.cron.lock
exec {lock_fd}>${LOCKFILE}
flock -x "$lock_fd"

dsatoshis='0.00010000'
dsatoshis_gamecredits='0.00100000'
dsatoshis_einsteinium='0.00100000'

print_txid () {
  echo -n $(echo "$1" | jq .txid)
}

var_coin=BTC
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(bitcoin-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
  #/usr/local/bin/slack_alert testing "$(echo -n -e \"${var_coin} utxos after split:\t\"; bitcoin-cli listunspent | grep -c \"${dsatoshis},\")"
fi

var_coin=KMD
var_value=100
echo -e "\n${var_coin} Split"
if [[ $(komodo-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
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

var_coin=VRSC
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(${HOME}/veruscoin/src/komodo-cli -ac_name=VRSC listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
	print_txid "$RESULT"
fi

var_coin=HUSH
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(hush-cli listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value})"
  print_txid "$RESULT"
fi

var_coin=GAME
var_value=10
echo -e "\n${var_coin} Split"
for ((item=0; item<${var_value}; item++));
do
  if [[ $(gamecredits-cli listunspent | grep -c "${dsatoshis_gamecredits},") -lt ${var_value} ]]; then
    RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${item} 100000)"
    print_txid "$RESULT"
  else
    break
  fi
done &

var_coin=EMC2
var_value=25
echo -e "\n${var_coin} Split"
if [[ $(${HOME}/einsteinium/src/einsteinium-cli listunspent | grep -c "${dsatoshis_einsteinium},") -lt ${var_value} ]]; then
  RESULT="$(${HOME}/misc_scripts/acsplit.sh ${var_coin} ${var_value} 100000)"
  print_txid "$RESULT"
fi

ignore_list=(
VOTE2018
PIZZA
BEER
)

# Only assetchains
var_value=25
${HOME}/komodo/src/listassetchains | while read item; do
  if [[ "${ignore_list[@]}" =~ "${item}" ]]; then
    continue
  fi

  echo -e "${item} Split"
  if [[ $(komodo-cli -ac_name=${item} listunspent | grep -c "${dsatoshis},") -lt ${var_value} ]]; then
    #/usr/local/bin/slack_alert testing \
    #  "$(echo -n ${name}; echo -n -e ' utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
    RESULT="$(${HOME}/misc_scripts/acsplit.sh ${item} ${var_value})"
    print_txid "$RESULT"
  fi
done

exec $lock_fd>&-
