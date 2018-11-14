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
echo -e "Starting upgrading everything in .build_source directory\n"
/usr/local/src/komodo_scripts/bin/setup_komodo.sh
/usr/local/src/komodo_scripts/bin/setup_chips.sh
/usr/local/src/komodo_scripts/bin/setup_gamecredits.sh
/usr/local/src/komodo_scripts/bin/setup_veruscoin.sh
/usr/local/src/komodo_scripts/bin/setup_hush.sh
/usr/local/src/komodo_scripts/bin/setup_emc2.sh
echo -e "Finished upgrading everything in .build_source directory\n"

# Stop all services first
echo -e "Stop all services\n"
${SCRIPTPATH}/stop_raw.sh

cd ${HOME}
for list in chips gamecredits komodo veruscoin hush einsteinium; do
  [[ -d .build_source/${list}_old ]] && rm -rf .build_source/${list}_old
  [[ -d ${list} ]] && mv ${list} .build_source/${list}_old
  [[ -d .build_source/${list} ]] && mv .build_source/${list} .
done
echo -e "Moved all assets to \$HOME \n"

# Stop and start iguana
${SCRIPTPATH}/iguana_stop.sh
${SCRIPTPATH}/iguana_start.sh >& ${LOGFILE} &

${SCRIPTPATH}/start_raw.sh &>> ${LOGFILE}
