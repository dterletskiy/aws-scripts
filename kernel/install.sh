#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')

# cd ${KERNEL_SOURCE_DIR}

BACKUP_DIR=$(backup_dir)/boot/${TIMESTAMP}/
execute " \
   mkdir -p ${BACKUP_DIR} && \
   sudo mv /boot/initrd.img* ${BACKUP_DIR} && \
   sudo mv /boot/config-* ${BACKUP_DIR} && \
   sudo mv /boot/System.map* ${BACKUP_DIR} && \
   sudo mv /boot/vmlinuz* ${BACKUP_DIR} \
"

execute " \
   sudo make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} modules_install \
"
execute " \
   sudo make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} install \
"
execute " \
   sudo update-initramfs -c -k 6.0.7 \
"
execute " \
   sudo update-grub \
"
