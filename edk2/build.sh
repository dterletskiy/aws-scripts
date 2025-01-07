#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

cd ${EDK2_SOURCE_DIR}

source edksetup.sh

make -C BaseTools

build -t GCC5 -a AARCH64 -p ArmVirtPkg/ArmVirtKvmTool.dsc
build -t GCC5 -a AARCH64 -p ArmVirtPkg/ArmVirtQemu.dsc

cd ${EDK2_SOURCE_DIR}/Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/
dd of="QEMU_EFI-pflash.raw" if="/dev/zero" bs=1M count=64
dd of="QEMU_EFI-pflash.raw" if="QEMU_EFI.fd" conv=notrunc
dd of="QEMU_VARS-pflash.raw" if="/dev/zero" bs=1M count=64
dd of="QEMU_VARS-pflash.raw" if="QEMU_VARS.fd" conv=notrunc
