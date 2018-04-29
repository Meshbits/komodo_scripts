#!/usr/bin/env bash
# Installing Komodo on Ubuntu 16.04 LTS
set -e

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user with sudo privileges\n"
   exit 1
fi

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

# Function
# Capture real time taken
function time_taken() {
	/usr/bin/time -f "## Time taken=%e\n" "$1"
}

# Variables
[[ -z ${VAR_NPROC+x} ]] && VAR_NPROC="$(cat /proc/cpuinfo | grep processor | wc -l)"
[[ -z ${VAR_USERNAME+x} ]] && VAR_USERNAME="${USERNAME}"
[[ -z ${VAR_BRANCH+x} ]] && VAR_BRANCH='dev'
[[ -z ${VAR_REPO+x} ]] && VAR_REPO='https://github.com/jl777/komodo.git'
[[ -z ${VAR_SRC_DIR+x} ]] && VAR_SRC_DIR="${HOME}/komodo"
[[ -z ${VAR_CONF_DIR+x} ]] && VAR_CONF_DIR="${HOME}/.komodo"
[[ -z ${VAR_CONF_FILE+x} ]] && VAR_CONF_FILE="${VAR_CONF_DIR}/conf/komodo.conf"
[[ -z ${VAR_RPCPORT+x} ]] && VAR_RPCPORT="7771"
[[ -z ${VAR_BLOCKCHAIN_ARCHIVE+x} ]] && VAR_BLOCKCHAIN_ARCHIVE="komodo_blockchain_backup.tar.gz"

# Create random password for conf if needed
if [[ ! -f "${VAR_CONF_FILE}" ]]; then
  RPCUSER="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
  RPCPASSWORD="$(date +%s | sha256sum | base64 | head -c 32 ; echo)"
else
  DAEMONCONF="${VAR_CONF_FILE}"
  RPCUSER=$(grep 'rpcuser' $DAEMONCONF | cut -d'=' -f2)
  RPCPASSWORD=$(grep 'rpcpassword' $DAEMONCONF | cut -d'=' -f2)
fi

echo -e "## Komodod Daemon setup starting ##\n"

#### Install pre-requisites:
sudo -s bash <<EOF
export DEBIAN_FRONTEND=noninteractive;
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qq \
  install build-essential pkg-config libc6-dev m4 g++-multilib \
  autoconf libtool ncurses-dev unzip git python zlib1g-dev wget bsdmainutils \
  automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler \
  libqt4-dev libqrencode-dev libdb++-dev ntp ntpdate vim \
  software-properties-common curl libcurl4-gnutls-dev cmake clang \
  libgmp3-dev
EOF

# Create directories
[[ -d ${VAR_CONF_DIR} ]] || mkdir ${VAR_CONF_DIR}
[[ -d ${VAR_CONF_DIR}/conf ]] || mkdir ${VAR_CONF_DIR}/conf
[[ -d ${VAR_CONF_DIR}/log ]] || mkdir ${VAR_CONF_DIR}/log
[[ -d ${VAR_CONF_DIR}/bin ]] || mkdir ${VAR_CONF_DIR}/bin

#### Create komodo.conf if it doesn't exist
[[ -f "${VAR_CONF_FILE}" ]] || \
	cat > "${VAR_CONF_FILE}" << EOF
rpcuser=${RPCUSER}
rpcpassword=${RPCPASSWORD}
rpcport=${VAR_RPCPORT}
txindex=1
bind=127.0.0.1
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
addnode=78.47.196.146
EOF
echo -e "Created Komodo configuration file\n"

# Create a hard-link for conf file for backward compatibility
[[ -f ${VAR_CONF_DIR}/komodo.conf ]] || ln ${VAR_CONF_FILE} ${VAR_CONF_DIR}/

if [[ ! ${DONT_BUILD} ]]; then

  #### Install nanomsg
  sudo chown `whoami`. /usr/local/src
  cd /usr/local/src
  if [[ -d nanomsg ]]; then
  	cd nanomsg
  	git reset --hard; git pull --rebase
	else
		git clone https://github.com/nanomsg/nanomsg
  	cd nanomsg
	fi
  time_taken cmake .
  time_taken make
  time_taken sudo make install
  time_taken sudo ldconfig

  ### Checkout the sourcecode
  if [[ -d ${VAR_SRC_DIR} ]]; then
    cd ${VAR_SRC_DIR}
    git checkout ${VAR_BRANCH}; git reset --hard; git pull --rebase
  else
  	cd ${HOME}
		git clone ${VAR_REPO} -b ${VAR_BRANCH}
    cd ${VAR_SRC_DIR}
  fi

  echo -e "===> Build Komodo Daemon"
  [[ -d "${HOME}/.zcash-params" ]] || mkdir "${HOME}/.zcash-params"
  time_taken wget -c https://gitlab.com/zcashcommunity/params/raw/master/sprout-proving.key \
    -O ${HOME}/.zcash-params/sprout-proving.key

  # to-do: Validate the checksum here or stop
	# 8bc20a7f013b2b58970cddd2e7ea028975c88ae7ceb9259a5344a16bc2c0eef7

  time_taken ./zcutil/fetch-params.sh
  time_taken ./zcutil/build.sh -j${VAR_NPROC}
  echo -e "===> Finished building Komodo Daemon"

fi

# Setup control scripts
sed -e "s|<VAR_RPCPORT>|${VAR_RPCPORT}|g" \
  -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_NPROC>|${VAR_NPROC}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "$(dirname $0)/.komodo/bin/start.sh" > "${VAR_CONF_DIR}/bin/start.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  "$(dirname $0)/.komodo/bin/stop.sh" > "${VAR_CONF_DIR}/bin/stop.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "$(dirname $0)/.komodo/bin/healthcheck.sh" > "${VAR_CONF_DIR}/bin/healthcheck.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "$(dirname $0)/.komodo/bin/status.sh" > "${VAR_CONF_DIR}/bin/status.sh"

# Symlink binaries
sudo ln -sf ${HOME}/komodo/src/komodo-cli /usr/local/bin/
sudo ln -sf ${HOME}/komodo/src/komodod /usr/local/bin/
sudo chmod +x /usr/local/bin/komodo-cli
sudo chmod +x /usr/local/bin/komodod

# Create files to stop, start and check status


# Permissions and ownership
chmod +x ${HOME}/.komodo/bin/*
chmod 660 ${HOME}/.komodo/conf/*.conf


echo -e "## Komodod Daemon has been configured ##\n"

# Let komodo blockchain sync in the background only if blockchain was downloaded
if [[ ! "${VAR_BLOCKCHAIN_DOWNLOAD}" ]]; then
  if [[ -d "${VAR_CONF_DIR}/blocks" && -d "${VAR_CONF_DIR}/chainstate" ]] \
    && ! $(ps aux | grep "${VAR_BLOCKCHAIN_ARCHIVE}") &> /dev/null; then
      bash ${VAR_CONF_DIR}/bin/start.sh &
  fi
fi
