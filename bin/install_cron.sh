#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "This script needs to run as a root user\n"
   exit 1
fi

cat > /var/spool/cron/crontabs/meshbits <<\EOF
MAILTO=''
*/5 * * * * bash /home/meshbits/misc_scripts/cron_recharge_utxos.sh
#0 * * * * bash /usr/local/bin/slack_alert "#nn_reports" "\`\`\`$(echo $(hostname);bash -l /home/meshbits/misc_scripts/stats_new | grep -P -- 'KMD |BTC |-ASSET- ')\`\`\`"
*/10 * * * * bash /home/meshbits/misc_scripts/iguana_start.sh
EOF

chown meshbits.crontab /var/spool/cron/crontabs/meshbits
chmod 0600 /var/spool/cron/crontabs/meshbits

/etc/init.d/cron restart
