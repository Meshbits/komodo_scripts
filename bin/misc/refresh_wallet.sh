#!/usr/bin/env bash
set -eo pipefail

# Reference:
# https://github.com/chainstrike/nntools/blob/master/guides/Guide-FreshWallet.txt

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

# What da balance
balance=$(komodo-cli getbalance)
balance_minus_ten=$(bc <<< "$balance-10.0")

# send all but 10 komodo to VAULT_KOMODO_ADDRESS
komodo-cli sendtoaddress "${VAULT_KOMODO_ADDRESS}" ${balance_minus_ten} "" "" true

# Stop komodo and start without -gen
komodo-cli stop
komodod &; sleep 100
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

#bitcoin-cli importprivkey "Kxxx" "" false
komodo-cli importprivkey $(cat ${HOME}/.temp_sensitive/nn_komodo_key) "" false

komodod &; sleep 100
~/.komodo/bin/status.sh
~/.komodo/bin/stop.sh
~/.komodo/bin/start.sh &
