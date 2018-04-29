#!/usr/bin/env bash
set -e

echo -e "Stop komodod\n"
sudo -H -u <VAR_USERNAME> /bin/bash -c \
  "<VAR_SRC_DIR>/src/komodo-cli -conf=<VAR_CONF_FILE> stop"
