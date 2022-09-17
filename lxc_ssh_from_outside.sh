#!/bin/bash

Do below in host machine

root@ansible:~# cat .ssh/config
Host main
    HostName 10.10.100.111
    User ansible
    Port 2222
    ForwardAgent yes

Host ansible-client-1
    User ansible
    Port 22
    ProxyCommand ssh main nc ansible-client-1 22
    ForwardAgent yes
root@ansible:~#


Run below command to port forward from host to lxc container

lxc config device add ansible-client-1 myport22 proxy listen=tcp:0.0.0.0:2222(HOSTPORT) connect=tcp:127.0.0.1:22(CONTAINER PORT)



Create profile and add to lxc containers

#!/bin/bash

lxc profile create proxy-22

lxc profile device add proxy-22 hostport2000 proxy connect="tcp:127.0.0.1:22" listen="tcp:0.0.0.0:2000"

for I in $(lxc list -c ns --format csv|cut -d, -f1); do lxc profile add $I proxy-22; done
