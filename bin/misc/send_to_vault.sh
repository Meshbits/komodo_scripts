#!/usr/bin/env bash
set -eo pipefail

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

function log_print() {
   datetime=$(date '+%Y-%m-%d %H:%M:%S')
   echo [$datetime] $1
}

# Validate variables
if [[ \
-z ${NN_KOMODO_ADDRESS+x} || \
-z ${VAULT_KOMODO_ADDRESS+x}
]]; then
  echo -e "Variable not found\n"
  exit 1
fi

[[ -d ${HOME}/.temp_sensitive ]] || mkdir -p ${HOME}/.temp_sensitive

# save the privkey to a variable so we import it later
echo "Saving NN kmd private key"
NN_komodo_private_key=$(komodo-cli dumpprivkey ${NN_KOMODO_ADDRESS} | tee ${HOME}/.temp_sensitive/nn_komodo_key)

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
