#!/usr/bin/env bash

# x/32i 0x0000000040000000
# set $HCR_EL2=0
# info reg HCR_EL2
# hbreak *0x00000000402005f8

# sudo LD_LIBRARY_PATH=:/home/ubuntu/workspace//qemu/v9.0-nv-rfcv3-exp//deploy//usr/local//lib/:/home/ubuntu/workspace//qemu/v9.0-nv-rfcv3-exp//deploy//usr/local//lib/x86_64-linux-gnu/ gdb -ex "break kvm_arm_set_cpu_features_from_host" -ex "layout src" /home/ubuntu/workspace//qemu/v9.0-nv-rfcv3-exp//deploy//usr/local//bin/qemu-system-aarch64
# run -machine virt,acpi=off,secure=off,accel=kvm,virtualization=on,iommu=smmuv3,gic-version=max  -cpu max  -m 8G  -nodefaults -no-reboot  -kernel /home/ubuntu/workspace//yocto//xen-generic-armv8-xt  -append "dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"        -device guest-loader,addr=0x60000000,kernel=/home/ubuntu/workspace//yocto//linux-dom0,bootargs="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen"            -device guest-loader,addr=0x52000000,initrd=/home/ubuntu/workspace//yocto//rootfs.dom0.cpio.gz      -drive if=none,index=1,id=rootfs_domd,file=/home/ubuntu/workspace//yocto//rootfs.domd.ext4 -device virtio-blk-device,drive=rootfs_domd  -serial mon:stdio  -nographic



# gdb /home/ubuntu/workspace/kernel/kvm-arm64/nv-next/build/vmlinux
# (gdb) add-auto-load-safe-path /home/ubuntu/workspace/kernel/kvm-arm64/nv-next/source/scripts/gdb/vmlinux-gdb.py
# (gdb) target remote :1234
# (gdb) set disassemble-next-line on
# (gdb) hb primary_entry
# (gdb) hb start_kernel
# (gdb) c
# (gdb) x/32i 0x0000000040000000
# (gdb) x/32i 0xffff8000820711b0
# gdb /home/ubuntu/workspace/kernel/torvalds/linux/vmlinux \
#    -ex "add-auto-load-safe-path /home/ubuntu/workspace/kernel/torvalds/linux/scripts/gdb/vmlinux-gdb.py" \
#    -ex "set directories /home/ubuntu/workspace/kernel/torvalds/linux/" \
#    -ex "target remote :1234" \
#    -ex "set disassemble-next-line on" \
#    -ex "hb primary_entry" \
#    -ex "hb __primary_switch" \
#    -ex "hb __primary_switched" \
#    -ex "hb start_kernel"



readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



XEN=${YOCTO_DIR}/xen-syms
XEN_SRC=${YOCTO_DIR}/xen/

COMMAND="gdb-multiarch"
# COMMAND+=" -q"
# COMMAND+=" --nh"
# COMMAND+=" -tui"
# COMMAND+=" -ex \"layout regs\""
COMMAND+=" -ex \"target remote localhost:1234\""
COMMAND+=" -ex \"set disassemble-next-line on\""
# COMMAND+=" -ex \"set architecture auto\""
# COMMAND+=" -ex \"file ${XEN}\""
# COMMAND+=" -ex \"set solib-search-path ${LIB_PATH}\""
# COMMAND+=" -ex \"set directories ${XEN_SRC}\""
# COMMAND+=" -ex \"add-symbol-file ${SYMBOLS_FILE} ${SYMBOLS_OFFSET}\""
# COMMAND+=" -ex \"b *${BREAK_ADDR}\""
# COMMAND+=" -ex \"b ${BREAK_NAME}\""
# COMMAND+=" -ex \"b ${BREAK_FILE}:${BREAK_LINE}\""
# COMMAND+=" -ex \"info breakpoints\""
# COMMAND+=" -ex \"info files\""
# COMMAND+=" -ex \"show directories\""
# COMMAND+=" -ex \"show configuration\""
COMMAND+=" ${XEN}"

execute "${COMMAND}"
