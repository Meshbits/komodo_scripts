#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

dsatoshis='.0001'

if [[ $(bitcoin-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  /usr/local/bin/slack_alert "$(echo -n -e 'BTC utxos before split:\t'; bitcoin-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh BTC 20
  /usr/local/bin/slack_alert "$(echo -n -e 'BTC utxos after split:\t'; bitcoin-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

if [[ $(chips-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  /usr/local/bin/slack_alert "$(echo -n -e 'CHIPS utxos before split:\t'; chips-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh CHIPS 20
  /usr/local/bin/slack_alert "$(echo -n -e 'CHIPS utxos after split:\t'; chips-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

if [[ $(komodo-cli listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
  /usr/local/bin/slack_alert "$(echo -n -e 'KMD utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
  ${HOME}/misc_scripts/acsplit.sh KMD 20
  /usr/local/bin/slack_alert "$(echo -n -e 'KMD utxos after split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
fi

ASSETCHAINS_FILE="${HOME}/komodo/src/assetchains"

# Check that we can actually find '^komodo_asset' before doing anything else
if grep -P '^komodo_asset' ${ASSETCHAINS_FILE} >& /dev/null; then
  for name in $(grep -P '^komodo_asset' ${ASSETCHAINS_FILE} | awk '{ print $2 }' );
  do
    if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi

    if [[ $(komodo-cli -ac_name=${name} listunspent | grep ${dsatoshis} | wc -l) -lt 20 ]]; then
      /usr/local/bin/slack_alert \
        "$(echo -n ${name}; echo -n -e ' utxos before split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
      ${HOME}/misc_scripts/acsplit.sh ${name} 20
      /usr/local/bin/slack_alert \
        "$(echo -n ${name}; echo -n -e ' utxos after split:\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l)"
    fi
  done
fi
