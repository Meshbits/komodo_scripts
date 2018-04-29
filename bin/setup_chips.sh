#!/usr/bin/env bash
# Installing Chips on Ubuntu 16.04 LTS
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
[[ -z ${VAR_BRANCH+x} ]] && VAR_BRANCH='dev'
[[ -z ${VAR_REPO+x} ]] && VAR_REPO='https://github.com/jl777/chips3.git'
[[ -z ${VAR_SRC_DIR+x} ]] && VAR_SRC_DIR="${HOME}/chips3"
[[ -z ${VAR_CONF_DIR+x} ]] && VAR_CONF_DIR="${HOME}/.chips"
[[ -z ${VAR_CONF_FILE+x} ]] && VAR_CONF_FILE="${VAR_CONF_DIR}/conf/chips.conf"
[[ -z ${VAR_RPCPORT+x} ]] && VAR_RPCPORT="57776"

# Create random password for conf if needed
if [[ ! -f ${VAR_CONF_FILE} ]]; then
  RPCUSER=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
  RPCPASSWORD=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
else
  RPCUSER=$(grep 'rpcuser' ${VAR_CONF_FILE} | cut -d'=' -f2)
  RPCPASSWORD=$(grep 'rpcpassword' ${VAR_CONF_FILE} | cut -d'=' -f2)
fi

echo -e "## Chips Daemon setup starting ##\n"

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
addnode=5.9.253.195
addnode=74.208.210.191
EOF
echo -e "Created configuration file\n"

# Create a hard-link for conf file for backward compatibility
[[ -f ${VAR_CONF_DIR}/chips.conf ]] || ln ${VAR_CONF_FILE} ${VAR_CONF_DIR}/

if [[ ${DONT_BUILD} != true ]]; then

  ### Checkout the sourcecode
  if [[ -d ${VAR_SRC_DIR} ]]; then
    cd ${VAR_SRC_DIR}
    git checkout ${VAR_BRANCH}; git reset --hard; git pull --rebase
  else
    cd ${HOME}
    git clone ${VAR_REPO} -b ${VAR_BRANCH}
    cd ${VAR_SRC_DIR}
  fi

  # Download & Install Berkley DB 4.8
  echo -e "===> Build Berkley DB 4.8"
  BDB_PREFIX="${VAR_SRC_DIR}/db4"
  [[ -d "${BDB_PREFIX}" ]] || mkdir -p "${BDB_PREFIX}"
  sudo chown -R `whoami`. /usr/local/src
  cd /usr/local/src
  wget -c 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
  echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
  tar -xzvf 'db-4.8.30.NC.tar.gz'
  cd "db-4.8.30.NC/build_unix"
  time_taken ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BDB_PREFIX}
  time_taken make -j${VAR_NPROC}
  time_taken make install
  echo -e "===> Finished building and installing Berkley DB 4.8"

  # Build Chips
  echo -e "===> Build Chips Daemon"
  cd ${VAR_SRC_DIR}
  time ./autogen.sh
  time ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" \
    --without-gui --without-miniupnpc --disable-tests --disable-bench --with-gui=no
  time make -j${VAR_NPROC}
  echo -e "===> Finished building Chips Daemon"

fi

# Setup control scripts
sed -e "s|<VAR_RPCPORT>|${VAR_RPCPORT}|g" \
  -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_NPROC>|${VAR_NPROC}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "${SCRIPTPATH}/.chips/bin/start.sh" > "${VAR_CONF_DIR}/bin/start.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "${SCRIPTPATH}/.chips/bin/stop.sh" > "${VAR_CONF_DIR}/bin/stop.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "${SCRIPTPATH}/.chips/bin/healthcheck.sh" > "${VAR_CONF_DIR}/bin/healthcheck.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "${SCRIPTPATH}/.chips/bin/status.sh" > "${VAR_CONF_DIR}/bin/status.sh"

# Symlink binaries
sudo ln -sf ${VAR_SRC_DIR}/src/chips-cli /usr/local/bin/
sudo ln -sf ${VAR_SRC_DIR}/src/chipsd /usr/local/bin/
sudo chmod +x /usr/local/bin/chips-cli
sudo chmod +x /usr/local/bin/chipsd

# Permissions and ownership
chmod +x ${VAR_CONF_DIR}/bin/*
chmod 660 ${VAR_CONF_DIR}/conf/*.conf

echo -e "## Chips Daemon has been configured ##\n"
