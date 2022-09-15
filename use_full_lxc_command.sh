#!/bin/bash

lxc launch images:centos/8/amd64 cenots-8-c2
lxc launch images:ubuntu/xenial/amd64 ubuntu-xenial-c3
lxc launch images:ubuntu/bionic/amd64 ubuntu-bionic-c4
lxc launch images:ubuntu/focal/amd64 ubuntu-focal-c5
lxc launch images:ubuntu/jammy/amd64 ubuntu-jammy-c6
lxc launch images:opensuse/15.1/amd64 opensuse15-1-c10


lxc list --fast
lxc list | grep RUNNING
lxc list | grep STOPPED
lxc list | grep -i opensuse
lxc list "*c1*"
lxc list "*c2*"
lxc list



lxc exec containerName -- command
lxc exec containerName -- /path/to/script
lxc exec containerName --env EDITOR=/usr/bin/vim -- command
### run date, ip a, ip rm and other commands on various containers ###
lxc exec cenots-8-c2 -- date
lxc exec cenots-8-c2 -- ip a
lxc exec ubuntu-focal-c5 -- ip r
lxc exec fedora-31-c9 -- dnf -y update
lxc exec debian-10-www -- cat /etc/debian_version


lxc exec {container-name} {shell-name}
lxc exec debian-10-www bash
lxc exec alpine-c1 sh


lxc start {container-name}
lxc start oracle-8-c11


lxc stop {container-name}
lxc stop alpine-c1


lxc restart {container-name}
lxc restart gentoo-c8


lxc delete {container-name}
lxc delete ubuntu-xenial-c3



lxc stop ubuntu-xenial-c3 && lxc delete ubuntu-xenial-c3



lxc info
lxc info {container-name}
lxc info opensuse15-1-c10



lxc file pull {continer-nane}/{path/to/file} {/path/to/local/dest}
lxc file pull ubuntu-xenial-c3/var/www/nginx/app/config.php .


lxc file push {/path/to/file} {continer-nane}/path/to/dest/dir/
lxc file push config.php ubuntu-xenial-c3/var/www/nginx/app/
