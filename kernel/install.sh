#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

# cd ${KERNEL_SOURCE_DIR}

sudo make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} modules_install
sudo make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} install
# sudo update-initramfs -c -k 6.0.7
sudo update-grub
