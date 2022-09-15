#!/bin/bash

shopt -s xpg_echo

CONFIG="/tmp/config.yaml"

function log_msg {
current_time=$(date "+%Y-%m-%d %H:%M:%S.%3N")
log_level=$1
log_msg="${@:2}"
if [[ $1 == WARNING ]];then
echo "[$current_time] $log_level - $log_msg"
else
echo -n "[$current_time] $log_level - $log_msg"
fi
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
YELLOW="\033[0;33m"


log_info "${GREEN} Installing LXD Using Snap.. ${CLEAR}"
sudo snap install lxd
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
chmod 777 $CONFIG
echo " OK!"

log_info "${GREEN} Initialise LXD Using Preseed File.. ${CLEAR}"
cat $CONFIG | sudo lxd init --preseed
echo " OK!"

log_info "${GREEN} LXD setup Done!!  ${CLEAR}"
echo " OK!"

log_info "${GREEN} LXC Installed version $(lxc version).. ${CLEAR}"
echo " OK!"

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}


image_list=("ubuntu:18.04" "ubuntu:20.04" "ubuntu:22.04" "ubuntu:20.04")
#images:centos/7

function spin_server() {
sleep 30
echo "PLEASE WAIT SPINING UP ALL THE SERVERS MAY TAKE A WHILE"
for count in {1..2}
do
log_info "${GREEN} Starting Server client-$count.. ${CLEAR}"
image=$(select_random "${image_list[@]}")
sudo lxc launch "${image}" client-$count
echo " OK!"
done
}

function run_script() {
for count in {1..2}
do
log_info "${GREEN} Adding ansible user to server.. ${CLEAR}"
sudo lxc exec client-$count -- bash /tmp/config.sh
echo " OK!"
done
}


function copy_script() {
while  [ $(lxc ls -c ns --format=csv|grep RUNNING|cut -f1 -d,|wc -l) -lt 2 ] ;do
log_warn "${YELLOW} Waiting for all containers to come up.. ${CLEAR}"
sleep 1
done
echo " OK!"
for count in {1..2}
do
log_info "${GREEN} Copying script in client-$count server.. ${CLEAR}"
sudo lxc exec client-$count "useradd vagrant"
[ $? -eq 0 ] && sudo lxc file push /tmp/config.sh client-$count/tmp/
echo " OK!"
done
run_script
}

spin_server
copy_script
