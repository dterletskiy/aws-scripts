#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh
source ${SCRIPT_DIR}/../_backup/main.sh



define_required_argument "boot" "uboot efi xen kernel" ""
define_optional_argument "ram" "" "8G"
define_optional_argument "kvm" "on off" "off"
define_optional_argument "armve" "on off" "off"
define_optional_argument "smp" "" "4"
define_optional_argument "sme" "on off none" "none"
define_option "debug"



QEMU_DUMP_DIR=$(dump_dir)/qemu/${TIMESTAMP}/
mkdir -p ${QEMU_DUMP_DIR}

COMMAND_FILE=${QEMU_DUMP_DIR}/command.txt

QEMU_DT_DUMP_DIR=${QEMU_DUMP_DIR}/dtb/
mkdir -p ${QEMU_DT_DUMP_DIR}
QEMU_DTB_DUMP=${QEMU_DT_DUMP_DIR}/original.dtb
QEMU_DTS_DUMP=${QEMU_DT_DUMP_DIR}/original.dts
QEMU_DTB_DUMP_RECOMPILE=${QEMU_DT_DUMP_DIR}/recompiled.dtb
QEMU_LOG_DUMP=${QEMU_DUMP_DIR}/log.txt
QEMU_RECORD_DUMP=${QEMU_DUMP_DIR}/record.bin
QEMU_PID=${QEMU_DUMP_DIR}/pid.txt

QEMU_DIR=${QEMU_DEPLOY_DIR}/usr/local/
QEMU_ARM64=${QEMU_DIR}/bin/qemu-system-aarch64


QEMU_EFI_DIR=$(root_dir)/edk2/edk2-stable202411/source/Build/ArmVirtQemu-AARCH64/DEBUG_GCC5/FV/
QEMU_EFI_BIN=${QEMU_EFI_DIR}/QEMU_EFI-pflash.raw
QEMU_EFI_VARS=${QEMU_EFI_DIR}/QEMU_VARS-pflash.raw

DTB=

UBOOT=$(yocto_dir)/u-boot-generic-armv8-xt.bin

XEN=$(yocto_dir)/xen-generic-armv8-xt
XEN_CMDLINE="dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"

DOM0_KERNEL=$(yocto_dir)/linux-dom0
DOM0_KERNEL_CMDLINE="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen nokaslr"
DOM0_INITRD=$(yocto_dir)/rootfs.dom0.cpio.gz

DOMD_ROOTFS=$(yocto_dir)/rootfs.domd.ext4

KERNEL=$(yocto_dir)/linux-dom0
KERNEL_CMDLINE="root=/dev/ram verbose loglevel=7 console=ttyAMA0 nokaslr"
INITRD=$(yocto_dir)/rootfs.dom0.cpio.gz

FULL_IMAGE=$(yocto_dir)/full.img



function build_params_machine( )
{
   Q_MACHINE=" -machine virt"
   Q_MACHINE+=",acpi=off"
   Q_MACHINE+=",secure=off"
   # Q_MACHINE+=",mte=on"
   Q_MACHINE+=",iommu=smmuv3"
   Q_MACHINE+=",gic-version=max"
   # Q_MACHINE+=",its=off"

   if [ "${CMD_ARMVE_DEFINED_VALUES[0]}" == "on" ]; then
      Q_MACHINE+=",virtualization=on"
   elif [ "${CMD_ARMVE_DEFINED_VALUES[0]}" == "off" ]; then
      Q_MACHINE+=",virtualization=off"
   fi

   if [ "${CMD_KVM_DEFINED_VALUES[0]}" == "on" ]; then
      Q_MACHINE+=",accel=kvm"
   fi

   echo "${Q_MACHINE}"
}

