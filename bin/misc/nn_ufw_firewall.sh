#!/usr/bin/env bash

# source profile and setup variables using "${HOME}/.common/config"
source /etc/profile
[[ -f "${HOME}/.common/config" ]] && source "${HOME}/.common/config"

sudo apt -y -qq install ufw
sudo ufw --force reset
sudo ufw disable
sudo ufw default deny incoming
sudo ufw allow from 127.0.0.1 comment 'Localhost'
sudo ufw allow 22 comment 'SSH'
sudo ufw allow 17775 comment 'Iguana'
sudo ufw allow 7775 comment 'Iguana'

#sudo ufw allow 7770 comment 'Komodo'
#sudo ufw allow 8888 comment 'Hush'
#sudo ufw allow 8333 comment 'BTC'

# Allow all Notary node IPs
for list in "${NN_IPS[@]}"
do
  sudo ufw allow from "${list}/32" comment "Notary Nodes"
done

sudo ufw enable
sudo ufw status
