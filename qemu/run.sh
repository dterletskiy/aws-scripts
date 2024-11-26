#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/"
LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/x86_64-linux-gnu/"
COMMAND="export LD_LIBRARY_PATH"
eval ${COMMAND}

sudo LD_LIBRARY_PATH=${LD_LIBRARY_PATH} \
${QEMU_DIR}/deploy/usr/local/bin/qemu-system-aarch64 \
   -machine type=virt,accel=kvm,virtualization=on \
   -cpu cortex-a57 \
   -enable-kvm \
   -smp 4 \
   -m 8G \
   -d guest_errors \
   -nodefaults \
   -no-reboot \
   -nographic \
   -kernel ${YOCTO_DIR}/xen-generic-armv8-xt \
   -append "dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart" \
   -serial mon:stdio
