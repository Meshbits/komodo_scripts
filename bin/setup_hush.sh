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
VAR_THING=hush

[[ -z ${VAR_NPROC+x} ]] && VAR_NPROC="$(cat /proc/cpuinfo | grep processor | wc -l)"
[[ -z ${VAR_USERNAME+x} ]] && VAR_USERNAME="${USER}"
[[ -z ${VAR_BRANCH+x} ]] && VAR_BRANCH='dev'
[[ -z ${VAR_REPO+x} ]] && VAR_REPO='https://github.com/MyHush/hush.git'
[[ -z ${VAR_SRC_DIR+x} ]] && VAR_SRC_DIR="${HOME}/${VAR_THING}"
[[ -z ${VAR_CONF_DIR+x} ]] && VAR_CONF_DIR="${HOME}/.${VAR_THING}"
[[ -z ${VAR_CONF_FILE+x} ]] && VAR_CONF_FILE="${VAR_CONF_DIR}/conf/${VAR_THING}.conf"
[[ -z ${VAR_RPCPORT+x} ]] && VAR_RPCPORT="8822"

# Create random password for conf if needed
if [[ ! -f ${VAR_CONF_FILE} ]]; then
  RPCUSER=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
  RPCPASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
else
  RPCUSER=$(grep 'rpcuser' ${VAR_CONF_FILE} | cut -d'=' -f2)
  RPCPASSWORD=$(grep 'rpcpassword' ${VAR_CONF_FILE} | cut -d'=' -f2)
fi

echo -e "## ${VAR_THING} Daemon setup starting ##\n"

# Install requisites:
sudo -s bash <<EOF
export DEBIAN_FRONTEND=noninteractive;
apt-get -y -qq update
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qq \
  install libevent-dev
EOF

# Create directories
[[ -d ${VAR_CONF_DIR} ]] || mkdir ${VAR_CONF_DIR}
[[ -d ${VAR_CONF_DIR}/conf ]] || mkdir ${VAR_CONF_DIR}/conf
[[ -d ${VAR_CONF_DIR}/log ]] || mkdir ${VAR_CONF_DIR}/log
[[ -d ${VAR_CONF_DIR}/bin ]] || mkdir ${VAR_CONF_DIR}/bin
[[ -d ${HOME}/.build_source ]] || mkdir ${HOME}/.build_source

#### Create conf only if it doesn't exist before
[[ -f "${VAR_CONF_FILE}" ]] || \
  cat > "${VAR_CONF_FILE}" << EOF
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcport=${VAR_RPCPORT}

rpcbind=127.0.0.1
rpcallowip=127.0.0.1
rpcworkqueue=256
#bind=127.0.0.1
addnode=explorer.myhush.org
addnode=dnsseed.myhush.org
addnode=dnsseed2.myhush.org
addnode=dnsseed.bleuzero.com
addnode=dnsseed.hush.quebec
txindex=1
server=1
showmetrics=0

maxconnections=16
# Hush listens on Tor by default, most don't need this. Also requires firewall changes
listenonion=0
# These are optional and can be disabled for performance reasons if needed
# This will enable various RPC methods which depend on indexes
#addressindex=1
#timestampindex=1
#spentindex=1
# TLS options described here, default is fine for most: https://github.com/MyHush/hush/blob/master/SECURE_SETUP.md
EOF
echo -e "Created configuration file\n"

# Create a hard-link for conf file for backward compatibility
[[ -f ${VAR_CONF_DIR}/${VAR_THING}.conf ]] || ln -sf ${VAR_CONF_FILE} ${VAR_CONF_DIR}/

if [[ ${DONT_BUILD} != true ]]; then

  ### Checkout the sourcecode
  if [[ -d ${VAR_SRC_DIR} ]]; then

    echo -e "## ${VAR_THING} source directory already exists, building in *.build_source/${VAR_THING}* ##\n"
    cd ${HOME}/.build_source >& /dev/null
    [[ -d ${VAR_THING} ]] && rm -rf ${VAR_THING}
    git clone ${VAR_REPO} -b ${VAR_BRANCH} ${VAR_THING}
    cd ${VAR_THING}
  else
    cd ${HOME}
    git clone ${VAR_REPO} -b ${VAR_BRANCH} ${VAR_THING}
    cd ${VAR_SRC_DIR}
  fi

  # Build Hush
  echo -e "===> Build ${VAR_THING} Daemon"
  time_taken ./zcutil/build.sh -j${VAR_NPROC}
  echo -e "===> Finished building ${VAR_THING} Daemon"

fi

# Setup control scripts
sed -e "s|<VAR_RPCPORT>|${VAR_RPCPORT}|g" \
  -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/start.sh" > "${VAR_CONF_DIR}/bin/start.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  -e "s|<VAR_THING>|${VAR_THING}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/stop.sh" > "${VAR_CONF_DIR}/bin/stop.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/healthcheck.sh" > "${VAR_CONF_DIR}/bin/healthcheck.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_THING>|${VAR_THING}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/status.sh" > "${VAR_CONF_DIR}/bin/status.sh"

# Symlink binaries
sudo ln -sf ${VAR_SRC_DIR}/src/${VAR_THING}-cli /usr/local/bin/
sudo ln -sf ${VAR_SRC_DIR}/src/${VAR_THING}d /usr/local/bin/
sudo chmod +x /usr/local/bin/${VAR_THING}-cli
sudo chmod +x /usr/local/bin/${VAR_THING}d

# Permissions and ownership
chmod +x ${VAR_CONF_DIR}/bin/*
chmod 660 ${VAR_CONF_DIR}/conf/*.conf

echo -e "## ${VAR_THING} Daemon has been configured ##\n"

# Create monit template
cat > ${HOME}/.${VAR_THING}/monitd_${VAR_THING}.template <<EOF
check program ${VAR_THING}_healthcheck.sh with path "${HOME}/.${VAR_THING}/bin/healthcheck.sh"
  as uid ${USER} and gid ${USER}
  with timeout 60 seconds
if status != 0 then exec "/usr/local/bin/sudo_wrapper ${HOME}/.${VAR_THING}/bin/start.sh"
  as uid ${USER} and gid ${USER}
  repeat every 2 cycles
EOF

# Copy monit configuration
sudo mv ${HOME}/.${VAR_THING}/monitd_${VAR_THING}.template /etc/monit/conf.d/monitd_${VAR_THING}
