#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



XEN=${YOCTO_DIR}/xen-generic-armv8-xt
XEN_CMD_LINE="dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"

DOM0_KERNEL=${YOCTO_DIR}/linux-dom0
DOM0_KERNEL_CMD_LINE="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen"
DOM0_INITRD=${YOCTO_DIR}/rootfs.dom0.cpio.gz

DOMD_ROOTFS=${YOCTO_DIR}/rootfs.domd.ext4



COMMAND=""
COMMAND+="sudo ${KVMTOOL_SOURCE_DIR}/lkvm run"
COMMAND+=" -k ${XEN}"
COMMAND+=" -p \"${XEN_CMD_LINE}\""
COMMAND+=" -m 8G"
COMMAND+=" -c 1"
COMMAND+=" --debug"
COMMAND+=" --e2h0"
COMMAND+=" --nested"
execute ${COMMAND}
