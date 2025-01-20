#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



KERNEL=/boot/vmlinuz
INITRD=/boot/initrd.img
CMDLINE="BOOT_IMAGE=/vmlinuz root=PARTUUID=021ed981-cb06-49a6-ade9-707e7abe39ab ro console=tty1 console=ttyS0 nvme_core.io_timeout=4294967295 kvm-arm.mode=nested panic=-1"

sudo kexec -l ${KERNEL} --initrd=${INITRD} --command-line="${CMDLINE}"
sudo kexec -e
