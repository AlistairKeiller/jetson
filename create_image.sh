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
sudo apt-get -q install libxml2-utils qemu-user-static


echo "Downloading BSP"
wget -qO jetson_bsp.tbz2 ${BSP_URL}


echo "Downloading samplefs"
wget -qO samplefs.tbz2 https://developer.nvidia.com/embedded/l4t/r32_release_v7.2/t210/tegra_linux_sample-root-filesystem_r32.7.2_aarch64.tbz2


echo "Extracting BSP"
tar -jpxf jetson_bsp.tbz2
rm jetson_bsp.tbz2


echo "Extracting samplefs into Linux_for_Tegra's rootfs"
cd Linux_for_Tegra/rootfs
tar -jpxf ../../samplefs.tbz2
rm ../../samplefs.tbz2


echo "Applying binary patches"
cd ..
./apply_binaries.sh


echo "Adding ${JETSON_USR} as user"
cd tools
./l4t_create_default_user.sh -u ${JETSON_USR} -p ${JETSON_PWD} -n ${JETSON_NAME} --autologin --accept-license

echo "Creating image"
./jetson-disk-image-creator.sh -o ../../jetson_image.img -b jetson-nano -r 300