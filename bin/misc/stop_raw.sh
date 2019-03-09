#!/usr/bin/env bash

sudo /etc/init.d/monit stop
~/.bitcoin/bin/stop.sh
~/.komodo/bin/stop.sh
~/.komodo/bin/ac_stop.sh
~/.chips/bin/stop.sh
~/.gamecredits/bin/stop.sh
~/.komodo/VRSC/bin/stop.sh
~/.hush/bin/stop.sh
~/.einsteinium/bin/stop.sh
${HOME}/.gincoincore/bin/stop.sh

#pkill -15 iguana
