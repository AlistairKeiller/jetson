#!/bin/bash
echo "Making rootfs ( part 2 / final )"
/debootstrap/debootstrap --second-stage


echo "Updating sources"
apt-get update


echo "Installing packages" # remove unnsesary packages from this install
apt-get -yq install ${package_list}


echo "Cleaning up"
sync
apt-get clean
sync