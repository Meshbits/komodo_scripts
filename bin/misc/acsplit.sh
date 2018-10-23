#!/usr/bin/env bash
#set -e

if [[ -z ${1+x} || -z ${2+x} ]]; then
  cat >&2 <<HELP
./acsplit KMD 50
./acsplit BTC 50
HELP
  exit 1
fi

if [[ -z ${3+x} ]]; then
  satoshis=10000
else
  satoshis=${3}
fi

curl --url "http://127.0.0.1:7776" \
  --data "{\"coin\":\""${1}"\",\"agent\":\"iguana\",\"method\":\"splitfunds\",\"satoshis\":\"${satoshis}\",\"sendflag\":1,\"duplicates\":"${2}"}"
