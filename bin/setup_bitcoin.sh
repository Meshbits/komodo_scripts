#!/usr/bin/env bash
# Installing Bitcoin on Ubuntu 16.04 LTS
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
# Leart it the hard way that version should be pinned and that bitcoin's master branch can be unstable
BITCOIN_LATEST_STABLE=$(curl --silent "https://api.github.com/repos/bitcoin/bitcoin/releases/latest" \
  | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
#wget -c https://github.com/bitcoin/bitcoin/archive/${BITCOIN_LATEST_STABLE}.tar.gz -O ${BITCOIN_LATEST_STABLE}.tar.gz

SCRIPTNAME=$(realpath $0)
SCRIPTPATH=$(dirname $SCRIPTNAME)
VAR_THING=bitcoin

[[ -z ${VAR_NPROC+x} ]] && VAR_NPROC="$(cat /proc/cpuinfo | grep processor | wc -l)"
[[ -z ${VAR_USERNAME+x} ]] && VAR_USERNAME="${USER}"
[[ -z ${VAR_BRANCH+x} ]] && VAR_BRANCH="v0.16.3"
[[ -z ${VAR_REPO+x} ]] && VAR_REPO='https://github.com/bitcoin/bitcoin.git'
[[ -z ${VAR_SRC_DIR+x} ]] && VAR_SRC_DIR="${HOME}/${VAR_THING}"
[[ -z ${VAR_CONF_DIR+x} ]] && VAR_CONF_DIR="${HOME}/.${VAR_THING}"
[[ -z ${VAR_CONF_FILE+x} ]] && VAR_CONF_FILE="${VAR_CONF_DIR}/conf/${VAR_THING}.conf"
[[ -z ${VAR_RPCPORT+x} ]] && VAR_RPCPORT="8332"
[[ -z ${VAR_BLOCKCHAIN_ARCHIVE+x} ]] && VAR_BLOCKCHAIN_ARCHIVE="${VAR_THING}_blockchain_backup.tar.gz"

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
  install build-essential libtool autotools-dev autoconf pkg-config libssl-dev \
  libboost-all-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev \
  qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev autoconf \
  automake openssl libssl-dev libevent-dev libminiupnpc-dev bsdmainutils \
  pigz vim ntp ntpdate curl wget git python unzip sudo jq dnsutils tree \
  inotify-tools htop
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
server=1
#bind=127.0.0.1
rpcbind=127.0.0.1
rpcallowip=127.0.0.1

maxconnections=16
EOF
echo -e "Created configuration file\n"

# Create a hard-link for conf file for backward compatibility
[[ -f ${VAR_CONF_DIR}/${VAR_THING}.conf ]] || ln -sf ${VAR_CONF_FILE} ${VAR_CONF_DIR}/

#### Use blockchain backup from somewhere
if [[ ! -z "${VAR_BLOCKCHAIN_DOWNLOAD+x}" ]]; then
  echo -e "## Downloading ${VAR_BLOCKCHAIN_ARCHIVE} in the background ##\n"
  cd ${VAR_CONF_DIR}
  wget -c ${VAR_BLOCKCHAIN_DOWNLOAD} \
    -O ${VAR_BLOCKCHAIN_ARCHIVE}

  if ! [[ -d blocks && -d chainstate ]]; then
    pigz -dc ${VAR_BLOCKCHAIN_ARCHIVE} | tar xf -
  fi
fi &

if [[ ${DONT_BUILD} != true ]]; then

  ### Checkout the sourcecode
  if [[ -d ${VAR_SRC_DIR} ]]; then
    cd ${VAR_SRC_DIR}
    git checkout master; git pull --rebase
    git checkout ${VAR_BRANCH}; git reset --hard
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
  tar -xzf 'db-4.8.30.NC.tar.gz'
  cd "db-4.8.30.NC/build_unix"
  time_taken ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BDB_PREFIX}
  time_taken make -j${VAR_NPROC}
  time_taken make install
  echo -e "===> Finished building and installing Berkley DB 4.8"

  # Build Chips
  echo -e "===> Build ${VAR_THING} Daemon"
  cd ${VAR_SRC_DIR}
  time_taken ./autogen.sh
  time_taken ./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" \
    --without-gui --without-miniupnpc --disable-tests --disable-bench --with-gui=no
  time_taken make -s -j${VAR_NPROC}
  echo -e "===> Finished building ${VAR_THING} Daemon"

fi

# Setup control scripts
sed -e "s|<VAR_RPCPORT>|${VAR_RPCPORT}|g" \
  -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_NPROC>|${VAR_NPROC}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/start.sh" > "${VAR_CONF_DIR}/bin/start.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/stop.sh" > "${VAR_CONF_DIR}/bin/stop.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/healthcheck.sh" > "${VAR_CONF_DIR}/bin/healthcheck.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
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
check program ${VAR_THING}d_healthcheck.sh with path "${HOME}/.${VAR_THING}/bin/healthcheck.sh"
  as uid ${USER} and gid ${USER}
  with timeout 60 seconds
if status != 0 then exec "/usr/local/bin/sudo_wrapper ${HOME}/.${VAR_THING}/bin/start.sh"
  as uid ${USER} and gid ${USER}
  repeat every 2 cycles
EOF

# Copy monit configuration
sudo mv ${HOME}/.${VAR_THING}/monitd_${VAR_THING}.template /etc/monit/conf.d/monitd_${VAR_THING}
