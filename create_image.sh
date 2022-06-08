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


echo "Making rootfs"
# debootstrap --arch=arm64 --foreign --variant=minbase ${RELEASE} rootfs
debootstrap --arch=arm64 --foreign ${RELEASE} rootfs
cp /usr/bin/qemu-aarch64-static rootfs/usr/bin/


echo "Setting repos"
echo "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE} main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-updates main restricted universe multiverse
deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports ${RELEASE}-security main restricted universe multiverse" | tee rootfs/etc/apt/sources.list


echo "Setting up schroot on host system"
echo "[jetson-image]
directory=$(pwd)/rootfs
root-users=root
type=directory" | tee /etc/schroot/chroot.d/jetson-image


echo "Installing packages in rootfs"
schroot -c jetson-image -- /debootstrap/debootstrap --second-stage
schroot -c jetson-image -- apt-get update
echo apt-get -y --no-install-recommends --allow-downgrades install $(xargs -a tools/samplefs/nvubuntu-bionic-aarch64-packages) | schroot -c jetson-image
scroot -c jetson-image -- sync
schroot -c jetson-image -- apt-get clean
schroot -c jetson-image -- sync


# rm "${target_qemu_path}"

# rm -rf var/lib/apt/lists/*
# rm -rf dev/*
# rm -rf var/log/*
# rm -rf var/cache/apt/archives/*.deb
# rm -rf var/tmp/*
# rm -rf tmp/*


echo "Applying binary patches"
./apply_binaries.sh


echo "Adding ${JETSON_USR} as user"
cd tools
./l4t_create_default_user.sh -u ${JETSON_USR} -p ${JETSON_PWD} -n ${JETSON_NAME} --autologin --accept-license


echo "Creating image"
./jetson-disk-image-creator.sh -o ../../jetson_image.img -b jetson-nano -r 300