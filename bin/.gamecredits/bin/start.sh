#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

if ! $( lsof -Pi :<VAR_RPCPORT> -sTCP:LISTEN -t >& /dev/null); then
  echo -e "## Start GameCredits daemon ##\n"
  <VAR_SRC_DIR>/src/gamecreditsd -conf=<VAR_CONF_FILE> ${GAMECREDITS_STARTUP_OPTIONS} &>> <VAR_CONF_DIR>/log/daemon.log
fi
