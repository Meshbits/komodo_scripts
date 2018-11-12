#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

count=0
while [[ count -lt 300 ]]; do
  if "<VAR_SRC_DIR>/src/<VAR_THING>-cli" getinfo >& /dev/null; then
    getblockchaininfo="$(<VAR_SRC_DIR>/src/<VAR_THING>-cli getblockchaininfo)"
    if [[ $(echo ${getblockchaininfo} | jq -r .headers) -eq $(echo ${getblockchaininfo} | jq -r .blocks) ]]; then
      echo -e '## <VAR_THING> blockchain in sync with the network ##'
      break
    else
      if [[ ${count} -eq 299 ]]; then
        echo -e "## assetchain not in sync with the network: <VAR_THING> ##"
        echo -e "Headers: $(echo ${getblockchaininfo} | jq -r .headers)"
        echo -e "Blocks: $(echo ${getblockchaininfo} | jq -r .blocks)\n"
        break
      fi
    fi
  fi
  count=${count}+1
  sleep 1
done
