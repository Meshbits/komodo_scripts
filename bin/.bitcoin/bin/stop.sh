#!/usr/bin/env bash
set -e

echo -e "## Stop bitcoin daemon ##\n"
sudo -H -u <VAR_USERNAME> /bin/bash -c \
  "<VAR_SRC_DIR>/src/bitcoin-cli -conf=<VAR_CONF_FILE> stop"

while inotifywait -e modify -t 60 <VAR_CONF_DIR>/debug.log; do
  if tail -n10 <VAR_CONF_DIR>/debug.log | grep 'Shutdown: done'; then
    echo -e "## bitcoin daemon has been shutdown ##\n"
    break
  fi
done
