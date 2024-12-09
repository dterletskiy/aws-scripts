#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



QEMU_DUMP_DIR=${DUMP_DIR}/qemu/${TIMESTAMP}/
mkdir -p ${QEMU_DUMP_DIR}

COMMAND_FILE=${QEMU_DUMP_DIR}/command.txt

QEMU_DT_DUMP_DIR=${QEMU_DUMP_DIR}/dtb/
QEMU_DTB_DUMP=${QEMU_DT_DUMP_DIR}/original.dtb
QEMU_DTS_DUMP=${QEMU_DT_DUMP_DIR}/original.dts
QEMU_DTB_DUMP_RECOMPILE=${QEMU_DT_DUMP_DIR}/recompiled.dtb
QEMU_LOG_DUMP=${QEMU_DUMP_DIR}/log.txt
QEMU_RECORD_DUMP=${QEMU_DUMP_DIR}/record.bin
QEMU_PID=${QEMU_DUMP_DIR}/pid.txt

QEMU_DIR=${QEMU_DEPLOY_DIR}/usr/local/
QEMU_ARM64=${QEMU_DIR}/bin/qemu-system-aarch64

XEN=${YOCTO_DIR}/xen-generic-armv8-xt
XEN_CMD_LINE="dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"

DOM0_KERNEL=${YOCTO_DIR}/linux-dom0
DOM0_KERNEL_CMD_LINE="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen"
DOM0_INITRD=${YOCTO_DIR}/rootfs.dom0.cpio.gz

DOMD_ROOTFS=${YOCTO_DIR}/rootfs.domd.ext4



sudo ${KVMTOOL_SOURCE_DIR}/lkvm run \
   -k ${XEN} \
   -p "${XEN_CMD_LINE}" \
   -m 512 \
   -c 2
