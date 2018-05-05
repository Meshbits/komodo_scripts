#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo -e "This script needs to run as a root user\n"
   exit 1
fi

VAR_NPROC="$(cat /proc/cpuinfo | grep processor | wc -l)"

# Create sudo wrapper
cat > /usr/local/bin/sudo_wrapper <<\EOF
#!/usr/bin/env bash
set -e
sudo -H -u ${USER} /bin/bash -l -c -- "$@"
EOF
chmod +x /usr/local/bin/sudo_wrapper

# Create slack alert wrapper
cat > /usr/local/bin/slack_alert <<\EOF
[[ -f "${HOME}/.common/config" ]]; source "${HOME}/.common/config"
if [[ ! -z ${1+x} ]]; then
  SLACK_CHANNEL=${1}
  shift
fi
for items in SLACK_CHANNEL SLACK_USERNAME SLACK_URL SLACK_EMOJI; do
  if [[ -z ${items+x} ]]; then
    echo -e "Unset variable: ${item}"
    exit 1
  fi
done

curl -X POST --data-urlencode \
  "payload={\"channel\": \"${SLACK_CHANNEL}\", \"username\": \"${SLACK_USERNAME}\", \"text\": \"$*\", \"icon_emoji\": \"${SLACK_EMOJI}\"}" \
  ${SLACK_URL}
EOF
chmod +x /usr/local/bin/slack_alert

# Script for monit
cat > /usr/local/bin/slack_monit.sh <<\EOF
#!/usr/bin/env bash
[[ -f "${HOME}/.common/config" ]]; source "${HOME}/.common/config"
for items in SLACK_CHANNEL SLACK_USERNAME SLACK_URL SLACK_EMOJI; do
  if [[ -z ${items+x} ]]; then
    echo -e "Unset variable: ${item}"
    exit 1
  fi
done

COLOR=${MONIT_COLOR:-$([[ $MONIT_EVENT == *"succeeded"* ]] && echo good || echo danger)}
TEXT=$(echo -e "$MONIT_EVENT: $MONIT_DESCRIPTION" | python3 -c "import json,sys;print(json.dumps(sys.stdin.read()))")

PAYLOAD="{
  \"attachments\": [
    {
      \"text\": $TEXT,
      \"color\": \"$COLOR\",
      \"mrkdwn_in\": [\"text\"],
      \"fields\": [
        { \"title\": \"Date\", \"value\": \"$MONIT_DATE\", \"short\": true },
        { \"title\": \"Host\", \"value\": \"$MONIT_HOST\", \"short\": true }
      ]
    }
  ]
}"

curl -s -X POST --data-urlencode "payload=${PAYLOAD}" ${SLACK_URL}
EOF
sudo chmod +x /usr/local/bin/slack_monit.sh


# Install and enable monit and copy config
apt-get -y -qq install monit
sed -e "s|<VAR_NPROC>|${VAR_NPROC}|" \
  $(dirname $0)/../conf/monit/monitrc > /etc/monit/monitrc
chmod 0600 /etc/monit/monitrc
sudo systemctl disable monit
