#!/usr/bin/env bash

DEBUGLOG_ERRORS="${HOME}/debuglog_errors"
AC_DAEMON_ERRORS="${HOME}/ac_daemon_errors"
STARTUP_ERRORS="${HOME}/startup_errors"

function grep_me() {
  grep -i -P "err|fork|fail|please send funds"
}

pids=""

rm -rf ${DEBUGLOG_ERRORS} ${DAEMON_ERRORS} ${AC_DAEMON_ERRORS} ${STARTUP_ERRORS}

find ${HOME}/ -iname 'debug.log' -o -iname 'daemon.log' \
  -exec tail -f {} \; | grep_me >> ${DEBUGLOG_ERRORS} &
pids="$pids $!"

tail -f ${HOME}/*.log ${HOME}/.komodo/log/*.log | grep_me >> ${STARTUP_ERRORS} &
pids="$pids $!"

wait -n ${pids}

trap 'kill ${pids}' SIGINT SIGTERM EXIT
#trap 'kill $(jobs -p)' SIGINT SIGTERM EXIT
