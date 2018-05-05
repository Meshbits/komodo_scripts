#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

dsatoshis='.0001'

echo -n BTC; echo -n -e ' \t\t'; bitcoin-cli listunspent | grep ${dsatoshis} | wc -l
echo -n CHIPS; echo -n -e ' \t\t'; chips-cli listunspent | grep ${dsatoshis} | wc -l
echo -n KMD; echo -n -e ' \t\t'; komodo-cli listunspent | grep ${dsatoshis} | wc -l

ASSETCHAINS_FILE="${HOME}/komodo/src/assetchains"

# Check that we can actually find '^komodo_asset' before doing anything else
if grep -P '^komodo_asset' ${ASSETCHAINS_FILE} >& /dev/null; then
  for name in $(grep -P '^komodo_asset' ${ASSETCHAINS_FILE} | awk '{ print $2 }' );
  do
    if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi
    echo -n ${name}; echo -n -e ' \t\t'; komodo-cli -ac_name=${name} listunspent | grep ${dsatoshis} | wc -l
  done
fi