function build_params_cpu( )
{
   Q_CPU=" -cpu max"

   if [ "${CMD_SME_DEFINED_VALUES[0]}" == "on" ]; then
      Q_CPU+=",sme=on"
   elif [ "${CMD_SME_DEFINED_VALUES[0]}" == "off" ]; then
      Q_CPU+=",sme=off"
   fi

   if [[ 0 -eq ${#CMD_SMP_DEFINED_VALUES[@]} ]]; then
      Q_CPU+=" -smp ${CMD_SMP_DEFAULT_VALUES[0]}"
   else
      Q_CPU+=" -smp ${CMD_SMP_DEFINED_VALUES[0]}"
   fi

   echo "${Q_CPU}"
}

function build_params_boot( )
{
   Q_BOOT=""

   local _BOOT_=${CMD_BOOT_DEFINED_VALUES[0]}
   case ${_BOOT_} in
      uboot)
         Q_BIOS=" -bios ${UBOOT}"

         Q_DRIVE_FULL=" -drive if=none,index=1,id=full,file=${FULL_IMAGE}"
         Q_DRIVE_FULL+=" -device virtio-blk-device,drive=full"

         Q_BOOT+=" ${Q_BIOS}"
         Q_BOOT+=" ${Q_DRIVE_FULL}"
      ;;
      efi)
         Q_EFI_BIN=" -drive if=pflash,format=raw,readonly=on,file=${QEMU_EFI_BIN},size=64M"
         Q_EFI_VARS=" -drive if=pflash,format=raw,file=${QEMU_EFI_VARS},size=64M"

         Q_DRIVE_FULL=" -drive if=none,index=1,id=full,file=${FULL_IMAGE}"
         Q_DRIVE_FULL+=" -device virtio-blk-device,drive=full"

         Q_BOOT+=" ${Q_EFI_BIN}"
         Q_BOOT+=" ${Q_EFI_VARS}"
         Q_BOOT+=" ${Q_DRIVE_FULL}"
      ;;
      xen)
         Q_KERNEL=" -kernel ${XEN}"
         Q_APPEND=" -append \"${XEN_CMDLINE}\""
         Q_INITRD=" -initrd ${DOM0_INITRD}"

         Q_GUEST_LOADER_DOM0_KERNEL=" \
            -device guest-loader,addr=0x60000000,kernel=${DOM0_KERNEL},bootargs=\"${DOM0_KERNEL_CMDLINE}\" \
         "
         Q_GUEST_LOADER_DOM0_INITRD=" \
            -device guest-loader,addr=0x52000000,initrd=${DOM0_INITRD} \
         "

         Q_DRIVE_DOMD_ROOTFS=" -drive if=none,index=1,id=rootfs_domd,file=${DOMD_ROOTFS}"
         Q_DRIVE_DOMD_ROOTFS+=" -device virtio-blk-device,drive=rootfs_domd"

         Q_BOOT+=" ${Q_KERNEL}"
         Q_BOOT+=" ${Q_APPEND}"
         Q_BOOT+=" ${Q_GUEST_LOADER_DOM0_KERNEL}"
         Q_BOOT+=" ${Q_GUEST_LOADER_DOM0_INITRD}"
         Q_BOOT+=" ${Q_DRIVE_DOMD_ROOTFS}"
      ;;
      kernel)
         Q_KERNEL=" -kernel ${KERNEL}"
         Q_APPEND=" -append \"${KERNEL_CMDLINE}\""
         Q_INITRD=" -initrd ${INITRD}"

         Q_BOOT+=" ${Q_KERNEL}"
         Q_BOOT+=" ${Q_APPEND}"
         Q_BOOT+=" ${Q_INITRD}"
      ;;
      *)
         exit 1
      ;;
   esac

   echo "${Q_BOOT}"
}

function build_params_common( )
{
   Q_COMMON=""
   Q_COMMON+=" -nodefaults"
   Q_COMMON+=" -no-reboot"

   Q_SERIAL=" -serial mon:stdio"

   Q_GRAPHIC=" -nographic"

   Q_LOGGING=""
   Q_LOGGING+=" -D ${QEMU_LOG_DUMP}"
   Q_LOGGING+=" -d guest_errors"
   Q_LOGGING+=",cpu"
   Q_LOGGING+=",cpu_reset"
   Q_LOGGING+=",out_asm"
   Q_LOGGING+=",in_asm"
   Q_LOGGING+=",int"
   Q_LOGGING+=" -pidfile ${QEMU_PID_DUMP}"

   Q_RECORD=" -icount shift=auto,rr=record,rrfile=${QEMU_RECORD_DUMP}"

   Q_MONITOR+=" -monitor tcp:127.0.0.1:4444,server,nowait"



   COMMAND=" "
   COMMAND+=" ${Q_COMMON}"
   COMMAND+=" ${Q_SERIAL}"
   COMMAND+=" ${Q_GRAPHIC}"
   # COMMAND+=" ${Q_LOGGING}"
   # COMMAND+=" ${Q_RECORD}"
   # COMMAND+=" ${Q_MONITOR}"

   echo "${COMMAND}"
}



function main( )
{
   parse_arguments "$@"


   COMMAND="sudo LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${QEMU_ARM64}"
   COMMAND="LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${QEMU_ARM64}"
   COMMAND+=$( build_params_machine )
   COMMAND+=$( build_params_cpu )
   COMMAND+=$( build_params_boot )
   COMMAND+=$( build_params_common )

   execute "${COMMAND}"
   print_ok "RESULT: ${?}"
}

main "$@"
