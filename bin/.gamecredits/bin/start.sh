#!/usr/bin/env bash
set -e

if ! $( lsof -Pi :<VAR_RPCPORT> -sTCP:LISTEN -t >& /dev/null); then
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      -h|--help)
      cat >&2 <<HELP
Usage: start.sh [OPTIONS]
Start GameCredits
-h --help                         Show this help
HELP
      exit 0
      ;;
    esac
    shift
  done

  echo -e "## Start GameCredits daemon ##\n"
  sudo -H -u <VAR_USERNAME> /bin/bash -c \
    "<VAR_SRC_DIR>/src/gamecreditsd -conf=<VAR_CONF_FILE> -gen &>> <VAR_CONF_DIR>/log/gamecreditsd.log"
fi
