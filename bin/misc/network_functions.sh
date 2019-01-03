#!/usr/bin/env bash

#sudo apt -y install parellel
#parallel --gnu ping -c1 ::: `dig +trace google.com|ipx`

function nn_connected_ip() {
  curl -s --url "http://127.0.0.1:7776/" --data "{\"agent\":\"dpow\",\"method\":\"ipaddrs\"}" | jq -r .[]
}

function func_nn_connect() {
  # this is probably not needed and can be replaced by nn_connected_ip()
  grep NN_CONNECT ${HOME}/start_raw.log \
    | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+' | uniq
}

function nn_ping() {
  nn_connected_ip | while read variable
  do
    nc -zn -w2 ${variable} 17775 || echo "Unable to connect to ${variable}" &
  done
}

function nn_ufw() {
  nn_connected_ip | while read variable
  do
    sudo grep ${variable} /var/log/ufw.log | uniq
  done
}

function unready_func_nn_daemon_connect() {
  # Function to allow connecting to another server to download blockchain
  komodo-cli addnode "$1"
ignore_list=(
VOTE2018
PIZZA
BEER
)

  # Only assetchains
  ${HOME}/komodo/src/listassetchains | while read list; do
    if [[ "${ignore_list[@]}" =~ "${list}" ]]; then continue; fi
    komodo-cli -ac_name=$list addnode "$1"
  done

  bitcoin-cli addnode "$1"
  chips-cli addnode "$1"
  einsteinium-cli addnode "$1"
  gamecredits-cli addnode "$1"
  hush-cli addnode "$1"
  veruscoin-cli -ac_name=VRSC addnode "$1"
}

#watch -x bash -c "source ~/misc_scripts/network_functions.sh; nn_ping"
