#!/bin/bash

echo "Seting variables"
RELEASE=jammy
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v7.2/t210/jetson-210_linux_r32.7.2_aarch64.tbz2
WORK_DIR=/home/runner/work/jetson/jetson


echo "Installing packages on host system"
apt update
apt install -y debootstrap qemu-user-static binfmt-support schroot


echo "Making rootfs"
debootstrap --arch=arm64 --foreign --variant=minbase ${RELEASE} ${WORK_DIR}/rootfs
cp /usr/bin/qemu-aarch64-static ${WORK_DIR}/rootfs/usr/bin/


echo "Setting network config" # make sure this is nesseary
echo "network:
    version: 2
    renderer: NetworkManager" | tee ${WORK_DIR}/rootfs/etc/netplan/01-netconf.yaml


echo "Setting repos" # remove restricted, universe, and multiverse if possible
echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE} main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-security main restricted universe multiverse" | tee ${WORK_DIR}/rootfs/etc/apt/sources.list

echo "Setting device name"
echo "${JETSON_NAME}" | tee ${WORK_DIR}/rootfs/etc/hostname


echo "Setting up schroot on host system"
echo "[jetson-image]
directory=${WORK_DIR}/rootfs
root-users=root
type=directory" | tee /etc/schroot/chroot.d/jetson-image

schroot -c jetson-image bash ${WORK_DIR}/schroot.sh


# echo "Removing QEMU"
# rm ${WORK_DIR}/rootfs/usr/bin/qemu-aarch64-static


echo "Removing files that conflict with LT4" # might not be nessesary
rm ${WORK_DIR}/rootfs/dev/random ${WORK_DIR}/rootfs/dev/urandom


echo "Downloading BSP tar"
wget -qO ${WORK_DIR}/JETSON_BSP.tbz2 ${BSP_URL}


echo "Extracting BSP tar"
tar -jpxf ${WORK_DIR}/JETSON_BSP.tbz2 -C ${WORK_DIR}


echo "Removing BSP tar"
rm ${WORK_DIR}/JETSON_BSP.tbz2


echo "Moving rootfs to BSP"
rm -r ${WORK_DIR}/Linux_for_Tegra/rootfs
mv ${WORK_DIR}/rootfs ${WORK_DIR}/Linux_for_Tegra


echo "Applying jetson binaries"
cd ${WORK_DIR}/Linux_for_Tegra/
./apply_binaries.sh


echo "Adding ${JETSON_USR} as user"
cd ${WORK_DIR}/Linux_for_Tegra/tools
./l4t_create_default_user.sh -u ${JETSON_USR} -p ${JETSON_PWD}


echo "Making ${JETSON_USR} a sudoer"
echo "${JETSON_USR} ALL=(ALL) NOPASSWD: ALL" | tee ${WORK_DIR}/Linux_for_Tegra/rootfs/etc/sudoers.d/${JETSON_USR}


echo "creating image"
cd ${WORK_DIR}/Linux_for_Tegra/tools
./jetson-disk-image-creator.sh -o ${WORK_DIR}/JETSON.img -b ${JETSON_BOARD} -r ${JETSON_BOARD_REV}