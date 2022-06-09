#!/bin/bash
echo "Seting variables"
RELEASE=focal
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v7.2/t210/jetson-210_linux_r32.7.2_aarch64.tbz2

echo "Installing dependencies"
apt-get update
apt-get -y install debootstrap qemu-user-static binfmt-support libxml2-utils


echo "Downloading BSP"
wget -qO jetson_bsp.tbz2 ${BSP_URL}


echo "Extracting BSP"
tar -jpxf jetson_bsp.tbz2
rm jetson_bsp.tbz2
cd Linux_for_Tegra/rootfs
rm README.txt


echo "Running debootstrap"
debootstrap --arch=arm64 --foreign --variant=minbase ${RELEASE} .
cp /usr/bin/qemu-aarch64-static usr/bin/
echo "nameserver 1.1.1.1" | tee etc/resolv.conf
chroot . /debootstrap/debootstrap --second-stage


echo "Mounting rootfs"
mount --bind /sys ./sys
mount --bind /proc ./proc
mount --bind /dev ./dev
mount --bind /dev/pts ./dev/pts


echo "test"
chroot . apt-get update


# echo "Setting repos"
# echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE} main restricted universe multiverse
# deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-updates main restricted universe multiverse
# deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-security main restricted universe multiverse
# deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-backports main restricted universe multiverse" | tee etc/apt/sources.list


# echo "Installing packages"
# chroot . apt-get update
# chroot . apt-get install -y \
#     libgles2 libpangoft2-1.0-0 libxkbcommon0 libwayland-egl1 libwayland-cursor0 libunwind8 libasound2 libpixman-1-0 libjpeg-turbo8 libinput10 libcairo2 device-tree-compiler iso-codes libffi6 libncursesw5 libdrm-common libdrm2 libegl-mesa0 libegl1 libegl1-mesa libgtk-3-0 python2 python-is-python2 libgstreamer1.0-0 libgstreamer-plugins-bad1.0-0 \
#     bash-completion build-essential btrfs-progs cmake curl dnsutils htop iotop isc-dhcp-client iputils-ping kmod linux-firmware locales net-tools netplan.io pciutils python3-dev ssh sudo udev unzip usbutils neovim wpasupplicant
# chroot . sync
# chroot . apt-get clean
# chroot . sync


# echo "Unmounting rootfs"
# umount ./sys
# umount ./proc
# umount ./dev/pts
# umount ./dev


# echo "Removing conflicting and unnecessary files"
# rm usr/bin/qemu-aarch64-static
# rm -rf var/lib/apt/lists/*
# rm -rf dev/*
# rm -rf var/log/*
# rm -rf var/cache/apt/archives/*.deb
# rm -rf var/tmp/*
# rm -rf tmp/*


# echo "Applying binary patches"
# cd ..
# ./apply_binaries.sh


# echo "Creating image"
# ./jetson-disk-image-creator.sh -o ../../jetson_image.img -b jetson-nano -r 300