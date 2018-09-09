#!/usr/bin/env bash
set -eo pipefail

# Reference:
# https://github.com/chainstrike/nntools/blob/master/guides/Guide-FreshWallet.txt

# Prep for this script
#komodo-cli importprivkey $TEMP_private_key "temp_vault" false

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
-z ${NN_KOMODO_ADDRESS+x} || \
-z ${NN_VERUSCOIN_ADDRESS+x} || \
-z ${NN_GAMECREDITS_ADDRESS+x} || \
-z ${VAULT_KOMODO_ADDRESS+x} || \
-z ${VAULT_VERUSCOIN_ADDRESS+x} || \
-z ${VAULT_GAMECREDITS_ADDRESS+x} || \
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
NN_private_key=$(komodo-cli dumpprivkey ${NN_KOMODO_ADDRESS} | tee ${HOME}/.temp_sensitive/nn_komodo_key)
TEMP_private_key=$(komodo-cli dumpprivkey ${TEMP_KOMODO_ADDRESS} | tee ${HOME}/.temp_sensitive/temp_komodo_key)

# What da balance
balance=$(komodo-cli getbalance)
balance_minus_ten=$(bc <<< "$balance-10.0")

# send all but 10 komodo to VAULT_KOMODO_ADDRESS
komodo-cli sendtoaddress "${VAULT_KOMODO_ADDRESS}" ${balance_minus_ten} "" "" true

# stop monit or it'll start the nn
sudo /etc/init.d/monit stop

# Stop komodo and start without -gen
~/.komodo/bin/stop.sh
komodod &
sleep 60
~/.komodo/bin/status.sh

# send all komodo to TEMP_KOMODO_ADDRESS
komodo-cli sendtoaddress "${TEMP_KOMODO_ADDRESS}" $(komodo-cli getbalance) "" "" true

#send all but 10 assetchain to vault_address_komodo
#send all but 10 veruscoin to vault_address_veruscoin
#send all but 10 gamecredits to vault_address_gamecredits
#send all assetchain to temp_address_komodo
#send all veruscoin to temp_address_veruscoin
#send all gamecredits to temp_address_gamecredits

~/.komodo/bin/stop.sh

# when we'll need to move all the wallet.dat for assetchain
#for list in $(find ~/.komodo -iname wallet.dat)

mv ~/.komodo/{wallet.dat,_`date +%s`}

komodod &
sleep 60
~/.komodo/bin/status.sh

#bitcoin-cli importprivkey "Kxxx" "" false
komodo-cli importprivkey $(cat ${HOME}/.temp_sensitive/nn_komodo_key) "" false
komodo-cli importprivkey $(cat ${HOME}/.temp_sensitive/temp_komodo_key) "temp_vault" false

# send komodo from temp_vault to nn_komodo_address minus transaction fee
temp_vault_balance=$(komodo-cli getbalance temp_vault)
temp_vault_balance_minus_trans=$(bc <<< "$temp_vault_balance-0.001")
komodo-cli sendmany "temp_vault" "{\"${NN_KOMODO_ADDRESS}\":\"$temp_vault_balance_minus_trans\"}"

~/.komodo/bin/stop.sh
~/.komodo/bin/start.sh &

~/.komodo/bin/status.sh
~/misc_scripts/cron_recharge_utxos.sh
sudo /etc/init.d/monit start
