#!/bin/bash
echo "Seting variables"
RELEASE=bionic
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v7.2/t210/jetson-210_linux_r32.7.2_aarch64.tbz2


echo "Downloading BSP tar"
wget -qO JETSON_BSP.tbz2 ${BSP_URL}


echo "Extracting BSP tar"
tar -jpxf JETSON_BSP.tbz2


echo "Removing BSP tar"
rm JETSON_BSP.tbz2


echo "Building samplefs"
cd Linux_for_Tegra/tools/samplefs
./nv_build_samplefs.sh --abi aarch64 --distro ubuntu --version bionic


echo "Moving samplefs to rootfs"
cd ../../rootfs
tar -jpxf ../tools/samplefs/sample_fs.tbz2
rm ../tools/samplefs/sample_fs.tbz2


echo "Applying binary patches"
cd ..
./apply_binaries.sh