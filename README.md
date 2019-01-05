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
  git checkout no_assetchains; git reset --hard; git pull --rebase
  cd - >& /dev/null
else
  git clone https://github.com/ns408/komodo_scripts.git
  cd komodo_scripts; git checkout no_assetchains
fi
```

- `setup_komodo.sh`: sets up komodo daemon from scratch
```
su - meshbits
/usr/local/src/komodo_scripts/bin/setup_komodo.sh
```

### Sync while developing

- `misc/update_setup_scripts.sh`: Loop script
```
/usr/local/src/komodo_scripts/bin/misc/update_setup_scripts.sh 2
```
