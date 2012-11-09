#!/bin/sh

set -e

# AUTHOR: Thomas Nitsche
#  EMAIL: thomas.nitsche@experteer.com
#   DESC: try to detect current install branch and merge it to master

current_install=`cat CURRENT_INSTALL`


echo " *** git checkout master " && git checkout master
echo " *** git pull " && git pull

read -N1 -p "merge $current_install to master? (y/n)"
[[ $REPLY = [yY] ]] && echo " *** git merge $current_install " && git merge $current_install || { echo " You didn't answer yes, or git merge $current_install failed."; exit 1; }

echo " *** git checkout $current_install " && git checkout $current_install




# -*- sh -*- vim:set ft=sh ai et sw=2 sts=2:

