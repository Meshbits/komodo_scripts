#!/usr/bin/env bash
#set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

dsatoshis='0.00010000'
dsatoshis_gamecredits='0.00100000'
dsatoshis_einsteinium='0.00100000'

echo -n "BTC total utxos:"; echo -n -e ' \t'; bitcoin-cli listunspent | grep -c "amount"
echo -n "BTC notarisation utxos:"; echo -n -e ' \t'; bitcoin-cli listunspent | grep -c "${dsatoshis},"

echo -n "KMD total utxos:"; echo -n -e ' \t'; komodo-cli listunspent | grep -c "amount"
echo -n "KMD notarisation utxos:"; echo -n -e ' \t'; komodo-cli listunspent | grep -c "${dsatoshis},"

echo -n "Chips total utxos:"; echo -n -e ' \t'; chips-cli listunspent | grep -c "amount"
echo -n "Chips notarisation utxos:"; echo -n -e ' \t'; chips-cli listunspent | grep -c "${dsatoshis},"

echo -n "VRSC total utxos:"; echo -n -e ' \t'; ${HOME}/veruscoin/src/komodo-cli -ac_name=VRSC listunspent | grep -c "amount"
echo -n "VRSC notarisation utxos:"; echo -n -e ' \t'; ${HOME}/veruscoin/src/komodo-cli -ac_name=VRSC listunspent | grep -c "${dsatoshis},"

echo -n "HUSH total utxos:"; echo -n -e ' \t'; hush-cli listunspent | grep -c "amount"
echo -n "HUSH notarisation utxos:"; echo -n -e ' \t'; hush-cli listunspent | grep -c "${dsatoshis},"

echo -n "Gamecredits total utxos:"; echo -n -e ' \t'; gamecredits-cli listunspent | grep -c "amount"
echo -n "Gamecredits notarisation utxos:"; echo -n -e ' \t'; gamecredits-cli listunspent | grep -c "${dsatoshis_gamecredits},"

echo -n "Einsteinium total utxos:"; echo -n -e ' \t'; ${HOME}/einsteinium/src/einsteinium-cli listunspent | grep -c "amount"
echo -n "Einsteinium notarisation utxos:"; echo -n -e ' \t'; ${HOME}/einsteinium/src/einsteinium-cli listunspent | grep -c "${dsatoshis_einsteinium},"

echo -n "Gincoin total utxos:"; echo -n -e ' \t'; ${HOME}/gin/src/gincoin-cli listunspent | grep -c "amount"
echo -n "Gincoin notarisation utxos:"; echo -n -e ' \t'; ${HOME}/gin/src/gincoin-cli listunspent | grep -c "${dsatoshis},"

ignore_list=(
VOTE2018
PIZZA
BEER
CCL
)

# Only assetchains
${HOME}/komodo/src/listassetchains | while read list; do
  if [[ "${ignore_list[@]}" =~ "${list}" ]]; then continue; fi
  echo -n "${list} total utxos:"; echo -n -e ' \t'; komodo-cli -ac_name=${list} listunspent | grep -c "amount"
  echo -n "${list} notarisation utxos:"; echo -n -e ' \t'; komodo-cli -ac_name=${list} listunspent | grep -c "${dsatoshis},"
done
