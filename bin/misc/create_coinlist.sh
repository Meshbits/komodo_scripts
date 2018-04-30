#!/usr/bin/env bash
IFS=

echo 'coinlist=(' > coinlist
for list in $(grep -P '^komodo_asset' ${HOME}/komodo/src/assetchains | awk '{ print $2 " " $3 }' );
  do echo ${list} | sed -e "s/.*/'&'/"  >> coinlist
done
echo ')' >> coinlist
