# komodo_scripts

Komodo Platform Core service scripts

## Requisites

- Ubuntu 16.04 LTS

## Scripts

- Clone the repo
```
cd /usr/local/src
if [[ -d komodo_scripts ]]; then
  cd komodo_scripts
  git checkout master; git reset --hard; git pull --rebase
  cd - >& /dev/null
else
  git clone https://github.com/ns408/komodo_scripts.git
fi
```

- `create_user.sh`: create meshbits user
```
cd komodo_scripts
bash bin/create_user.sh meshbits
```

- `setup_komodo.sh`: sets up komodo daemon from scratch
```
su - meshbits
cd /usr/local/src/komodo_scripts
bash bin/setup_komodo.sh
```

- `setup_chips.sh`: sets up chips daemon from scratch
```
su - meshbits
cd /usr/local/src/komodo_scripts
bash bin/setup_chips.sh
```
