#!/bin/bash

function sudo_conf() {
cat > /etc/sudoers.d/ansible << EOF
%ansible  ALL=(ALL) NOPASSWD:ALL
EOF
}

function add_user() {
case $(egrep '^(NAME)=' /etc/os-release|cut -d'=' -f2|sed 's|"||g') in
"CentOS Linux")
sudo yum install openssh-server openssl -y
sudo service sshd start
sudo useradd -p $(openssl passwd -1 password) -m -d /home/ansible -s /bin/bash ansible
sudo_conf
;;
*)
sudo useradd -p $(openssl passwd -1 password) -m -d /home/ansible -s /bin/bash ansible
sudo sed -i "/^PasswordAuthentication/s; .*$; yes;" /etc/ssh/sshd_config
sudo service sshd restart
sudo_conf
;;
esac
}


add_user
