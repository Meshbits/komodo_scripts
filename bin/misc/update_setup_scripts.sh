#!/usr/bin/env bash

sudo -s bash <<EOF
cd /usr/local/src
if [[ -d komodo_scripts ]]; then
  cd komodo_scripts
  git checkout master; git reset --hard; git pull --rebase
  cd - >& /dev/null
else
  git clone https://github.com/ns408/komodo_scripts.git
fi
EOF

cd /usr/local/src/komodo_scripts
bash bin/setup_misc_scripts.sh
cd ~
