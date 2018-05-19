#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"
[[ -f "${HOME}/komodo/src/pubkey.txt" ]] && source "${HOME}/komodo/src/pubkey.txt"

if ! $( lsof -Pi :<VAR_RPCPORT> -sTCP:LISTEN -t >& /dev/null); then
  echo -e "## Start GameCredits daemon ##\n"
  sudo -H -u <VAR_USERNAME> /bin/bash -c \
    "<VAR_SRC_DIR>/src/gamecreditsd -conf=<VAR_CONF_FILE> ${GAMECREDITS_STARTUP_OPTIONS} &>> <VAR_CONF_DIR>/log/gamecreditsd.log"
fi
