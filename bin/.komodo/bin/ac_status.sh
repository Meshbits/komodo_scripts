#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

ignore_list=(
VOTE2018
PIZZA
BEER
)

# Only assetchains
<HOME>/komodo/src/listassetchains | while read item; do
  if [[ "${ignore_list[@]}" =~ "${item}" ]]; then
    continue
  fi

  conffile=<HOME>/.komodo/${item}/${item}.conf

  count=0
  while [[ ${count} -lt 180 ]]; do
    if <HOME>/komodo/src/komodo-cli -ac_name=${item} getinfo &> /dev/null; then
      getinfo=$(<HOME>/komodo/src/komodo-cli -ac_name=${item} getinfo)
      if [[ $(echo $getinfo | jq -r .longestchain) -eq $(echo $getinfo | jq -r .blocks) ]]; then
        break
      else
        if [[ ${count} -eq 179 ]]; then
          echo -e "## assetchain not in sync with the network: ${item} ##"
          echo -e "Longestchain: $(echo $getinfo | jq -r .longestchain)"
          echo -e "Blocks: $(echo $getinfo | jq -r .blocks)\n"
          break
        fi
      fi
    fi
    count=${count}+1
    sleep 1
  done &

  sleep 1
done

# Wait for all parallel jobs to finish
while [ 1 ]; do fg >& /dev/null; [ $? == 1 ] && break; done
