#!/usr/bin/env bash
# Installing GameCredits on Ubuntu 16.04 LTS
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
[[ -z ${VAR_NPROC+x} ]] && VAR_NPROC="$(cat /proc/cpuinfo | grep processor | wc -l)"
[[ -z ${VAR_USERNAME+x} ]] && VAR_USERNAME="${USER}"
[[ -z ${VAR_BRANCH+x} ]] && VAR_BRANCH='master'
[[ -z ${VAR_REPO+x} ]] && VAR_REPO='https://github.com/jl777/GameCredits.git'
[[ -z ${VAR_SRC_DIR+x} ]] && VAR_SRC_DIR="${HOME}/gamecredits"
[[ -z ${VAR_CONF_DIR+x} ]] && VAR_CONF_DIR="${HOME}/.gamecredits"
[[ -z ${VAR_CONF_FILE+x} ]] && VAR_CONF_FILE="${VAR_CONF_DIR}/conf/gamecredits.conf"
[[ -z ${VAR_RPCPORT+x} ]] && VAR_RPCPORT="40001"

# Create random password for conf if needed
if [[ ! -f ${VAR_CONF_FILE} ]]; then
  RPCUSER=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
  RPCPASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
else
  RPCUSER=$(grep 'rpcuser' ${VAR_CONF_FILE} | cut -d'=' -f2)
  RPCPASSWORD=$(grep 'rpcpassword' ${VAR_CONF_FILE} | cut -d'=' -f2)
fi

echo -e "## GameCredits Daemon setup starting ##\n"

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
txindex=1
bind=127.0.0.1
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
EOF
echo -e "Created configuration file\n"

# Create a hard-link for conf file for backward compatibility
[[ -f ${VAR_CONF_DIR}/gamecredits.conf ]] || ln -sf ${VAR_CONF_FILE} ${VAR_CONF_DIR}/

if [[ ${DONT_BUILD} != true ]]; then

  ### Checkout the sourcecode
  if [[ -d ${VAR_SRC_DIR} ]]; then

    echo -e "## GameCredits source directory already exists, building in *.build_source/gamecredits* ##\n"
    cd "${HOME}/.build_source" >& /dev/null
    rm -rf gamecredits
    git clone ${VAR_REPO} -b ${VAR_BRANCH} gamecredits
    $(dirname $0)/install_berkleydb.sh "${HOME}/.build_source/gamecredits"
    cd gamecredits
    BDB_PREFIX="${HOME}/.build_source/gamecredits/db4"
  else
    cd ${HOME}
    git clone ${VAR_REPO} -b ${VAR_BRANCH} gamecredits
    cd ${VAR_SRC_DIR}

    # Build BerkleyDB
    $(dirname $0)/install_berkleydb.sh ${VAR_SRC_DIR}
    cd ${VAR_SRC_DIR}
    BDB_PREFIX="${VAR_SRC_DIR}/db4"
  fi

  # Build GameCredits
  echo -e "===> Build GameCredits Daemon"
  time ./autogen.sh
  time ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" \
    --without-gui --without-miniupnpc --disable-tests --disable-bench --with-gui=no
  time make -j${VAR_NPROC}
  echo -e "===> Finished building GameCredits Daemon"

fi

# Setup control scripts
sed -e "s|<VAR_RPCPORT>|${VAR_RPCPORT}|g" \
  -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_NPROC>|${VAR_NPROC}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "${SCRIPTPATH}/.gamecredits/bin/start.sh" > "${VAR_CONF_DIR}/bin/start.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "${SCRIPTPATH}/.gamecredits/bin/stop.sh" > "${VAR_CONF_DIR}/bin/stop.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "${SCRIPTPATH}/.gamecredits/bin/healthcheck.sh" > "${VAR_CONF_DIR}/bin/healthcheck.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  "${SCRIPTPATH}/.gamecredits/bin/status.sh" > "${VAR_CONF_DIR}/bin/status.sh"

# Symlink binaries
sudo ln -sf ${VAR_SRC_DIR}/src/gamecredits-cli /usr/local/bin/
sudo ln -sf ${VAR_SRC_DIR}/src/gamecreditsd /usr/local/bin/
sudo chmod +x /usr/local/bin/gamecredits-cli
sudo chmod +x /usr/local/bin/gamecreditsd

# Permissions and ownership
chmod +x ${VAR_CONF_DIR}/bin/*
chmod 660 ${VAR_CONF_DIR}/conf/*.conf

echo -e "## GameCredits Daemon has been configured ##\n"

# Create monit template
cat > ${HOME}/.gamecredits/monitd_gamecredits.template <<EOF
check program gamecredits_healthcheck.sh with path "${HOME}/.gamecredits/bin/healthcheck.sh"
  as uid ${USER} and gid ${USER}
  with timeout 60 seconds
if status != 0 then exec "/usr/local/bin/sudo_wrapper ${HOME}/.gamecredits/bin/start.sh"
  as uid ${USER} and gid ${USER}
  repeat every 2 cycles
EOF

# Copy monit configuration
sudo mv ${HOME}/.gamecredits/monitd_gamecredits.template /etc/monit/conf.d/monitd_gamecredits
