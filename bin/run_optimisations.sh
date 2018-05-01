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

apt-get -y -qq install --install-recommends linux-generic-hwe-16.04

# For `net.ipv4.tcp_congestion_control=bbr` you need a kernel > 4.9 and you have to load the kernel module.
if modprobe tcp_bbr 2> /dev/null; then
  if ! grep 'tcp_bbr' /etc/modules-load.d/modules.conf; then
    echo 'tcp_bbr' | sudo tee --append /etc/modules-load.d/modules.conf
    update-initramfs -u
  fi

  cat > /etc/sysctl.d/01-notary.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.ip_local_port_range = 16001 65530
net.core.somaxconn = 20480
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_fastopen = 3
EOF

  chmod 644 /etc/sysctl.d/01-notary.conf
  sysctl -p /etc/sysctl.d/01-notary.conf
  sysctl -w net.ipv4.route.flush=1
  sed -i "/^bash .*tmp_userdatarun.sh/d" /etc/rc.local
else
  echo -e "You need to restart the system and run this script again"
fi
