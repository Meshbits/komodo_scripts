#!/usr/bin/env bash

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

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
  komodo-cli addnode "$1" "onetry"

  # Only assetchains
  ${HOME}/komodo/src/listassetchains | while read list; do
    if [[ "${ignore_list[@]}" =~ "${list}" ]]; then continue; fi
    komodo-cli -ac_name=$list addnode "$1" "onetry"
  done

  bitcoin-cli addnode "$1" "onetry"
  chips-cli addnode "$1" "onetry"
  einsteinium-cli addnode "$1" "onetry"
  gamecredits-cli addnode "$1" "onetry"
  hush-cli addnode "$1" "onetry"
  veruscoin-cli -ac_name=VRSC addnode "$1" "onetry"
}

#watch -x bash -c "source ~/misc_scripts/network_functions.sh; nn_ping"
