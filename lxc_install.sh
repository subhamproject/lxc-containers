#!/bin/bash

shopt -s xpg_echo

CONFIG="/tmp/config.yaml"

function log_msg {
current_time=$(date "+%Y-%m-%d %H:%M:%S.%3N")
log_level=$1
log_msg="${@:2}"
echo -n "[$current_time] $log_level - $log_msg"
}

function log_error {
log_msg "ERROR" "$@"
}

function log_info {
log_msg "INFO " "$@"
}

function log_warn {
log_msg "WARNING" "$@"
}

RED="\033[0;31m"
GREEN="\033[0;32m"
CLEAR="\033[0m"


log_info "${GREEN} Installing LXD Using Snap if NOT exist.. ${CLEAR}"
[ ! -z "$(command -v lxc)" ] ||  snap install lxd
echo " OK!"

log_info "${GREEN} Create Preseed File.. ${CLEAR}"

cat >> $CONFIG << EOF
    config: {}
    networks:
    - config:
             ipv4.address: auto
             ipv6.address: auto
      description: "Custom Profile for Ansible Client Machine"
      managed: false
      name: lxdbr0
      type: bridge
    storage_pools:
    - config:
         size: 20GB
      description: ""
      name: default
      driver: btrfs
    profiles:
    - config: {}
      description: "Custom Profile for Ansible Client Machine"
      devices:
              eth0:
                name: eth0
                nictype: bridged
                parent: lxdbr0
                type: nic
              root:
                path: /
                pool: default
                type: disk
      name: default
    cluster: null
EOF
echo " OK!"

log_info "${GREEN} Initialise LXD Using Preseed File.. ${CLEAR}"
cat $CONFIG | lxd init --preseed
echo " OK!"

log_info "${GREEN} LXD setup Done!!.. ${CLEAR}"
echo " OK!"

log_info "${GREEN} LXC Installed version $(lxc version).. ${CLEAR}"
echo " OK!"
