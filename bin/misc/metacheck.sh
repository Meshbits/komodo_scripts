#!/usr/bin/env bash

cd ${HOME}
echo -n BTC;echo -n -e ' \t' ;echo -n "$(bitcoin-cli listunspent | grep .0001 | wc)"; bitcoin-cli getinfo | grep balance
cd ~/chips3/src
echo -n CHIPS;echo -n -e ' \t' ;echo -n "$(chips-cli listunspent | grep .0001 | wc)";chips-cli getinfo | grep balance
cd ~/komodo/src
echo -n KMD;echo -n -e ' \t'; echo -n "$(./komodo-cli listunspent | grep .0001 | wc)"; ./komodo-cli getinfo | grep balance
echo -n REVS;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=REVS listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=REVS getinfo | grep balance
echo -n SUPERNET;echo -n; echo -n "$(./komodo-cli -ac_name=SUPERNET listunspent | grep .0001 | wc)";./komodo-cli -ac_name=SUPERNET getinfo | grep balance
echo -n DEX;echo -n -e ' \t';echo -n "$( ./komodo-cli -ac_name=DEX listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=DEX getinfo | grep balance
echo -n PANGEA;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=PANGEA listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=PANGEA getinfo | grep balance
echo -n JUMBLR;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=JUMBLR listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=JUMBLR getinfo | grep balance
echo -n BET;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=BET listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=BET getinfo | grep balance
echo -n CRYPTO;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=CRYPTO listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=CRYPTO getinfo | grep balance
echo -n HODL;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=HODL listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=HODL getinfo | grep balance
echo -n MSHARK;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=MSHARK listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=MSHARK getinfo | grep balance
echo -n BOTS;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=BOTS listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=BOTS getinfo | grep balance
echo -n MGW;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=MGW listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=MGW getinfo | grep balance
echo -n COQUI;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=COQUI listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=COQUI getinfo | grep balance
echo -n WLC;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=WLC listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=WLC getinfo | grep balance
echo -n KV;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=KV listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=KV getinfo | grep balance
echo -n CEAL;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=CEAL listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=CEAL getinfo | grep balance
echo -n MESH;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=MESH listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=MESH getinfo | grep balance
echo -n MNZ;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=MNZ listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=MNZ getinfo | grep balance
echo -n AXO;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=AXO listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=AXO getinfo | grep balance
echo -n BTCH;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=BTCH listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=BTCH getinfo | grep balance
echo -n ETOMIC;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=ETOMIC listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=ETOMIC getinfo | grep balance
echo -n NINJA;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=NINJA listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=NINJA getinfo | grep balance
echo -n VOTE2018;echo -n; echo -n "$(./komodo-cli -ac_name=VOTE2018 listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=VOTE2018 getinfo | grep balance
echo -n OOT;echo -n -e ' \t'; echo -n "$(./komodo-cli -ac_name=OOT listunspent | grep .0001 | wc)"; ./komodo-cli -ac_name=OOT getinfo | grep balance
