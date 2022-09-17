#!/bin/bash
#https://www.cyberciti.biz/faq/how-to-add-or-mount-directory-in-lxd-linux-container/

lxc config device add ansible-client-2 external-disk disk source=/data path=/data


lxc config device add {container-name} {name} disk source={/path/to/source/dir/} path={/path/to/dest/onto/container/}
