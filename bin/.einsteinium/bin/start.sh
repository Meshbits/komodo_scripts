#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

if ! $( lsof -Pi :<VAR_RPCPORT> -sTCP:LISTEN -t >& /dev/null); then
  echo -e "## Start <VAR_THING> daemon ##\n"
  <VAR_SRC_DIR>/src/<VAR_THING>d -conf=<VAR_CONF_FILE> ${EINSTEINIUM_STARTUP_OPTIONS} &>> <VAR_CONF_DIR>/log/daemon.log
fi
