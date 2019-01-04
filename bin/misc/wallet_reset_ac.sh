#!/usr/bin/env bash
# Credit to Decker: https://raw.githubusercontent.com/DeckerSU/komodo_scripts/master/wallet_reset_ac.sh

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Stop monit
sudo /etc/init.d/monit stop

komodo_cli="${HOME}/komodo/src/komodo-cli"
komodo_daemon="${HOME}/komodo/src/komodod"

NN_ADDRESS=${NN_KOMODO_ADDRESS}
# you'll need only to set NN_ADDRESS, other needed info such as pubkey and privkey
# script will get automatically from daemon

# --------------------------------------------------------------------------
function init_colors() {
RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
}

# --------------------------------------------------------------------------
function log_print() {
   datetime=$(date '+%Y-%m-%d %H:%M:%S')
   echo [$datetime] $1
}

# --------------------------------------------------------------------------
function wait_for_daemon() {
  #if [[ ! -z $1 && $1 != "KMD" ]]
  if [ ! -z $1 ] && [ $1 != "KMD" ]; then
      coin=$1
      asset=" -ac_name=$1"
  else
      coin="KMD"
      asset=""
  fi

  i=0
  while ! $komodo_cli $asset getinfo >/dev/null 2>&1; do
     i=$((i+1))
     log_print "Waiting for daemon start $coin ($i)"
     sleep 5
     # TODO: in case if daemon start too long, for example, more than 5-7 mins. we should exit from script
  done
}

# --------------------------------------------------------------------------
function stop_daemon() {
  if [ ! -z $1 ] && [ $1 != "KMD" ]; then
      coin=$1
      asset=" -ac_name=$1"
  else
      coin="KMD"
      asset=""
  fi

  i=0
  $komodo_cli $asset stop

  if [ $coin == "KMD" ]; then
    ddatadir=$HOME/.komodo
  else
    ddatadir=$HOME/.komodo/$coin
  fi

  while [ -f $ddatadir/komodod.pid ]; do
     i=$((i+1))
     log_print "Waiting for daemon $coin stop ($i)"
     sleep 2
  done

  while [ ! -z $(lsof -Fp $ddatadir/.lock | head -1 | cut -c 2-) ]; do
     i=$((i+1))
     log_print "Waiting for .lock release by $coin  ($i)"
     sleep 2
  done
}

# --------------------------------------------------------------------------
function send_balance() {
  if [ ! -z $1 ] && [ $1 != "KMD" ]; then
    coin=$1
    asset=" -ac_name=$1"
  else
    coin="KMD"
    asset=""
  fi

  #echo $komodo_cli $asset getbalance with at least 1 confirmation
  BALANCE=$($komodo_cli $asset getbalance "*" 1 2>/dev/null)
  ERRORLEVEL=$?

  if [ "$ERRORLEVEL" -eq "0" ] && [ "$BALANCE" != "0.00000000" ]; then
      message=$(echo -e "(${GREEN}$coin${RESET}) $BALANCE")
      log_print "$message"
  else
      BALANCE="0.00000000"
      message=$(echo -e "(${RED}$coin${RESET}) $BALANCE")
      log_print "$message"
      exit
  fi

  # sendtoaddress
  #$komodo_cli $asset sendtoaddress $NN_ADDRESS $BALANCE "" "" true

  # redirected stderr to stdout
  RESULT=$($komodo_cli $asset sendtoaddress $NN_ADDRESS $BALANCE "" "" true 2>&1)
  ERRORLEVEL=$?
  if [ "$ERRORLEVEL" -ne "0" ]; then
    log_print "tx $RESULT"
  	exit
  fi
  log_print "txid: $RESULT"

  i=0
  confirmations=0
  while [ "$confirmations" -eq "0" ]
  do
    confirmations=$($komodo_cli $asset gettransaction $RESULT | jq .confirmations)
    i=$((i+1))
    log_print "Waiting for confirmations ($i).$confirmations"
    sleep 10
  done

  blockhash=$($komodo_cli $asset gettransaction $RESULT | jq -r .blockhash)
  height=$($komodo_cli $asset getblock $blockhash | jq .height)
}

