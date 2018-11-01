#!/usr/bin/env bash
# Run this while developing so that code can stay in-sync

var=${1}

if [[ -z ${var+x} ]]; then
  var=5
fi

count=1
while [[ count -le ${var} ]]; do

sudo -s bash <<EOF
cd /usr/local/src
if [[ -d komodo_scripts ]]; then
  cd komodo_scripts
  git checkout master; git reset -q --hard; git pull --rebase
  cd - >& /dev/null
else
  git clone -q https://github.com/ns408/komodo_scripts.git
  cd - >& /dev/null
fi
EOF

  bash /usr/local/src/komodo_scripts/bin/setup_misc_scripts.sh >& /dev/null
  cd ${HOME}
  sleep 5

  count=${count}+1
done
