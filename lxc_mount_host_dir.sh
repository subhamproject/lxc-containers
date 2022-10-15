#!/bin/bash
#https://www.cyberciti.biz/faq/how-to-add-or-mount-directory-in-lxd-linux-container/

lxc config device add ansible-client-2 external-disk disk source=/data path=/data


lxc config device add {container-name} {name} disk source={/path/to/source/dir/} path={/path/to/dest/onto/container/}




IMP

#https://canonical.com/blog/ros-development-with-lxd

devices:
  PASocket:
    path: /tmp/.pulse-native
    source: /run/user/1000/pulse/native
    type: disk
  X0:
    path: /tmp/.X11-unix/X0
    source: /tmp/.X11-unix/X0
    type: disk
  mygpu:
    type: gpu
name: gui
used_by:

https://gist.github.com/bloodearnest/ebf044476e70c4baee59c5000a10f4c8

# this section adds your \$HOME directory into the container. This is useful for vim, bash and ssh config, and such like.
devices:
  home:
    type: disk
    source: $HOME
    path: $HOME
