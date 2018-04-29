#!/usr/bin/env bash
set -e

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
