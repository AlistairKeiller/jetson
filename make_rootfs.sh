echo "Seting variables"
RELEASE=bionic
JETSON_NAME=jetski
JETSON_USR=alistair
JETSON_PWD=password
JETSON_BOARD=jetson-nano
JETSON_BOARD_REV=300
BSP_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v6.1/t210/jetson-210_linux_r32.6.1_aarch64.tbz2
WORK_DIR=/home/runner/work/jetson/jetson


echo "Installing packages on host system"
apt update
apt install -y debootstrap qemu-user-static binfmt-support schroot # make sure these packages are nessesary


echo "Making rootfs" # I know qemu-debootstrap is depricated, but because its a wrapper for debootstrap, it has eiser syntax and identical output to just using debootstrap.
qemu-debootstrap --arch=arm64 ${RELEASE} ${WORK_DIR}/rootfs


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


echo "Entering schroot"
schroot -c jetson-image -u root


echo "Generating locale"
locale-gen en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8


echo "Updating sources"
apt update


echo "Upgrading system"
apt upgrade -y


echo "Installing packages" # remove unnsesary packages from this install
apt install -y --no-install-recommends \
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


echo "Removing files that conflict with LT4" # might not be nessesary
rm ${WORK_DIR}/rootfs/dev/random ${WORK_DIR}/rootfs/dev/urandom


echo "Downloading BSP"
wget -O ${WORK_DIR}/JETSON_BSP.tbz2 ${BSP_URL}


echo "Extracting BSP"
tar -jpxf ${WORK_DIR}/JETSON_BSP.tbz2 -C ${WORK_DIR}


echo "Removing tar"
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