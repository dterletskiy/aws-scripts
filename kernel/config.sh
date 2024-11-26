#!/usr/bin/env bash

source ./common.sh

cd ${KERNEL_DIR}/source/
cp -v /boot/config-$(uname -r) .config
# make localmodconfig
make menuconfig
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
scripts/config --set-str CONFIG_SYSTEM_TRUSTED_KEYS ""
scripts/config --set-str CONFIG_SYSTEM_REVOCATION_KEYS ""
