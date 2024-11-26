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



function build_params( )
{
   Q_MACHINE="-machine virt"
   Q_MACHINE+=",acpi=off"
   Q_MACHINE+=",secure=off"
   # Q_MACHINE+=",mte=on"
   Q_MACHINE+=",accel=kvm"
   Q_MACHINE+=",virtualization=on"
   Q_MACHINE+=",iommu=smmuv3"
   Q_MACHINE+=",gic-version=max"
   # Q_MACHINE+=",its=off"

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   Q_CPU+=" -smp 4"

   Q_MEMORY=" -m 8G"

   Q_COMMON=""
   Q_COMMON+=" -nodefaults"
   Q_COMMON+=" -no-reboot"

   Q_LOGGING=""
   Q_LOGGING+=" -D ${QEMU_LOG_DUMP}"
   Q_LOGGING+=" -d guest_errors"
   Q_LOGGING+=",cpu"
   Q_LOGGING+=",cpu_reset"
   Q_LOGGING+=",out_asm"
   Q_LOGGING+=",in_asm"
   Q_LOGGING+=",int"
   # Q_LOGGING+=" -icount shift=auto,rr=record,rrfile=${QEMU_RECORD_DUMP}"
   # Q_LOGGING+=" -pidfile ${QEMU_PID_DUMP}"
   # Q_LOGGING+=" -monitor tcp:127.0.0.1:4444,server,nowait"

   Q_KERNEL=" -kernel ${XEN}"
   Q_APPEND=" -append \"${XEN_CMD_LINE}\""
   Q_INITRD=" -initrd ${DOM0_INITRD}"

   Q_GUEST_LOADER_DOM0_KERNEL=" \
      -device guest-loader,addr=0x60000000,kernel=${DOM0_KERNEL},bootargs=\"${DOM0_KERNEL_CMD_LINE}\" \
   "
   Q_GUEST_LOADER_DOM0_INITRD=" \
      -device guest-loader,addr=0x52000000,initrd=${DOM0_INITRD} \
   "

   Q_SERIAL=" -serial mon:stdio"

   Q_GRAPHIC=" -nographic"

   Q_DRIVE_DOMD_ROOTFS=" -drive if=none,index=1,id=rootfs_domd,file=${DOMD_ROOTFS}"
   Q_DRIVE_DOMD_ROOTFS+=" -device virtio-blk-device,drive=rootfs_domd"

   COMMAND="${QEMU_ARM64}"
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_MEMORY}"
   COMMAND+=" ${Q_COMMON}"
   COMMAND+=" ${Q_LOGGING}"
   # COMMAND+=" -enable-kvm"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_APPEND}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_KERNEL}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_INITRD}"
   COMMAND+=" ${Q_DRIVE_DOMD_ROOTFS}"
   COMMAND+=" ${Q_SERIAL}"
   COMMAND+=" ${Q_GRAPHIC}"

   echo "${COMMAND}"
}

function compile_dt( )
{
   local IN_DTS=${1}
   local OUT_DTB=${2}

   local COMMAND="dtc -I dts -O dtb -o ${OUT_DTB} ${IN_DTS}"
   print_ok ${COMMAND}
   eval "${COMMAND}"
}

function decompile_dt( )
{
   local IN_DTB=${1}
   local OUT_DTS=${2}

   local COMMAND="dtc -I dtb -O dts -o ${OUT_DTS} ${IN_DTB}"
   print_ok ${COMMAND}
   eval "${COMMAND}"
}



LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/"
LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/x86_64-linux-gnu/"
COMMAND="export LD_LIBRARY_PATH"
echo "${COMMAND}"
eval "${COMMAND}"



COMMAND="sudo LD_LIBRARY_PATH=${LD_LIBRARY_PATH} "
COMMAND+=$( build_params )

echo "${COMMAND} -machine dumpdtb=${QEMU_DTB_DUMP}"
eval "${COMMAND} -machine dumpdtb=${QEMU_DTB_DUMP}"

decompile_dt ${QEMU_DTB_DUMP} ${QEMU_DTS_DUMP}
compile_dt ${QEMU_DTS_DUMP} ${QEMU_DTB_DUMP_RECOMPILE}

echo "${COMMAND}"
echo ${COMMAND} > ${COMMAND_FILE}
eval "${COMMAND}"
