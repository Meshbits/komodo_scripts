#!/usr/bin/env bash
set -e

# Variables
SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)

LOGFILE="${HOME}/start_raw.log"

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Ensure that everything is running first
${SCRIPTPATH}/start_raw.sh >& ${LOGFILE}

# update the daemons
/usr/local/src/komodo_scripts/bin/setup_komodo.sh
/usr/local/src/komodo_scripts/bin/setup_chips.sh
/usr/local/src/komodo_scripts/bin/setup_gamecredits.sh
/usr/local/src/komodo_scripts/bin/setup_veruscoin.sh
/usr/local/src/komodo_scripts/bin/setup_hush.sh
/usr/local/src/komodo_scripts/bin/setup_emc2.sh
/usr/local/src/komodo_scripts/bin/setup_kmdice.sh

# Stop all services first
${SCRIPTPATH}/stop_raw.sh

cd ${HOME}
for list in chips gamecredits komodo veruscoin hush einsteinium kmdice; do
  rm -rf .build_source/${list}_old
  mv $list .build_source/${list}_old
  mv .build_source/${list} .
done

# Stop and start iguana
${SCRIPTPATH}/iguana_stop.sh
${SCRIPTPATH}/iguana_start.sh >& ${LOGFILE} &

${SCRIPTPATH}/start_raw.sh &>> ${LOGFILE}
