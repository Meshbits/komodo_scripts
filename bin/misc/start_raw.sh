#!/usr/bin/env bash

~/.bitcoin/bin/start.sh &
~/.chips/bin/start.sh &
~/.komodo/bin/start.sh -notary -gen &

~/.bitcoin/bin/status.sh
~/.chips/bin/status.sh
~/.komodo/bin/status.sh

cd komodo/src
./assetchains &
sleep 5m
cd ~/SuperNET/iguana
git checkout dev && git pull && ./m_notary && cd ~/komodo/src && ./dpowassets
