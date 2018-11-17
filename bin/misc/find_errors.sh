#!/usr/bin/env

DEBUGLOG_ERRORS="${HOME}/debuglog_errors"
DAEMON_ERRORS="${HOME}/daemon_errors"
AC_DAEMON_ERRORS="${HOME}/ac_daemon_errors"
STARTUP_ERRORS="${HOME}/startup_errors"

function grep_me() {
  grep -i -P "err|fork|fail|please send funds"
}

rm -rf ${DEBUGLOG_ERRORS} ${DAEMON_ERRORS} ${AC_DAEMON_ERRORS} ${STARTUP_ERRORS}

find ${HOME}/ -iname debug.log -exec tail -f {} \; | grep_me >> ${DEBUGLOG_ERRORS} &
find ${HOME}/ -iname daemon.log -exec tail -f {} \; | grep_me >>  ${DAEMON_ERRORS} &

tail -f ${HOME}/*.log | grep_me >> ${STARTUP_ERRORS} &
tail -f ${HOME}/.komodo/log/*.log | grep_me >> ${STARTUP_ERRORS} &
