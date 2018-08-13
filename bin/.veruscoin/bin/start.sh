#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"
[[ -f "<VAR_SRC_DIR>/src/pubkey.txt" ]] && source "<VAR_SRC_DIR>/src/pubkey.txt"

if ! $( lsof -Pi :<VAR_RPCPORT> -sTCP:LISTEN -t >& /dev/null); then
  echo -e "## Start <VAR_THING> daemon ##\n"
  <VAR_SRC_DIR>/src/komodod ${VERUSCOIN_STARTUP_OPTIONS} &>> ${HOME}/.komodo/log/<VAR_THING>.log
fi
