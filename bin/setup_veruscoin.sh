#!/usr/bin/env bash
# Tested on Ubuntu 16.04 LTS
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
VAR_THING=veruscoin

[[ -z ${VAR_NPROC+x} ]] && VAR_NPROC="$(cat /proc/cpuinfo | grep processor | wc -l)"
[[ -z ${VAR_USERNAME+x} ]] && VAR_USERNAME="${USER}"
[[ -z ${VAR_BRANCH+x} ]] && VAR_BRANCH='dev'
[[ -z ${VAR_REPO+x} ]] && VAR_REPO='https://github.com/VerusCoin/VerusCoin.git'
[[ -z ${VAR_SRC_DIR+x} ]] && VAR_SRC_DIR="${HOME}/${VAR_THING}"
[[ -z ${VAR_CONF_DIR+x} ]] && VAR_CONF_DIR="${HOME}/.komodo/VRSC"
[[ -z ${VAR_CONF_FILE+x} ]] && VAR_CONF_FILE="${VAR_CONF_DIR}/VRSC.conf"
[[ -z ${VAR_RPCPORT+x} ]] && VAR_RPCPORT="15361"
[[ -z ${VAR_BLOCKCHAIN_ARCHIVE+x} ]] && VAR_BLOCKCHAIN_ARCHIVE="veruscoin_blockchain_backup.tar.gz"

echo -e "## ${VAR_THING} setup starting ##\n"

# Install requisites:
sudo -s bash <<EOF
export DEBIAN_FRONTEND=noninteractive;
apt-get -y -qq update
apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -qq \
  install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool \
  ncurses-dev unzip git python python-zmq zlib1g-dev wget libcurl4-openssl-dev \
  bsdmainutils automake curl

apt -y -qq autoremove
EOF

# Create directories
[[ -d ${VAR_CONF_DIR}/log ]] || mkdir ${VAR_CONF_DIR}/log
[[ -d ${VAR_CONF_DIR}/bin ]] || mkdir ${VAR_CONF_DIR}/bin
[[ -d ${HOME}/.build_source ]] || mkdir ${HOME}/.build_source


#### Use blockchain backup from somewhere
if [[ ! -z ${VAR_BLOCKCHAIN_DOWNLOAD+x} ]]; then
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

    echo -e "## ${VAR_THING} source directory already exists, building in *.build/${VAR_THING}* ##\n"
    cd ${VAR_SRC_DIR}/.. >& /dev/null

    if [[ -d .build_source/${VAR_THING} ]]; then
      cd .build_source/${VAR_THING}
      git checkout ${VAR_BRANCH}
      git reset --hard
      git pull --rebase
    else
      cd .build_source
      git clone ${VAR_REPO} -b ${VAR_BRANCH} ${VAR_THING}
      cd ${VAR_THING}
    fi
    # Copy the pubkey from old source
    #cp -vf ${VAR_SRC_DIR}/src/pubkey.txt ${HOME}/.build_source/${VAR_THING}/src/

  else
    cd ${HOME}
    git clone ${VAR_REPO} -b ${VAR_BRANCH} ${VAR_THING}
    cd ${VAR_SRC_DIR}
  fi

  echo -e "===> Build ${VAR_THING}"
  time_taken ./zcutil/fetch-params.sh
  time_taken ./zcutil/build.sh -j${VAR_NPROC}
  echo -e "===> Finished building ${VAR_THING}"

fi

# Setup control scripts
sed -e "s|<VAR_RPCPORT>|${VAR_RPCPORT}|g" \
  -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_THING>|${VAR_THING}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/start.sh" > "${VAR_CONF_DIR}/bin/start.sh"

sed -e "s|<VAR_USERNAME>|${VAR_USERNAME}|g" \
  -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  -e "s|<VAR_CONF_DIR>|${VAR_CONF_DIR}|g" \
  -e "s|<VAR_THING>|${VAR_THING}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/stop.sh" > "${VAR_CONF_DIR}/bin/stop.sh"

sed -e "s|<VAR_CONF_FILE>|${VAR_CONF_FILE}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/healthcheck.sh" > "${VAR_CONF_DIR}/bin/healthcheck.sh"

sed -e "s|<VAR_SRC_DIR>|${VAR_SRC_DIR}|g" \
  "${SCRIPTPATH}/.${VAR_THING}/bin/status.sh" > "${VAR_CONF_DIR}/bin/status.sh"

# Symlink binaries
sudo ln -sf ${VAR_SRC_DIR}/src/komodo-cli /usr/local/bin/veruscoin-cli
sudo ln -sf ${VAR_SRC_DIR}/src/komodod /usr/local/bin/veruscoind
sudo chmod +x /usr/local/bin/veruscoin-cli
sudo chmod +x /usr/local/bin/veruscoind

# Permissions and ownership
chmod +x ${VAR_CONF_DIR}/bin/*

echo -e "## ${VAR_THING} has been configured ##\n"

# Create monit template
cat > ${HOME}/.komodo/monitd_${VAR_THING}.template <<EOF
check program ${VAR_THING}d_healthcheck.sh with path "${VAR_CONF_DIR}/bin/healthcheck.sh"
  as uid ${USER} and gid ${USER}
  with timeout 60 seconds
if status != 0 then exec "/usr/local/bin/sudo_wrapper ${VAR_CONF_DIR}/bin/start.sh"
  as uid ${USER} and gid ${USER}
  repeat every 2 cycles
EOF

# Copy monit configuration
sudo mv ${HOME}/.komodo/monitd_${VAR_THING}.template /etc/monit/conf.d/monitd_${VAR_THING}
