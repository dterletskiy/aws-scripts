#!/usr/bin/env bash

source ./common.sh

cd ${QEMU_DIR}/source/

sudo make modules_install
sudo make install
# sudo update-initramfs -c -k 6.0.7
sudo update-grub