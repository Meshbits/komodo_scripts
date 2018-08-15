#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

dsatoshis='.00010000'
dsatoshis_gamecredits='.00100000'

if [[ $(bitcoin-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  /usr/local/bin/slack_alert testing "$(echo -n -e 'BTC utxos before split:\t'; bitcoin-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh BTC 20
  /usr/local/bin/slack_alert testing "$(echo -n -e 'BTC utxos after split:\t'; bitcoin-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

if [[ $(chips-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  /usr/local/bin/slack_alert testing "$(echo -n -e 'CHIPS utxos before split:\t'; chips-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh CHIPS 20
  /usr/local/bin/slack_alert testing "$(echo -n -e 'CHIPS utxos after split:\t'; chips-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

if [[ $(gamecredits-cli listunspent | grep ${dsatoshis_gamecredits} | wc -l) -lt 20 ]]; then
  /usr/local/bin/slack_alert testing "$(echo -n -e 'GameCredits utxos before split:\t'; gamecredits-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh GAME 10 100000
  /usr/local/bin/slack_alert testing "$(echo -n -e 'GameCredits utxos after split:\t'; gamecredits-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

if [[ $(komodo-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  /usr/local/bin/slack_alert testing "$(echo -n -e 'KMD utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh KMD 20
  /usr/local/bin/slack_alert testing "$(echo -n -e 'KMD utxos after split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

if [[ $(${HOME}/veruscoin/src/komodo-cli -ac_name=VRSC listunspent | grep ${dsatoshis} | wc -l) -lt 10 ]]; then
  /usr/local/bin/slack_alert testing "$(echo -n -e 'VRSC utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh VRSC 20
  /usr/local/bin/slack_alert testing "$(echo -n -e 'VRSC utxos after split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
fi


ASSETCHAINS_FILE="<HOME>/komodo/src/assetchains.json"

for ((item=0; item<$(cat ${ASSETCHAINS_FILE} | jq '. | length'); item++));
do
  name=$(cat ${ASSETCHAINS_FILE} | jq -r ".[${item}] | .ac_name")
  if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi

  if [[ $(komodo-cli -ac_name=${name} listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
    /usr/local/bin/slack_alert testing \
      "$(echo -n ${name}; echo -n -e ' utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
    ${HOME}/misc_scripts/acsplit.sh ${name} 20
    /usr/local/bin/slack_alert testing \
      "$(echo -n ${name}; echo -n -e ' utxos after split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
  fi
done
