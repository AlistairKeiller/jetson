#!/bin/bash

echo "Making rootfs ( part 2 / final )"
/debootstrap/debootstrap --second-stage


# echo "Generating locale" # find an alternative
# locale-gen en_US.UTF-8
# update-locale LC_ALL=en_US.UTF-8


echo "Updating sources"
apt update


echo "Upgrading system"
apt upgrade -y


echo "Installing packages" # remove unnsesary packages from this install
apt install -y --no-install-recommends \
    `# keyring` \
    ubuntu-keyring \
    `# required packages for LT4` \
    libasound2 libcairo2 libdatrie1 libegl1 libegl1-mesa libevdev2 libfontconfig1 libgles2 libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 libgstreamer-plugins-bad1.0-0 libgtk-3-0 libharfbuzz0b libinput10 libjpeg-turbo8 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpixman-1-0 libpng16-16 libunwind8 libwayland-client0 libwayland-cursor0 libwayland-egl1-mesa libx11-6 libxext6 libxkbcommon0 libxrender1 python python3 \
    `# required system packages` \
    wget curl linux-firmware device-tree-compiler network-manager net-tools wireless-tools ssh \
    `# GUI` \
    xorg xubuntu-core onboard \
    `# desktop packages` \
    htop nano


echo "Cleaning up"
apt autoremove -y
apt clean