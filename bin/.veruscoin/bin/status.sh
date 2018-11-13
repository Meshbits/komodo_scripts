#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

count=0
while [[ ${count} -lt 300 ]]; do
  if <VAR_SRC_DIR>/src/komodo-cli -ac_name=VRSC getinfo >& /dev/null; then
    getinfo="$(<VAR_SRC_DIR>/src/komodo-cli -ac_name=VRSC getinfo)"
    if [[ $(echo ${getinfo} | jq -r .longestchain) -eq $(echo ${getinfo} | jq -r .blocks) ]]; then
      echo -e "## <VAR_THING> blockchain in sync with the network ##"
      break
    else
      if [[ ${count} -eq 299 ]]; then
        echo -e "## assetchain not in sync with the network: <VAR_THING> ##"
        echo -e "Longestchain: $(echo ${getinfo} | jq -r .longestchain)"
        echo -e "Blocks: $(echo ${getinfo} | jq -r .blocks)\n"
        break
      fi
    fi
  fi
  count=${count}+1
  sleep 1
done
