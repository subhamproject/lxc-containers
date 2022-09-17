#!/bin/bash


lxc profile create new

lxc profile show macvlan

ip route show default 0.0.0.0/0

lxc profile device add new eth0 nic nictype=macvlan parent=eth1

lxc launch ubuntu:18.04 net2 --profile default --profile new

lxc list
