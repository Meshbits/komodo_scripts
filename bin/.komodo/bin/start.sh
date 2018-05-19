#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"
[[ -f "<VAR_SRC_DIR>/src/pubkey.txt" ]] && source "<VAR_SRC_DIR>/src/pubkey.txt"

if ! $( lsof -Pi :<VAR_RPCPORT> -sTCP:LISTEN -t >& /dev/null); then
  echo -e "## Start komodo daemon ##\n"
  sudo -H -u <VAR_USERNAME> /bin/bash -c \
    "<VAR_SRC_DIR>/src/komodod -conf=<VAR_CONF_FILE> ${KOMODO_STARTUP_OPTIONS} &>> <VAR_CONF_DIR>/log/komodod.log"
fi
