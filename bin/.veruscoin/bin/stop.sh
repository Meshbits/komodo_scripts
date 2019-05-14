#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

echo -e "## Stop <VAR_THING> daemon ##\n"
sudo -H -u <VAR_USERNAME> /bin/bash -c \
  "<VAR_SRC_DIR>/src/verus -ac_name=VRSC stop"

while inotifywait -e modify -t 60 <VAR_CONF_DIR>/debug.log; do
  if tail -n10 <VAR_CONF_DIR>/debug.log | grep 'Shutdown: done'; then
    echo -e "## <VAR_THING> daemon has been shutdown ##\n"
    break
  fi
done