# --------------------------------------------------------------------------
function reset_wallet() {
  if [ ! -z $1 ] && [ $1 != "KMD" ]; then
    coin=$1
    asset=" -ac_name=$1"
  else
    coin="KMD"
    asset=""
  fi

  log_print "Start reset ($coin) ..."
  wait_for_daemon $coin
  log_print "Gathering pubkey ..."
  NN_PUBKEY=$($komodo_cli $asset validateaddress $NN_ADDRESS | jq -r .pubkey)

  if [ -z $NN_PUBKEY ]; then
    log_print "Failed to obtain pubkey. Exit"
    exit
  else
    log_print "Pubkey is $NN_PUBKEY"
  fi

  log_print "Gathering privkey ..."

  NN_PRIVKEY=$($komodo_cli $asset dumpprivkey $NN_ADDRESS)
  if [ -z $NN_PRIVKEY ]; then
    log_print "Failed to obtain privkey. Exit"
    exit
  else
    log_print "Privkey is obtained"
  fi

  # disable generate to avoid daemon crash during multiple "error adding notary vin" messages
  $komodo_cli $asset setgenerate false
  sleep 5

  send_balance $coin
  log_print "ht.$height ($blockhash)"

  NN_ZADDRESS=$($komodo_cli $asset z_getnewaddress)
  NN_ZKEY=$($komodo_cli $asset z_exportkey $NN_ZADDRESS)
  log_print "New z-address $NN_ZADDRESS"

  if [ $coin == "KMD" ]; then
    daemon_args=$(ps -fC komodod | grep -v -- "-ac_name=" | grep -Po "komodod .*" | sed 's/komodod//g')
  else
    daemon_args=$(ps -fC komodod | grep -- "-ac_name=$coin" | grep -Po "komodod .*" | sed 's/komodod//g')
  fi

  log_print "($coin) Args: \"$daemon_args\""

  # TODO: check args, if we can't get arg and can't start daemon, don't need to stop it (!)

  log_print "Stopping daemon ... "
  stop_daemon $coin
  log_print "Removing old wallet ... "

  wallet_file=backup_$(date '+%Y_%m_%d_%H%M%S').dat

  if [ $coin == "KMD" ]; then
    cp $HOME/.komodo/wallet.dat $HOME/.komodo/$wallet_file
    rm $HOME/.komodo/wallet.dat
  else
    cp $HOME/.komodo/$coin/wallet.dat $HOME/.komodo/$coin/$wallet_file
    rm $HOME/.komodo/$coin/wallet.dat
  fi

  sleep 5
  log_print "Starting daemon ($coin) ... "

  # *** STARTING DAEMON ***
  $komodo_daemon $daemon_args &>> ~/wallet_reset.log &

  #$komodo_daemon -gen -notary -pubkey="$NN_PUBKEY" &

  wait_for_daemon $coin
  log_print "Importing private key ... "
  $komodo_cli $asset importprivkey $NN_PRIVKEY "" false
  log_print "Rescanning from ht.$height ... "
  $komodo_cli $asset z_importkey "${NN_ZKEY}" yes ${height}

  # Enable generation of new blocks
  $komodo_cli $asset setgenerate true 1 >& /dev/null

  log_print "Done reset ($coin)"
}

# Main
curdir=$(pwd)
init_colors

ignore_list=(
VOTE2018
PIZZA
BEER
CCL
)

# Only assetchains
${HOME}/komodo/src/listassetchains | while read list; do
  if [[ "${ignore_list[@]}" =~ "${list}" ]]; then continue; fi
  reset_wallet $list
done

# Start monit
sudo /etc/init.d/monit start
