#!/usr/bin/env bash
set -e

count=0
while [[ count -lt 300 ]]; do
  if "<VAR_SRC_DIR>/src/gamecredits-cli" getblockchaininfo >& /dev/null; then
    getblockchaininfo="$(<VAR_SRC_DIR>/src/gamecredits-cli getblockchaininfo)"
    if [[ $(echo $getblockchaininfo | jq -r .blocks) -eq $(echo $getblockchaininfo | jq -r .headers) ]]; then
      echo -e '## GameCredits blockchain in sync with the network ##'
      break
    fi
  fi
  count=${count}+1
  sleep 1
done
