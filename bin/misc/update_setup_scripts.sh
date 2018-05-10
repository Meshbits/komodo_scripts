#!/usr/bin/env bash
# Run this while developing so that code can stay in-sync

while true; do

  sudo -s bash <<EOF
cd /usr/local/src
if [[ -d komodo_scripts ]]; then
  cd komodo_scripts
  git checkout master; git reset --hard; git pull --rebase
  cd - >& /dev/null
else
  git clone https://github.com/ns408/komodo_scripts.git
  cd - >& /dev/null
fi
EOF

  bash /usr/local/src/komodo_scripts/bin/setup_misc_scripts.sh
  cd ${HOME}
  sleep 5
done
