#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

CONFIG_OPTIONS=""
CONFIG_OPTIONS+=" --target-list=aarch64-softmmu"
CONFIG_OPTIONS+=" --enable-user"
CONFIG_OPTIONS+=" --enable-slirp"
CONFIG_OPTIONS+=" --enable-tools"
CONFIG_OPTIONS+=" --enable-fdt"
CONFIG_OPTIONS+=" --enable-kvm"
CONFIG_OPTIONS+=" --enable-libusb"
CONFIG_OPTIONS+=" --enable-blkio"
CONFIG_OPTIONS+=" --enable-virtfs"
CONFIG_OPTIONS+=" --disable-gtk"
CONFIG_OPTIONS+=" --disable-sdl"
CONFIG_OPTIONS+=" --disable-opengl"
CONFIG_OPTIONS+=" --extra-cflags=\"-Wno-error=unused-result\""

cd ${QEMU_DIR}/source/
./configure "${CONFIG_OPTIONS}"
