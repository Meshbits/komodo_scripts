#!/usr/bin/env bash

#sudo apt -y install parellel
#parallel --gnu ping -c1 ::: `dig +trace google.com|ipx`

function nn_ping() {
  grep NN_CONNECT ${HOME}/start_raw.log \
    | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+' | uniq \
    | while read variable
  do
    nc -zn -w2 ${variable} 17775 || echo "Unable to connect to ${variable}"
  done
}

function nn_ufw() {
  grep NN_CONNECT ${HOME}/start_raw.log \
    | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+' | uniq \
    | while read variable
  do
    sudo grep ${variable} /var/log/ufw.log | uniq
  done
}
