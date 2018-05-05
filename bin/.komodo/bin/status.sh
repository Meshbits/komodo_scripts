#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

count=0
while [[ count -lt 300 ]]; do
  if "<VAR_SRC_DIR>/src/komodo-cli" getinfo >& /dev/null; then
    getinfo="$(<VAR_SRC_DIR>/src/komodo-cli getinfo)"
    if [[ $(echo ${getinfo} | jq -r .longestchain) -eq $(echo ${getinfo} | jq -r .blocks) ]]; then
      echo -e '## Komodo blockchain in sync with the network ##'
      break
    fi
  fi
  count=${count}+1
  sleep 1
done
