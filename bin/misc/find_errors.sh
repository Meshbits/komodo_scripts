#!/usr/bin/env

ZFILE="${HOME}/errors"
rm -rf ${ZFILE}
find ${HOME}/ -iname debug.log -exec tail -f "${HOME}/*.log" {} \; | grep -i -P "err|fork|fail" >> ${ZFILE}
