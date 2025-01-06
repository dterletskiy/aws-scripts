#!/usr/bin/env bash

# x/32i 0x0000000040000000
# set $HCR_EL2=0
# info reg HCR_EL2
# hbreak *0x00000000402005f8

# sudo LD_LIBRARY_PATH=:/home/ubuntu/workspace//qemu/v9.0-nv-rfcv3-exp//deploy//usr/local//lib/:/home/ubuntu/workspace//qemu/v9.0-nv-rfcv3-exp//deploy//usr/local//lib/x86_64-linux-gnu/ gdb -ex "break kvm_arm_set_cpu_features_from_host" -ex "layout src" /home/ubuntu/workspace//qemu/v9.0-nv-rfcv3-exp//deploy//usr/local//bin/qemu-system-aarch64
# run -machine virt,acpi=off,secure=off,accel=kvm,virtualization=on,iommu=smmuv3,gic-version=max  -cpu max  -m 8G  -nodefaults -no-reboot  -kernel /home/ubuntu/workspace//yocto//xen-generic-armv8-xt  -append "dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"        -device guest-loader,addr=0x60000000,kernel=/home/ubuntu/workspace//yocto//linux-dom0,bootargs="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen"            -device guest-loader,addr=0x52000000,initrd=/home/ubuntu/workspace//yocto//rootfs.dom0.cpio.gz      -drive if=none,index=1,id=rootfs_domd,file=/home/ubuntu/workspace//yocto//rootfs.domd.ext4 -device virtio-blk-device,drive=rootfs_domd  -serial mon:stdio  -nographic



# https://www.kernel.org/doc/html/v4.14/dev-tools/gdb-kernel-debugging.html



readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



DUMP_DIR=$(dump_dir)/gdb/${TIMESTAMP}/
mkdir -p ${DUMP_DIR}
COMMAND_FILE=${DUMP_DIR}/command.txt
LOG_FILE=${DUMP_DIR}/log.txt

XEN=$(yocto_dir)/xen-syms
XEN_SRC=$(yocto_dir)/xen/

LINUX_ROOT=/home/ubuntu/workspace/kernel/torvalds/linux/
LINUX=${LINUX_ROOT}/vmlinux
LINUX_SOURCE=${LINUX_ROOT}
LINUX_SCRIPT=${LINUX_ROOT}/scripts/gdb/vmlinux-gdb.py







# objdump -S ${LINUX}

COMMAND="gdb-multiarch"
COMMAND="gdb"
COMMAND+=" ${LINUX}"
COMMAND+=" -ex \"set logging file ${LOG_FILE}\""
COMMAND+=" -ex \"set logging on\""
COMMAND+=" -ex \"add-auto-load-safe-path ${LINUX_SCRIPT}\""
COMMAND+=" -ex \"set directories ${LINUX_SOURCE}\""
COMMAND+=" -ex \"target remote :1234\""
COMMAND+=" -ex \"set disassemble-next-line on\""
COMMAND+=" -ex \"lx-symbols\""
COMMAND+=" -ex \"hb primary_entry\""
COMMAND+=" -ex \"hb __primary_switch\""
COMMAND+=" -ex \"hb __primary_switched\""
COMMAND+=" -ex \"hb finalise_el2\""
# COMMAND+=" -ex \"hb elx_sync\""
# COMMAND+=" -ex \"hb __finalise_el2\""
COMMAND+=" -ex \"hb start_kernel\""

echo ${COMMAND} > ${COMMAND_FILE}

execute "${COMMAND}"







# COMMAND="gdb-multiarch"
# # COMMAND+=" -q"
# # COMMAND+=" --nh"
# # COMMAND+=" -tui"
# # COMMAND+=" -ex \"layout regs\""
# COMMAND+=" -ex \"target remote localhost:1234\""
# COMMAND+=" -ex \"set disassemble-next-line on\""
# # COMMAND+=" -ex \"set architecture auto\""
# # COMMAND+=" -ex \"file ${XEN}\""
# # COMMAND+=" -ex \"set solib-search-path ${LIB_PATH}\""
# # COMMAND+=" -ex \"set directories ${XEN_SRC}\""
# # COMMAND+=" -ex \"add-symbol-file ${SYMBOLS_FILE} ${SYMBOLS_OFFSET}\""
# # COMMAND+=" -ex \"b *${BREAK_ADDR}\""
# # COMMAND+=" -ex \"b ${BREAK_NAME}\""
# # COMMAND+=" -ex \"b ${BREAK_FILE}:${BREAK_LINE}\""
# # COMMAND+=" -ex \"info breakpoints\""
# # COMMAND+=" -ex \"info files\""
# # COMMAND+=" -ex \"show directories\""
# # COMMAND+=" -ex \"show configuration\""
# COMMAND+=" ${XEN}"

# execute "${COMMAND}"
