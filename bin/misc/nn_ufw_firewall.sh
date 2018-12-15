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
#sudo ufw allow 8333 comment 'BTC'

# Allow all Notary node IPs
for list in "${NN_IPS[@]}"
do
  sudo ufw allow from "${list}/32" comment "Notary Nodes"
done

sudo ufw enable
sudo ufw status

exit 0


```
22                         ALLOW       Anywhere
7770                       ALLOW       Anywhere
7772                       ALLOW       Anywhere
7773                       ALLOW       Anywhere
7774                       ALLOW       Anywhere
7775                       ALLOW       Anywhere
17775                      ALLOW       Anywhere
8333                       ALLOW       Anywhere
57777                      ALLOW       Anywhere
10195                      ALLOW       Anywhere
11340                      ALLOW       Anywhere
11889                      ALLOW       Anywhere
14067                      ALLOW       Anywhere

15105                      ALLOW       Anywhere
14249                      ALLOW       Anywhere
8515                       ALLOW       Anywhere
14430                      ALLOW       Anywhere
11963                      ALLOW       Anywhere
12385                      ALLOW       Anywhere
8654                       ALLOW       Anywhere
12166                      ALLOW       Anywhere
8298                       ALLOW       Anywhere
11115                      ALLOW       Anywhere
9454                       ALLOW       Anywhere
14336                      ALLOW       Anywhere
14275                      ALLOW       Anywhere
8845                       ALLOW       Anywhere
12926                      ALLOW       Anywhere
8799                       ALLOW       Anywhere
10270                      ALLOW       Anywhere
15487                      ALLOW       Anywhere
8426                       ALLOW       Anywhere
12446                      ALLOW       Anywhere
14357                      ALLOW       Anywhere
15586                      ALLOW       Anywhere
9678                       ALLOW       Anywhere
12466                      ALLOW       Anywhere
11556                      ALLOW       Anywhere
15722                      ALLOW       Anywhere                   # GLXT
10305                      ALLOW       Anywhere                   # EQL
8888                       ALLOW       Anywhere                   # HUSH
```

# Extra open ports
sudo ufw allow 7770 comment 'Komodod'
sudo ufw allow 7772 comment 'Iguana'
sudo ufw allow 7773 comment 'Iguana'
sudo ufw allow 7774 comment 'Iguana'
sudo ufw allow 7775 comment 'Iguana'

sudo ufw allow 8298 comment 'KV'
sudo ufw allow 8515 comment 'CRYPTO'
sudo ufw allow 8674 comment 'RON'
sudo ufw allow 9109 comment 'BGN'
sudo ufw allow 9454 comment 'MESH'
sudo ufw allow 9481 comment 'CZK'
sudo ufw allow 9913 comment 'BRL'
sudo ufw allow 10113 comment 'SHARK'
sudo ufw allow 10195 comment 'REVS'
sudo ufw allow 11115 comment 'CEAL'
sudo ufw allow 11340 comment 'SUPERNET'
sudo ufw allow 11446 comment 'SEK'
sudo ufw allow 11587 comment 'NOK'
sudo ufw allow 11846 comment 'THB'
sudo ufw allow 11889 comment 'DEX'
sudo ufw allow 11963 comment 'BOTS'
sudo ufw allow 12166 comment 'WLC'
sudo ufw allow 12385 comment 'MGW'
sudo ufw allow 12616 comment 'WLC'
sudo ufw allow 13492 comment 'PLN'
sudo ufw allow 13698 comment 'HUF'
sudo ufw allow 13829 comment 'DKK'
sudo ufw allow 13923 comment 'TRY'
sudo ufw allow 13969 comment 'MXN'
sudo ufw allow 14019 comment 'KRW'
sudo ufw allow 14067 comment 'PANGEA'
sudo ufw allow 14249 comment 'BET'
sudo ufw allow 14275 comment 'COQUI'
sudo ufw allow 14430 comment 'HODL'
sudo ufw allow 14458 comment 'IDR'
sudo ufw allow 14474 comment 'SGD'
sudo ufw allow 14637 comment 'ILS'
sudo ufw allow 15105 comment 'JUMBLR'
sudo ufw allow 15159 comment 'ZAR'
sudo ufw allow 15311 comment 'CHF'
sudo ufw allow 15722 comment 'GLXT'
#sudo ufw allow 13108 comment 'GLXT'
sudo ufw allow 10305 comment 'EQL'
sudo ufw allow 20848 comment 'CCL'
sudo ufw allow 8888 comment 'HUSH'
sudo ufw allow 57777 comment 'CHIPS'
sudo ufw allow 8654 comment 'MVP'
sudo ufw allow 14336 comment 'MNZ'
sudo ufw allow 8845 comment 'MSHARK'
sudo ufw allow 12926 comment 'AXO'
sudo ufw allow 8799 comment 'BTCH'
sudo ufw allow 10270 comment 'ETOMIC'
sudo ufw allow 8426 comment 'NINJA'
sudo ufw allow 12446 comment 'OOT'
sudo ufw allow 14357 comment 'BNTN'
sudo ufw allow 15586 comment 'CHAIN'
sudo ufw allow 9678 comment 'PRLPAY'
sudo ufw allow 11556 comment 'DSEC'
sudo ufw allow 40002 comment 'GameCredits'

# sudo ufw allow 15487 comment 'VOTE2018'
# sudo ufw allow 15408 comment 'HKD'
# sudo ufw allow 8719 comment 'CAD'
# sudo ufw allow 10383 comment 'CNY'
# sudo ufw allow 10535 comment 'INR'
# sudo ufw allow 10687 comment 'MYR'
# sudo ufw allow 11180 comment 'PHP'
# sudo ufw allow 13967 comment 'USD'
# sudo ufw allow 10914 comment 'NZD'
# sudo ufw allow 11504 comment 'GBP'
# sudo ufw allow 13144 comment 'JPY'

# Whitelist everything that I have an open port for - a really BAD Idea
# for list in $(sudo netstat -ntlp | grep 0.0.0.0 | grep -v -P '127.0.0.1|sshd' | cut -d':' -f2 | cut -d' ' -f1); do
#   pid=$(fuser $list/tcp 2> /dev/null | awk '{ print $1 }')

#   # Get all the assetchains
#   name=$(ps -eo pid,args | grep ${pid} | grep -v grep | grep -- '-ac_name=' | awk -F'ac_name=' '{ print $2 }' | cut -d' ' -f1)

#   echo -e "sudo ufw allow $list # $name"
#   sudo ufw allow $list
# done
