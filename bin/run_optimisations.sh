#!/usr/bin/env bash

# environment optimisation
ulimit -a
ulimit -n # see the number of open files
ulimit -n 1000000

grep 'ulimit -n 1000000' /etc/rc.local || sed -i '$iulimit -n 1000000' /etc/rc.local

grep '* soft nofile 1000000' /etc/security/limits.conf | \
sed -i '$i* soft nofile 1000000\n* hard nofile 1000000' /etc/security/limits.conf

grep 'session required pam_limits.so' /etc/pam.d/common-session \
|| sed -i '$isession required pam_limits.so' /etc/pam.d/common-session
