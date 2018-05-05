#!/usr/bin/env bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "This script needs to run as a root user\n"
   exit 1
fi

cat > /var/spool/cron/crontabs/meshbits <<\EOF
*/30 * * * * bash /home/meshbits/misc_scripts/cron_recharge_utxos.sh
*/30 * * * * bash /usr/local/bin/slack_alert "#nn_reports" "\`\`\`$(echo $(hostname);/home/meshbits/misc_scripts/stats.sh false | grep -P -- 'KMD |BTC |-ASSET- ')\`\`\`"
EOF

chown meshbits.crontab /var/spool/cron/crontabs/meshbits
chmod 0600 /var/spool/cron/crontabs/meshbits
