#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

for items in BTC_NOTARISATION_ADDRESS KMD_NOTARISATION_ADDRESS; do
  if [[ -z ${items+x} ]]; then
    echo -e "Unset variable: ${item}"
    exit 1
  fi
done

ASSETCHAINS_FILE="${HOME}/komodo/src/assetchains"

#Change to sleepytime=false if you don't want it to loop
if [[ -z ${1+x} ]]; then
  sleepytime=600
else
  sleepytime="${1}"
fi

utxoamt=0.00010000
ntrzdamt=-0.00083600

#How many transactions back to scan for notarizations
txscanamount=77777

format="%-8s %7s %6s %7s %12s\n"

outputstats ()
{
    count=0
    now=$(date +"%Y-%m-%d %T%z")

    printf "\n\n${format}" "-ASSET-" "-NTRZd-" "-UTXO-" "-BLOX-" "-BALANCE-";

    printf "$format" "BTC" \
            "$(bitcoin-cli listtransactions "" ${txscanamount} | grep ${BTC_NOTARISATION_ADDRESS} | wc -l)" \
            "$(bitcoin-cli listunspent | grep ${utxoamt} | wc -l)" \
            "$(bitcoin-cli getblockchaininfo | jq .blocks)" \
            "$(bitcoin-cli getbalance)"

    kmdinfo=$(komodo-cli getinfo)
    printf "$format" "KMD" \
            "$(komodo-cli listtransactions "" $txscanamount | grep ${KMD_NOTARISATION_ADDRESS} | wc -l)" \
            "$(komodo-cli listunspent | grep $utxoamt | wc -l)" \
            "$(echo $kmdinfo | jq .blocks )" \
            "$(echo $kmdinfo | jq .balance )" \

    chipsinfo=$(chips-cli getinfo)
    printf "$format" "CHIPS" \
            "$(chips-cli listtransactions "" $txscanamount | grep ${KMD_NOTARISATION_ADDRESS} | wc -l)" \
            "$(chips-cli listunspent | grep $utxoamt | wc -l)" \
            "$(echo $chipsinfo | jq .blocks )" \
            "$(echo $chipsinfo | jq .balance )" \

    # Check that we can actually find '^komodo_asset' before doing anything else
    if grep -P '^komodo_asset' ${ASSETCHAINS_FILE} >& /dev/null; then
      for name in $(grep -P '^komodo_asset' ${ASSETCHAINS_FILE} | awk '{ print $2 }' );
      do
        if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi
        info=$(komodo-cli -ac_name=${name} getinfo)
        txinfo=$(komodo-cli -ac_name=${name} listtransactions "" ${txscanamount})

        printf "$format" "$name" \
                "$(echo $txinfo | jq ".[].address" | grep -- ${KMD_NOTARISATION_ADDRESS} | wc -l)" \
                "$(komodo-cli -ac_name=${name} listunspent | grep ${utxoamt} | wc -l)" \
                "$(echo $info | jq .blocks )" \
                "$(echo $info | jq .balance )"
      done
    fi
    printf "$now";
}

if [[ "$sleepytime" != "false" ]]; then
  while true
  do
      outputstats
      sleep $sleepytime
  done
else
  outputstats
  echo
fi
