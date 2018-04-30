#!/usr/bin/env bash

cd ${HOME}
echo -n BTC;echo -n -e ' \t\t' ;bitcoin-cli listunspent | grep .0001 | wc -l
cd ~/chips3/src
echo -n CHIPS;echo -n -e ' \t\t' ;chips-cli listunspent | grep .0001 | wc -l
cd ~/komodo/src
echo -n KMD;echo -n -e ' \t\t' ; ./komodo-cli listunspent | grep .0001 | wc -l
echo -n REVS;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=REVS listunspent | grep .0001 | wc -l
echo -n SUPERNET;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=SUPERNET listunspent | grep .0001 | wc -l
echo -n DEX;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=DEX listunspent | grep .0001 | wc -l
echo -n PANGEA;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=PANGEA listunspent | grep .0001 | wc -l
echo -n JUMBLR;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=JUMBLR listunspent | grep .0001 | wc -l
echo -n BET;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=BET listunspent | grep .0001 | wc -l
echo -n CRYPTO;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=CRYPTO listunspent | grep .0001 | wc -l
echo -n HODL;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=HODL listunspent | grep .0001 | wc -l
echo -n MSHARK;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=MSHARK listunspent | grep .0001 | wc -l
echo -n BOTS;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=BOTS listunspent | grep .0001 | wc -l
echo -n MGW;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=MGW listunspent | grep .0001 | wc -l
echo -n COQUI;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=COQUI listunspent | grep .0001 | wc -l
echo -n WLC;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=WLC listunspent | grep .0001 | wc -l
echo -n KV;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=KV listunspent | grep .0001 | wc -l
echo -n CEAL;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=CEAL listunspent | grep .0001 | wc -l
echo -n MESH;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=MESH listunspent | grep .0001 | wc -l
echo -n MNZ;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=MNZ listunspent | grep .0001 | wc -l
echo -n AXO;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=AXO listunspent | grep .0001 | wc -l
echo -n ETOMIC;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=ETOMIC listunspent | grep .0001 | wc -l
echo -n BTCH;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=BTCH listunspent | grep .0001 | wc -l
echo -n VOTE2018;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=VOTE2018 listunspent | grep .0001 | wc -l
echo -n PIZZA;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=PIZZA listunspent | grep .0001 | wc -l
echo -n BEER;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=BEER listunspent | grep .0001 | wc -l
echo -n NINJA;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=NINJA listunspent | grep .0001 | wc -l
echo -n OOT;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=OOT listunspent | grep .0001 | wc -l
echo -n BNTN;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=BNTN listunspent | grep .0001 | wc -l
echo -n CHAIN;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=CHAIN listunspent | grep .0001 | wc -l
echo -n PRLPAY;echo -n -e ' \t\t' ; ./komodo-cli -ac_name=PRLPAY listunspent | grep .0001 | wc -l
