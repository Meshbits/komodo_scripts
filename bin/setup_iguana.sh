#!/usr/bin/env bash
# Installing Hush on Ubuntu 16.04 LTS
# Reference: https://gist.github.com/leto/d07578c55738131b8772623265bfb2cf
set -e

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user with sudo privileges\n"
   exit 1
fi

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Functions
# Capture real time taken
function time_taken() {
  /usr/bin/time -f "## Time taken=%e\n" "$@"
}

# Variables
SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)
VAR_THING=iguana

# Create monit template
cat > ${HOME}/monitd_${VAR_THING}.template <<EOF
check program iguana with path "/bin/pidof iguana"
  as uid ${USER} and gid ${USER}
  with timeout 60 seconds
if status != 0 for 5 cycles then exec "/usr/local/bin/sudo_wrapper ${HOME}/misc_scripts/iguana_start.sh"
  as uid ${USER} and gid ${USER}
  repeat every 3 cycles

# check host myhost with address 127.0.0.1
# if failed port 7775 type tcp then exec "/usr/local/bin/sudo_wrapper ${HOME}/misc_scripts/iguana_start.sh"
#   as uid ${USER} and gid ${USER}
#   repeat every 2 cycles
EOF

# Copy monit configuration
sudo mv ${HOME}/monitd_${VAR_THING}.template /etc/monit/conf.d/monitd_${VAR_THING}
