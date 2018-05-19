#!/usr/bin/env bash
IFS=

echo 'coinlist=(' > coinlist
for list in $(grep -P '^komodo_asset' ${HOME}/komodo/src/assetchains | awk '{ print $2 " " $3 }' ); do
  name=$(echo ${list} | cut -d' ' -f1)
  if [[ ${name} == "BEER" || ${name} == "PIZZA" || ${name} == "VOTE2018" ]]; then continue; fi
  echo ${list} | sed -e "s/.*/'&'/"  >> coinlist
done
echo ')' >> coinlist
