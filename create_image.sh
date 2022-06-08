#!/bin/bash
echo "Seting variables"
RELEASE=bionic
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v7.2/t210/jetson-210_linux_r32.7.2_aarch64.tbz2

echo "Installing dependencies"
sudo apt-get -y install debootstrap qemu-user-static binfmt-support libxml2-utils schroot


echo "Downloading BSP"
wget -qO jetson_bsp.tbz2 ${BSP_URL}


echo "Extracting BSP"
tar -jpxf jetson_bsp.tbz2
rm jetson_bsp.tbz2
cd Linux_for_Tegra


echo "Starting debootstrap"
# debootstrap --arch=arm64 --foreign --variant=minbase ${RELEASE} rootfs
debootstrap --arch=arm64 --foreign ${RELEASE} rootfs
cp /usr/bin/qemu-aarch64-static rootfs/usr/bin/


echo "Setting up schroot on host system"
echo "[jetson-image]
directory=$(pwd)/rootfs
root-users=root
type=directory" | tee /etc/schroot/chroot.d/jetson-image


echo "Finishing debootstrap"
schroot -c jetson-image -- /debootstrap/debootstrap --second-stage


echo "Setting repos"
echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE} main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-security main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-backports main restricted universe multiverse" | tee rootfs/etc/apt/sources.list


echo "Installing packages"
schroot -c jetson-image -- apt-get update
schroot -c jetson-image -- echo "console-setup console-setup/charmap47 select UTF-8" | debconf-set-selections
for package in $(cut -f 1 -d "=" tools/samplefs/nvubuntu-bionic-aarch64-packages)
do
    schroot -c jetson-image -- apt-get -y install ${package}
done
# echo apt-get -y --no-install-recommends install $(cut -f 1 -d "=" tools/samplefs/nvubuntu-bionic-aarch64-packages | xargs) | schroot -c jetson-image
schroot -c jetson-image -- sync
schroot -c jetson-image -- apt-get clean
schroot -c jetson-image -- sync


rm rootfs/usr/bin/qemu-aarch64-static
rm -rf var/lib/apt/lists/*
rm -rf dev/*
rm -rf var/log/*
rm -rf var/cache/apt/archives/*.deb
rm -rf var/tmp/*
rm -rf tmp/*


echo "Applying binary patches"
./apply_binaries.sh


echo "Adding ${JETSON_USR} as user"
cd tools
./l4t_create_default_user.sh -u ${JETSON_USR} -p ${JETSON_PWD} -n ${JETSON_NAME} --autologin --accept-license


echo "Creating image"
./jetson-disk-image-creator.sh -o ../../jetson_image.img -b jetson-nano -r 300