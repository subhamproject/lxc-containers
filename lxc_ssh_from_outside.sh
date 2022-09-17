#!/bin/bash
#https://blog.simos.info/how-to-use-the-lxd-proxy-device-to-map-ports-between-the-host-and-the-containers/

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

lxc profile create proxy

lxc profile device add proxy hostport2000 proxy connect="tcp:127.0.0.1:22" listen="tcp:0.0.0.0:3000"

 lxc profile add server-1 proxy
