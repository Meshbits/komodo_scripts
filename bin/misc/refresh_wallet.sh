#!/usr/bin/env bash
set -eo pipefail

# Reference:
# https://github.com/chainstrike/nntools/blob/master/guides/Guide-FreshWallet.txt

# Pre-requisites for this script
#komodo-cli importprivkey $TEMP_komodo_private_key "temp_vault" false
#bitcoin-cli importprivkey $TEMP_bitcoin_private_key "temp_vault" false

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

function error_handler() {
  echo "Error occurred in script at line: ${1}."
  echo "Line exited with status: ${2}"
}

#trap 'error_handler ${LINENO} $?' INT TERM ERR


# Validate variables
if [[ \
-z ${NN_BITCOIN_ADDRESS+x} || \
-z ${NN_KOMODO_ADDRESS+x} || \
-z ${NN_VERUSCOIN_ADDRESS+x} || \
-z ${NN_GAMECREDITS_ADDRESS+x} || \
-z ${VAULT_KOMODO_ADDRESS+x} || \
-z ${VAULT_VERUSCOIN_ADDRESS+x} || \
-z ${VAULT_GAMECREDITS_ADDRESS+x} || \
-z ${TEMP_BITCOIN_ADDRESS+x} || \
-z ${TEMP_KOMODO_ADDRESS+x} || \
-z ${TEMP_VERUSCOIN_ADDRESS+x} || \
-z ${TEMP_GAMECREDITS_ADDRESS+x} \
]]; then
  echo -e "Variable not found\n"
  #exit 1
fi

# to-do
# Create game, veruscoin temp_address
[[ -d ${HOME}/.temp_sensitive ]] || mkdir -p ${HOME}/.temp_sensitive

# get the komodo, veruscoin, gamecredits address
#komodo-cli getaccountaddress ''
#komodo-cli getaddressesbyaccount ''

# save the privkey to a variable so we import it later
NN_bitcoin_private_key=$(bitcoin-cli dumpprivkey ${NN_BITCOIN_ADDRESS} | tee ${HOME}/.temp_sensitive/nn_bitcoin_key)
NN_komodo_private_key=$(komodo-cli dumpprivkey ${NN_KOMODO_ADDRESS} | tee ${HOME}/.temp_sensitive/nn_komodo_key)
TEMP_bitcoin_private_key=$(bitcoin-cli dumpprivkey ${TEMP_BITCOIN_ADDRESS} | tee ${HOME}/.temp_sensitive/temp_bitcoin_key)
TEMP_komodo_private_key=$(komodo-cli dumpprivkey ${TEMP_KOMODO_ADDRESS} | tee ${HOME}/.temp_sensitive/temp_komodo_key)

# What da balance
balance=$(komodo-cli getbalance)
balance_minus_ten=$(bc <<< "$balance-10.0")

echo "Balance - 10 = $balance_minus_ten"

if [[ ${balance%.*} -lt 20 ]]; then
  echo -e "\nBalance < 20 so quit. \n"
  exit 1
fi

# send all but 10 komodo to VAULT_KOMODO_ADDRESS
komodo-cli sendmany "" "{\"${VAULT_KOMODO_ADDRESS}\":\"$balance_minus_ten\"}" \
  1 "" "[\"${VAULT_KOMODO_ADDRESS}\"]"

# send all the TEMP_VAULT funds to VAULT
#temp_vault_balance=$(komodo-cli getbalance)
#temp_vault_balance_minus_trans=$(echo "$temp_vault_balance-0.001" | bc | awk '{printf "%f", $0}' )
#komodo-cli sendmany "temp_vault" "{\"${VAULT_KOMODO_ADDRESS}\":\"$temp_vault_balance_minus_trans\"}" \
#  1 "" "[\"${VAULT_KOMODO_ADDRESS}\"]"

# stop monit and all other services
~/misc_scripts/stop_raw.sh
sleep 30

# Start bitcoin and komodo
bitcoind &
komodod &
sleep 60
~/.bitcoin/bin/status.sh
~/.komodo/bin/status.sh

# send all bitcoin and komodo to TEMP_ADDRESS
bitcoin-cli sendtoaddress "${TEMP_BITCOIN_ADDRESS}" $(bitcoin-cli getbalance) "" "" true
komodo-cli sendtoaddress "${TEMP_KOMODO_ADDRESS}" $(komodo-cli getbalance) "" "" true

