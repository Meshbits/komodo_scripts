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

- `run_optimisations.sh`: system optimisations
```
/usr/local/src/komodo_scripts/bin/run_optimisations.sh
```

- `create_user.sh`: create meshbits user
```
/usr/local/src/komodo_scripts/bin/create_user.sh meshbits
```

- `common_config.sh`: sets up common configuration file
```
su - meshbits
/usr/local/src/komodo_scripts/bin/common_config.sh
```

- `userdata.sh`: userdata
```
/usr/local/src/komodo_scripts/bin/userdata.sh
```

- `setup_komodo.sh`: sets up komodo daemon from scratch
```
su - meshbits
/usr/local/src/komodo_scripts/bin/setup_komodo.sh
```

- `setup_chips.sh`: sets up chips daemon from scratch
```
su - meshbits
/usr/local/src/komodo_scripts/bin/setup_chips.sh
```

- `setup_assetchains.sh`: sets up chips daemon from scratch
```
su - meshbits
/usr/local/src/komodo_scripts/bin/setup_assetchains.sh
```

- `setup_misc_scripts.sh`: sets up misc scripts and ensures **all daemon start up using rc.local**
```
su - meshbits
/usr/local/src/komodo_scripts/bin/setup_misc_scripts.sh
```


### Sync while developing

- `misc/update_setup_scripts.sh`: Loop script
```
/usr/local/src/komodo_scripts/bin/misc/update_setup_scripts.sh
```
