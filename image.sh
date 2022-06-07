#!/bin/bash


echo "Seting variables"
RELEASE=bionic
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v6.1/t210/jetson-210_linux_r32.6.1_aarch64.tbz2


echo "Installing packages on host system"
apt update
apt install -y debootstrap qemu-user-static binfmt-support libxml2-utils schroot


echo "Making rootfs"
# debootstrap --arch=arm64 --foreign --variant=minbase ${RELEASE} rootfs
debootstrap --arch=arm64 --foreign ${RELEASE} rootfs
cp /usr/bin/qemu-aarch64-static rootfs/usr/bin/


echo "Setting network config" # this may not be nesseary
echo "network:
    version: 2
    renderer: NetworkManager" | tee /etc/netplan/01-netconf.yaml


echo "Setting repos"
echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE} main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-security main restricted universe multiverse" | tee rootfs/etc/apt/sources.list


echo "Setting device name"
echo "${JETSON_NAME}" | tee rootfs/etc/hostname


echo "Making ${JETSON_USR} a sudoer"
echo "${JETSON_USR} ALL=(ALL) NOPASSWD: ALL" | tee rootfs/etc/sudoers.d/${JETSON_USR}


echo "Setting up schroot on host system"
echo "[jetson-image]
directory=$(pwd)/rootfs
root-users=root
type=directory" | tee /etc/schroot/chroot.d/jetson-image


echo "Running schroot script"
cat schroot.sh | schroot -c jetson-image


echo "Removing files that conflict with LT4" # might not be nessesary
rm rootfs/dev/random rootfs/dev/urandom


echo "Downloading BSP tar"
wget -qO JETSON_BSP.tbz2 ${BSP_URL}


echo "Extracting BSP tar"
tar -jpxf JETSON_BSP.tbz2


echo "Removing BSP tar"
rm JETSON_BSP.tbz2


echo "Moving rootfs to BSP"
rm -r Linux_for_Tegra/rootfs
mv rootfs Linux_for_Tegra


echo "Applying jetson binaries"
cd Linux_for_Tegra
./apply_binaries.sh


echo "Adding ${JETSON_USR} as user"
cd tools
./l4t_create_default_user.sh -u ${JETSON_USR} -p ${JETSON_PWD} -n ${JETSON_NAME} --autologin --accept-license


echo "Printing available space" # For Debugging
df -h


echo "creating image"
./jetson-disk-image-creator.sh -o ../../JETSON.img -b ${JETSON_BOARD} -r ${JETSON_BOARD_REV}