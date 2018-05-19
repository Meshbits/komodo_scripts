#!/usr/bin/env bash
set -e

# Variables
SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)

# Ensure that everything is running first
${SCRIPTPATH}/start_raw.sh

# update the daemons
/usr/local/src/komodo_scripts/bin/setup_komodo.sh
/usr/local/src/komodo_scripts/bin/setup_chips.sh
/usr/local/src/komodo_scripts/bin/setup_gamecredits.sh

# Stop all services first
${SCRIPTPATH}/stop_raw.sh

cd ${HOME}
for list in chips3 gamecredits komodo; do
  rm -rf .build_source/${list}_old
  mv $list .build_source/${list}_old
done
