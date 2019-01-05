#!/usr/bin/env bash

sudo /etc/init.d/monit stop
~/.bitcoin/bin/stop.sh
~/.komodo/bin/stop.sh

#pkill -15 iguana
