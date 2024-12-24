#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



KVMTOOL_DUMP_DIR=${DUMP_DIR}/kvmtool/${TIMESTAMP}/
mkdir -p ${KVMTOOL_DUMP_DIR}
KVMTOOL_DT_DUMP_DIR=${KVMTOOL_DUMP_DIR}/dtb/
mkdir -p ${KVMTOOL_DT_DUMP_DIR}
KVMTOOL_DTB_DUMP=${KVMTOOL_DT_DUMP_DIR}/original.dtb
KVMTOOL_DTS_DUMP=${KVMTOOL_DT_DUMP_DIR}/original.dts
KVMTOOL_DTB_DUMP_RECOMPILE=${KVMTOOL_DT_DUMP_DIR}/recompiled.dtb

DTB=/home/ubuntu/workspace/dump/kvmtool/original.dtb

UBOOT=${YOCTO_DIR}/u-boot-generic-armv8-xt.bin

XEN=${YOCTO_DIR}/xen-generic-armv8-xt
XEN_CMD_LINE="dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"

DOM0_KERNEL=${YOCTO_DIR}/linux-dom0
DOM0_KERNEL_CMD_LINE="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen"
DOM0_INITRD=${YOCTO_DIR}/rootfs.dom0.cpio.gz

DOMD_ROOTFS=${YOCTO_DIR}/rootfs.domd.ext4



COMMAND=""
COMMAND+="sudo ${KVMTOOL_SOURCE_DIR}/lkvm run"
# COMMAND+=" -k ${UBOOT}"
COMMAND+=" -f /home/ubuntu/workspace/edk2/edk2-stable202411/source/Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/QEMU_EFI.fd"
# COMMAND+=" -k ${XEN}"
# COMMAND+=" -p \"${XEN_CMD_LINE}\""
# COMMAND+=" -i ${DOM0_KERNEL}"
COMMAND+=" -m 8G"
COMMAND+=" -c 1"
COMMAND+=" --debug"
COMMAND+=" --e2h0"
COMMAND+=" --nested"
COMMAND+=" --dump-dtb ${KVMTOOL_DTB_DUMP}"
execute ${COMMAND}

decompile_dt ${KVMTOOL_DTB_DUMP} ${KVMTOOL_DTS_DUMP}
compile_dt ${KVMTOOL_DTS_DUMP} ${KVMTOOL_DTB_DUMP_RECOMPILE}
