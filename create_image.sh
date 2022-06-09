#!/bin/bash
echo "Seting variables"
RELEASE=focal
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r34_release_v1.1/release/jetson_linux_r34.1.1_aarch64.tbz2

echo "Installing dependencies"
sudo apt-get -y install debootstrap qemu-user-static binfmt-support libxml2-utils


echo "Downloading BSP"
wget -qO jetson_bsp.tbz2 ${BSP_URL}


echo "Extracting BSP"
tar -jpxf jetson_bsp.tbz2
rm jetson_bsp.tbz2
cd Linux_for_Tegra/rootfs
rm README.txt


echo "Starting debootstrap"
debootstrap --variant=minbase --arch=arm64 --foreign ${RELEASE} .
cp /usr/bin/qemu-aarch64-static usr/bin/


echo "Mounting rootfs"
mount /sys ./sys -o bind
mount /proc ./proc -o bind
mount /dev ./dev -o bind
mount /dev/pts ./dev/pts -o bind


echo "Finishing debootstrap"
chroot . /debootstrap/debootstrap --second-stage


echo "Setting repos"
echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE} main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-security main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-backports main restricted universe multiverse" | tee etc/apt/sources.list


echo "Installing packages"
chroot . apt-get update
echo apt-get -y install $(cut -d"=" -f1  ../tools/samplefs/nvubuntu-focal-desktop-aarch64-packages | xargs) | DEBIAN_FRONTEND=noninteractive chroot .
chroot . sync
chroot . apt-get clean
chroot . sync


echo "Unmounting rootfs"
umount ./sys
umount ./proc
umount ./dev/pts
umount ./dev


echo "Removing conflicting and unnecessary files"
rm usr/bin/qemu-aarch64-static
rm -rf var/lib/apt/lists/*
rm -rf dev/*
rm -rf var/log/*
rm -rf var/cache/apt/archives/*.deb
rm -rf var/tmp/*
rm -rf tmp/*


echo "Applying binary patches"
cd ..
./apply_binaries.sh


echo "Adding ${JETSON_USR} as user"
cd tools
./l4t_create_default_user.sh -u ${JETSON_USR} -p ${JETSON_PWD} -n ${JETSON_NAME} --autologin --accept-license


echo "Creating image"
./jetson-disk-image-creator.sh -o ../../jetson_image.img -b jetson-nano -r 300