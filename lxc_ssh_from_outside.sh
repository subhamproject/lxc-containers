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

lxc config device add ansible-client-1 myport22 proxy listen=tcp:0.0.0.0:2222 connect=tcp:127.0.0.1:22

