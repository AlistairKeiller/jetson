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