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