#send all but 10 assetchain to vault_address_komodo
#send all but 10 veruscoin to vault_address_veruscoin
#send all but 10 gamecredits to vault_address_gamecredits
#send all assetchain to temp_address_komodo
#send all veruscoin to temp_address_veruscoin
#send all gamecredits to temp_address_gamecredits

sleep 30
~/.bitcoin/bin/stop.sh
~/.komodo/bin/stop.sh

# when we'll need to move all the wallet.dat for assetchain
#for list in $(find ~/.komodo -iname wallet.dat)

mv ~/.bitcoin/wallet.dat{,_`date +%s`}
mv ~/.komodo/wallet.dat{,_`date +%s`}

# Start bitcoin and komodo
bitcoind &
komodod &
sleep 60
~/.bitcoin/bin/status.sh
~/.komodo/bin/status.sh

set +e
# Import temp_vault private key and send funds
sleep 10
bitcoin-cli importprivkey $(cat ${HOME}/.temp_sensitive/temp_bitcoin_key) "" false
komodo-cli importprivkey $(cat ${HOME}/.temp_sensitive/temp_komodo_key)
set -e

# Stop and start because komodo doesn't seem to get the balance right after the previous step
sleep 60
~/.komodo/bin/stop.sh
~/.bitcoin/bin/stop.sh
sleep 30
bitcoind &
komodod &
sleep 10
~/.bitcoin/bin/status.sh
~/.komodo/bin/status.sh

# Need for bitcoin
blockcount=$(bitcoin-cli getblockchaininfo | jq .blocks)
blockcount_minus_1000=$(echo $blockcount - 1000 | bc)
bitcoin-cli rescanblockchain ${blockcount_minus_1000} ${blockcount}

# wait and check if transactions are through yet or not
while [[ $(bitcoin-cli getbalance) == 0.00000000 ]]; do sleep 1; done

# send bitcoin and komodo from temp_vault to nn_[komodo,bitcoin]_address minus transaction fee
temp_vault_balance=$(bitcoin-cli getbalance)
#temp_vault_balance_minus_trans=$(echo "$temp_vault_balance-0.0001" | bc | awk '{printf "%f", $0}' )
bitcoin-cli sendmany "" "{\"${NN_BITCOIN_ADDRESS}\":\"$temp_vault_balance\"}" \
  1 "" "[\"${NN_BITCOIN_ADDRESS}\"]"

sleep 10

# wait and check if transactions are through yet or not
while [[ $(komodo-cli getbalance) == 0.00000000 ]]; do sleep 1; done

temp_vault_balance=$(komodo-cli getbalance)
#temp_vault_balance_minus_trans=$(echo "$temp_vault_balance-0.001" | bc | awk '{printf "%f", $0}' )
komodo-cli sendmany "" "{\"${NN_KOMODO_ADDRESS}\":\"$temp_vault_balance\"}" \
  1 "" "[\"${NN_KOMODO_ADDRESS}\"]"

sleep 30
~/.bitcoin/bin/stop.sh
~/.komodo/bin/stop.sh

sleep 30
rm ~/.bitcoin/wallet.dat
rm ~/.komodo/wallet.dat

# Start bitcoin and komodo
bitcoind &
komodod &
sleep 60
~/.bitcoin/bin/status.sh
~/.komodo/bin/status.sh

set +e
# Import NN keys
sleep 10
bitcoin-cli importprivkey $(cat ${HOME}/.temp_sensitive/temp_bitcoin_key) "" false &
komodo-cli importprivkey $(cat ${HOME}/.temp_sensitive/nn_komodo_key)
set -e

# Need for bitcoin
blockcount=$(bitcoin-cli getblockchaininfo | jq .blocks)
blockcount_minus_1000=$(echo $blockcount - 1000 | bc)
bitcoin-cli rescanblockchain ${blockcount_minus_1000} ${blockcount}

sleep 100
~/misc_scripts/stop_raw.sh
sleep 30
~/misc_scripts/start_raw.sh &>> ~/start_raw.log
sleep 30
~/misc_scripts/cron_recharge_utxos.sh
