#!/usr/bin/env bash
# Installing Chips on Ubuntu 16.04 LTS
set -e

if [[ $EUID -eq 0 ]]; then
   echo -e "This script needs to run as a non-root user with sudo privileges\n"
   exit 1
fi

currentdir=$(pwd)
VAR_SRC_DIR="${currentdir}/${1}"
VAR_NPROC="$(cat /proc/cpuinfo | grep processor | wc -l)"

# Capture real time taken
function time_taken() {
  /usr/bin/time -f "## Time taken=%e\n" "$@"
}

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

cd "${currentdir}" >& /dev/null
