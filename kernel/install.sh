#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')
readonly BACKUP_DIR=$(backup_dir)/boot/${TIMESTAMP}/



function update_initramfs( )
{
   execute " \
      sudo update-initramfs -c -k $(uname -r) \
   "
}

function update_grub( )
{
   execute " \
      sudo update-grub \
   "
}

function install_kernel( )
{
   execute " \
      mkdir -p ${BACKUP_DIR} && \
      sudo mv /boot/initrd.img* ${BACKUP_DIR} && \
      sudo mv /boot/config-* ${BACKUP_DIR} && \
      sudo mv /boot/System.map* ${BACKUP_DIR} && \
      sudo mv /boot/vmlinuz* ${BACKUP_DIR} \
   "

   execute " \
      sudo make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} install \
   "
}

function install_modules( )
{
   execute " \
      sudo make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} modules_install \
   "

   update_initramfs
}



cd ${KERNEL_SOURCE_DIR}
install_kernel
install_modules
update_grub
