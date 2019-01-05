#!/usr/bin/env bash
set -e

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

echo -e "## Komodod Assetchains setup starting ##\n"

# Setup configuration which monit can use
sed -e "s|<HOME>|${HOME}|g" \
  -e "s|<EXTERNALIP>|${EXTERNALIP}|g" \
  $(dirname $0)/.komodo/bin/ac_start.sh > ${HOME}/.komodo/bin/ac_start.sh

sed -e "s|<HOME>|${HOME}|" \
  $(dirname $0)/.komodo/bin/ac_status.sh > ${HOME}/.komodo/bin/ac_status.sh

sed -e "s|<HOME>|${HOME}|" \
  $(dirname $0)/.komodo/bin/ac_stop.sh > ${HOME}/.komodo/bin/ac_stop.sh

# Setup configuration which monit can use
sed -e "s|<HOME>|${HOME}|" \
  $(dirname $0)/.komodo/bin/ac_healthcheck.sh > ${HOME}/.komodo/bin/ac_healthcheck.sh

# Create monit template
cat > ${HOME}/.komodo/monitd_assetchains.template <<EOF
check program assetchains_healthcheck.sh with path "${HOME}/.komodo/bin/ac_healthcheck.sh"
  as uid ${USER} and gid ${USER}
  with timeout 60 seconds
if status != 0 then exec "/usr/local/bin/sudo_wrapper ${HOME}/.komodo/bin/ac_start.sh"
  as uid ${USER} and gid ${USER}
  repeat every 2 cycles
EOF

# Copy monit configuration
sudo rm -f /etc/monit/conf.d/monitd_assetchains

# Permissions and ownership
chmod +x ${HOME}/.komodo/bin/*
chmod 600 ${HOME}/.komodo/conf/*.conf

echo -e "## Komodod Assetchains have been configured ##\n"
