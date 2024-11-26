#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

cd ${QEMU_DIR}/source/

sudo make modules_install
sudo make install
# sudo update-initramfs -c -k 6.0.7
sudo update-grub
