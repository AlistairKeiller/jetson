echo "Seting variables"
bash set_variables.sh

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