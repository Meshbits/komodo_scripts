#!/usr/bin/env bash
set -e

# Variables
SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)

LOGFILE="${HOME}/start_raw.log"

function move_source() {
  item="$1"
  cd ${HOME}
  [[ -d .build_source/${item}_old ]] && rm -rf .build_source/${item}_old

  if [[ -d .build_source/${item} && -d ${item} ]]; then
    mv ${item} .build_source/${item}_old
    mv .build_source/${item} .
  fi
  echo -e "Moved to \$HOME: ${item} \n"
}

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Ensure that everything is running first
${SCRIPTPATH}/start_raw.sh >& ${LOGFILE}

# update the daemons
echo -e "Starting upgrading everything in .build_source directory\n"
/usr/local/src/komodo_scripts/bin/setup_komodo.sh && move_source komodo
/usr/local/src/komodo_scripts/bin/setup_chips.sh && move_source chips
/usr/local/src/komodo_scripts/bin/setup_gamecredits.sh && move_source gamecredits
/usr/local/src/komodo_scripts/bin/setup_veruscoin.sh && move_source veruscoin
/usr/local/src/komodo_scripts/bin/setup_hush.sh && move_source hush
/usr/local/src/komodo_scripts/bin/setup_emc2.sh && move_source einsteinium
echo -e "Finished upgrading everything in .build_source directory\n"

# Stop all services first
echo -e "Stop all services\n"
${SCRIPTPATH}/stop_raw.sh

echo -e "Moved all assets to \$HOME \n"

# Stop and start iguana
${SCRIPTPATH}/iguana_stop.sh

${SCRIPTPATH}/start_raw.sh &>> ${LOGFILE}
