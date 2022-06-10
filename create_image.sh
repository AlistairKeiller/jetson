#!/bin/bash
echo "Seting variables"
RELEASE=focal
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v7.2/t210/jetson-210_linux_r32.7.2_aarch64.tbz2
SD_SIZE=128G


echo "Installing dependencies"
apt-get update
apt-get -y install debootstrap qemu-user-static binfmt-support libxml2-utils


echo "Downloading and Extracting BSP"
wget -qO- ${BSP_URL} | tar -xjp
cd Linux_for_Tegra/rootfs
rm README.txt


echo "Running debootstrap"
debootstrap --arch=arm64 --foreign --variant=minbase ${RELEASE} .
cp /usr/bin/qemu-aarch64-static usr/bin/
echo "nameserver 1.1.1.1" | tee etc/resolv.conf
chroot . /debootstrap/debootstrap --second-stage


echo "Setting repos"
echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE} main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-security main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-backports main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ bionic main" | tee etc/apt/sources.list


echo "Mounting rootfs"
mount --bind /sys ./sys
mount --bind /proc ./proc
mount --bind /dev ./dev
mount --bind /dev/pts ./dev/pts


echo "Installing packages"
chroot . apt-get update
chroot . apt-get -y install \
    libgles2 libpangoft2-1.0-0 libxkbcommon0 libwayland-egl1 libwayland-cursor0 libunwind8 libasound2 libpixman-1-0 libjpeg-turbo8 libinput10 libcairo2 device-tree-compiler iso-codes libffi6 libncursesw5 libdrm-common libdrm2 libegl-mesa0 libegl1 libegl1-mesa libgtk-3-0 python2 python-is-python2 libgstreamer1.0-0 libgstreamer-plugins-bad1.0-0 \
    bash-completion build-essential btrfs-progs cmake curl dnsutils htop iotop isc-dhcp-client iputils-ping kmod linux-firmware locales net-tools netplan.io pciutils python3-dev ssh sudo udev unzip usbutils neovim wpasupplicant \
    # lxqt


echo "Generating locales"
chroot . locale-gen en_US.UTF-8


echo "Enabling services"
chroot . systemctl enable ssh
chroot . systemctl enable systemd-networkd


echo "Unmounting rootfs"
chroot . sync
chroot . apt-get clean
chroot . sync
umount ./sys
umount ./proc
umount ./dev/pts
umount ./dev


echo "Configuring netplan"
echo "network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true" | tee etc/netplan/config.yaml


echo "Removing conflicting and unnecessary files"
rm usr/bin/qemu-aarch64-static
rm -rf var/lib/apt/lists/*
rm -rf dev/*
rm -rf var/log/*
rm -rf var/cache/apt/archives/*.deb
rm -rf var/tmp/*
rm -rf tmp/*


echo "Applying debs with Pythop's patches to nv-apply-debs.sh, which is called by apply_binaries.sh"
cd ../nv_tegra
wget -qO- https://raw.githubusercontent.com/pythops/jetson-nano-image/master/patches/nv-apply-debs.diff | patch nv-apply-debs.sh


echo "Applying binaries"
cd ..
./apply_binaries.sh


echo "Adding ${JETSON_USR} as user"
cd tools
./l4t_create_default_user.sh -u ${JETSON_USR} -p ${JETSON_PWD} -n ${JETSON_NAME} --autologin --accept-license


echo "Creating image"
./jetson-disk-image-creator.sh -o ../../jetson_image.img -b ${JETSON_BOARD} -r ${JETSON_BOARD_REV} -s ${SD_SIZE}