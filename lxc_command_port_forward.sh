#!/bin/bash

# https://discuss.linuxcontainers.org/t/forward-port-80-and-443-from-wan-to-container/2042/4
#https://lxdware.com/forwarding-host-ports-to-lxd-instances/

lxc config device add ansible-client-1 myport80 proxy listen=tcp:0.0.0.0:80 connect=tcp:127.0.0.1:80


lxc config device remove ansible-client-1 myport80
