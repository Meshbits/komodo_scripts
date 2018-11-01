#!/usr/bin/env bash
#set -eo pipefail

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Validate variables
if [[ \
-z ${NN_KOMODO_ADDRESS+x} || \
-z ${VAULT_KOMODO_ADDRESS+x}
]]; then
  echo -e "Variable not found\n"
  exit 1
fi

function finish {
  # Enable generate
  komodo-cli setgenerate true
}
trap finish EXIT

function init_colors() {
  RESET="\033[0m"
  BLACK="\033[30m"
  RED="\033[31m"
  GREEN="\033[32m"
  YELLOW="\033[33m"
  BLUE="\033[34m"
  MAGENTA="\033[35m"
  CYAN="\033[36m"
  WHITE="\033[37m"
}

function log_print() {
  datetime=$(date '+%Y-%m-%d %H:%M:%S')
  echo [$datetime] $1
}

function send_balance() {
  ADDRESS=${1}
  BALANCE=${2}
  ERRORLEVEL=$?

  if [ "$ERRORLEVEL" -eq "0" ] && [ "$BALANCE" != "0.00000000" ]; then
    message=$(echo -e "[${GREEN}KMD${RESET}] $BALANCE")
    log_print "$message"
  else
    BALANCE="0.00000000"
    message=$(echo -e "[${RED}KMD${RESET}] $BALANCE")
    log_print "$message"
    exit
  fi

  RESULT=$(komodo-cli sendtoaddress ${1} $BALANCE "" "" true 2>&1)
  ERRORLEVEL=$?
  if [ "$ERRORLEVEL" -ne "0" ]; then
    log_print "tx $RESULT"
    exit
  fi
  log_print "txid: $RESULT"

  i=0
  confirmations=0
  while [ "$confirmations" -lt 5 ]
  do
    confirmations=$(komodo-cli gettransaction $RESULT | jq .confirmations)
    i=$((i+1))
    log_print "Waiting for confirmations ($i).$confirmations"
    sleep 5
  done
  blockhash=$(komodo-cli gettransaction $RESULT | jq -r .blockhash)
  height=$(komodo-cli getblock $blockhash | jq .height)
}

# Disable generate
komodo-cli setgenerate false

# Send funds to the vault
balance=$(komodo-cli getbalance)
balance_minus_ten=$(bc <<< "$balance-10.0")

if [[ ${balance%.*} -lt 10 ]]; then
  echo -e "\nBalance < 10 so quit. \n"
  exit 1
fi
send_balance ${VAULT_KOMODO_ADDRESS} ${balance_minus_ten}

# TODO: splitting doesn't work after above so there's a need to send myself the
# balance but for some reason daemon reports incorrect balance so need to
# experiment and find out what's an optimal figure (fees + balance) to send to
# myself
# Send {total - 0.001} funds to yourself
# balance=$(komodo-cli getbalance)
# balance_minus_fees=$(bc <<< "$balance-0.001")
# send_balance ${NN_KOMODO_ADDRESS} ${balance_minus_fees}
