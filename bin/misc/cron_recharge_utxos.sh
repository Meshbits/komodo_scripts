#!/usr/bin/env bash
#set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

dsatoshis='0.00010000'
dsatoshis_gamecredits='0.00100000'
dsatoshis_einsteinium='0.00100000'

if [[ $(bitcoin-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  echo -e "\nBTC Split"
  ${HOME}/misc_scripts/acsplit.sh BTC 20
  #/usr/local/bin/slack_alert testing "$(echo -n -e 'BTC utxos after split:\t'; bitcoin-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

if [[ $(chips-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  echo -e "\nChips Split"
  ${HOME}/misc_scripts/acsplit.sh CHIPS 20
fi

if [[ $(komodo-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  echo -e "\nKomodo Split"
  ${HOME}/misc_scripts/acsplit.sh KMD 20
fi

if [[ $(${HOME}/veruscoin/src/komodo-cli -ac_name=VRSC listunspent | grep ${dsatoshis} | wc -l) -lt 10 ]]; then
  echo -e "\nVeruscoin Split"
  ${HOME}/misc_scripts/acsplit.sh VRSC 20
fi

if [[ $(hush-cli listunspent | grep ${dsatoshis} | wc -l) -lt 10 ]]; then
  echo -e "\HushCoin Split"
  ${HOME}/misc_scripts/acsplit.sh HUSH 20
fi

if [[ $(gamecredits-cli listunspent | grep ${dsatoshis_gamecredits} | wc -l) -lt 20 ]]; then
  echo -e "\nGamecredits Split"
  ${HOME}/misc_scripts/acsplit.sh GAME 10 100000
fi

if [[ $(${HOME}/einsteinium/src/einsteinium-cli listunspent | grep ${dsatoshis_einsteinium} | wc -l) -lt 10 ]]; then
  echo -e "\nEinsteinium Split"
  ${HOME}/misc_scripts/acsplit.sh EMC2 20 100000
fi

ASSETCHAINS_FILE="${HOME}/komodo/src/assetchains.json"

for ((item=0; item<$(cat ${ASSETCHAINS_FILE} | jq '. | length'); item++));
do
  name=$(cat ${ASSETCHAINS_FILE} | jq -r ".[${item}] | .ac_name")
  if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi

  if [[ $(komodo-cli -ac_name=${name} listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
    #/usr/local/bin/slack_alert testing \
    #  "$(echo -n ${name}; echo -n -e ' utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
    echo -e "${name} Split"
    ${HOME}/misc_scripts/acsplit.sh ${name} 20
  fi
done
