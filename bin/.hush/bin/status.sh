#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

count=0
while [[ count -lt 300 ]]; do
  if "<VAR_SRC_DIR>/src/hush-cli" getinfo >& /dev/null; then
    getinfo="$(<VAR_SRC_DIR>/src/hush-cli getblockchaininfo)"
    if [[ $(echo ${getinfo} | jq -r .headers) -eq $(echo ${getinfo} | jq -r .blocks) ]]; then
      echo -e '## hush blockchain in sync with the network ##'
      break
    fi
  fi
  count=${count}+1
  sleep 1
done
