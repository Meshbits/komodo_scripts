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
  func_nn_connect | while read variable
  do
    nc -zn -w2 ${variable} 17775 || echo "Unable to connect to ${variable}" &
  done
}

function nn_ufw() {
  func_nn_connect | while read variable
  do
    sudo grep ${variable} /var/log/ufw.log | uniq
  done
}

#watch -x bash -c "source ~/misc_scripts/network_functions.sh; nn_ping"
