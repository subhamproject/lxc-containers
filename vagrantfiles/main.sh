#!/bin/bash

shopt -s xpg_echo
ANSIBLE_CONF="/home/vagrant/ansible.cfg"
HOST_FILE="/home/vagrant/hosts"
PLAY_BOOK="/home/vagrant/sample_play.yaml"

echo -e "[devops]" > $HOST_FILE

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
sudo snap install lxd --channel=4.0/stable
sudo snap set lxd daemon.debug=true; sudo systemctl reload snap.lxd.daemon
sleep 5
echo " OK!"

log_info "${GREEN} Create Preseed File.. ${CLEAR}"

cat > $ANSIBLE_CONF << EOF
[defaults]
inventory = ./hosts
host_key_checking = False
pipelining = True
roles_path = ./roles
forks = 2
#callbacks_enabled = timer, profile_tasks, profile_roles
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
deprecation_warnings=False
EOF

cat > $PLAY_BOOK << EOF
---
- name: This is sample playbook for ansible client testing
  hosts: devops
  gather_facts: true
  become: true

  tasks:
  - name: Getting uptime from server
    shell:
      cmd: |
         uptime
    register: output
  - debug:
       msg: "Uptime of server {{ inventory_hostname }} is {{ output.stdout }}"
EOF

cat > $CONFIG << EOF
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
      description: ""
      name: default
      driver: dir
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
sudo chmod +x $CONFIG
echo " OK!"

log_info "${GREEN} Initialise LXD Using Preseed File.. ${CLEAR}"
sleep 2
sudo lxd init --preseed <$CONFIG
sleep 300
sudo systemctl reload snap.lxd.daemon
echo " OK!"

log_info "${GREEN} LXD setup Done!!  ${CLEAR}"
echo " OK!"

log_info "${GREEN} LXC Installed version $(lxc version).. ${CLEAR}"
echo " OK!"

select_random() {
    printf "%s\0" "$@" | shuf -z -n1 | tr -d '\0'
}


image_list=("ubuntu:18.04" "ubuntu:20.04" "ubuntu:22.04" "images:centos/7")
#image_list=("ubuntu:18.04" "ubuntu:20.04" "ubuntu:20.04" "ubuntu:20.04")
#images:centos/7

function spin_server() {
sleep 15
while [ $(lxc list|wc -l) -lt 1 ];do
log_info "${GREEN} Waiting for LXC service to Start and Settled.. ${CLEAR}"
sleep 1
done
log_info "*** ${GREEN} PLEASE WAIT SPINNING UP ALL THE SERVERS MAY TAKE A WHILE *** ${CLEAR}"
echo -e "\n"
sleep 60
for count in {1..4}
do
sleep 15
image=$(select_random "${image_list[@]}")
log_info "${GREEN} Starting Server ansible-client-$count with Image ${image} - Please Wait.. ${CLEAR}"
sudo lxc launch "${image}" ansible-client-$count </dev/null
sudo lxc start ansible-client-$count </dev/null
echo " OK!"
done
}

function run_script() {
server=$1
log_info "${GREEN} Adding ansible user to $server.. ${CLEAR}"
sudo lxc exec $server -- bash /tmp/config.sh  </dev/null
echo " OK!"
}

function wait_for_server() {
sleep 10
CONTAINER=$1
sudo lxc start $CONTAINER </dev/null
while  [ $(sudo lxc ls -c ns --format csv $CONTAINER|grep RUNNING|cut -f1 -d,|wc -l) -lt 1 ] ;do
log_warn "${YELLOW} Waiting for ${CONTAINER} to Come up - Please Wait.. ${CLEAR}"
sleep 1
done
IP_ADDR=$(sudo lxc ls -c ns4 --format csv $CONTAINER|cut -d, -f3|cut -d' ' -f1)
sudo echo -e "$IP_ADDR" >> $HOST_FILE
echo " OK!"
}

function copy_script() {
for count in {1..4}
do
wait_for_server ansible-client-$count
sleep 10
log_info "${GREEN} Copying Script in ansible-client-$count Server - Please Wait.. ${CLEAR}"
echo -e "\n"
sudo lxc exec ansible-client-$count -- useradd vagrant </dev/null
[ $? -eq 0 ] && sudo lxc file push /tmp/config.sh ansible-client-$count/tmp/ </dev/null && run_script ansible-client-$count
echo " OK!"
done
}

spin_server
copy_script

cat >> $HOST_FILE << EOF
[devops:vars]
ansible_ssh_user=ansible
ansible_ssh_pass=password
EOF

sudo chown -R vagrant:vagrant /home/vagrant/*
[ $? -eq 0 ] && \
log_info "${GREEN} *** RUNNING SAMPLE PLAYBOOK TO GET UPTIME FROM ALL THE SERVERS *** ${CLEAR}" && \
ansible-playbook $PLAY_BOOK
