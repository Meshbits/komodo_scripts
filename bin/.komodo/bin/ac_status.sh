#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

remotecheck=$(curl -m 5 -Ssf https://komodostats.com/api/notary/summary.json)
remotecheck2=$(curl -m 5 -Ssf https://dexstats.info/api/explorerstatus.php)

ignore_list=(
VOTE2018
PIZZA
BEER
)

# Only assetchains
${HOME}/komodo/src/listassetchains | while read item; do
  if [[ "${ignore_list[@]}" =~ "${item}" ]]; then
    continue
  fi

  conffile=<HOME>/.komodo/${item}/${item}.conf

  count=0
  while [[ ${count} -lt 180 ]]; do
    if ${HOME}/komodo/src/komodo-cli -ac_name=${item} getinfo &> /dev/null; then
      getinfo=$(${HOME}/komodo/src/komodo-cli -ac_name=${item} getinfo)
      longest=$(echo $getinfo | jq -r .longestchain)
      blocks=$(echo $getinfo | jq -r .blocks)

      remoteblocks=$(echo $remotecheck | jq --arg acname ${item} '.[] | select(.ac_name==$acname) | .blocks')
      remoteblocks2=$(echo $remotecheck2 | jq --arg acname ${item} '.status[] | select(.chain==$acname) | .height | tonumber')

      diff1=$((blocks-remoteblocks))
      diff2=$((blocks-remoteblocks2))

      if ((blocks >= longest)) && \
        (( (( diff1 >= variance * -1 )) || (( diff1 <= variance )) )) && \
        (( (( diff2 >= variance * -1 )) || (( diff2 <= variance )) )); then
          break
      else
        if [[ ${count} -eq 179 ]]; then
          echo -e "## assetchain not in sync: ${item}"
          echo -e "Longestchain: ${longest}"
          echo -e "Blocks: ${blocks}\n"
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
