#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh



clear



PERF_TOOL="/home/ubuntu/workspace/kernel/source/tools/perf/perf"

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
QEMU_EFI_ARM64=${QEMU_EFI_DIR}/QEMU_EFI-pflash.raw
QEMU_VARS_ARM64=${QEMU_EFI_DIR}/QEMU_VARS-pflash.raw

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

# FULL_IMAGE=$(yocto_dir)/full.img
FULL_IMAGE=$(yocto_dir)/full_bench_efi.img



function build_params_efi( )
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

   Q_KVM+=" -enable-kvm"

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

   Q_DRIVE_FULL=" -drive if=none,index=1,id=full,file=${FULL_IMAGE}"
   Q_DRIVE_FULL+=" -device virtio-blk-device,drive=full"


   COMMAND=""
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_DRIVE_FULL}"
   COMMAND+=" -drive if=pflash,format=raw,readonly=on,file=${QEMU_EFI_ARM64},size=64M"
   COMMAND+=" -drive if=pflash,format=raw,file=${QEMU_VARS_ARM64},size=64M"

   echo "${COMMAND}"
}

function build_params_uboot( )
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

   Q_KVM+=" -enable-kvm"

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

   Q_BIOS=" -bios ${UBOOT}"

   Q_DRIVE_FULL=" -drive if=none,index=1,id=full,file=${FULL_IMAGE}"
   Q_DRIVE_FULL+=" -device virtio-blk-device,drive=full"


   COMMAND=""
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_BIOS}"
   COMMAND+=" ${Q_DRIVE_FULL}"

   echo "${COMMAND}"
}

function build_params_nv_kvm( )
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

   Q_KVM+=" -enable-kvm"

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

   Q_KERNEL=" -kernel ${XEN}"
   Q_APPEND=" -append \"${XEN_CMDLINE}\""
   Q_INITRD=" -initrd ${DOM0_INITRD}"

   Q_GUEST_LOADER_DOM0_KERNEL=" \
      -device guest-loader,addr=0x60000000,kernel=${DOM0_KERNEL},bootargs=\"${DOM0_KERNEL_CMDLINE}\" \
   "
   Q_GUEST_LOADER_DOM0_INITRD=" \
      -device guest-loader,addr=0x52000000,initrd=${DOM0_INITRD} \
   "

   Q_DRIVE_DOMD_ROOTFS=""

   # Q_DRIVE_DOMD_ROOTFS+=" -drive if=none,index=1,id=rootfs_domd,file=${DOMD_ROOTFS}"
   # Q_DRIVE_DOMD_ROOTFS+=" -device virtio-blk-device,drive=rootfs_domd"

   Q_DRIVE_DOMD_ROOTFS+=" -drive if=none,index=1,id=rootfs_domd,file=${DOMD_ROOTFS}"
   Q_DRIVE_DOMD_ROOTFS+=" -device virtio-blk-device,drive=rootfs_domd,iommu_platform=true"

   Q_DRIVE_DOMD_ROOTFS+=" -drive if=none,index=2,id=rootfs_domd_pci,file=${DOMD_ROOTFS}"
   Q_DRIVE_DOMD_ROOTFS+=" -device virtio-blk-pci,drive=rootfs_domd_pci,iommu_platform=true,disable-legacy=on"

   # Q_DRIVE_DOMD_ROOTFS+=" -device virtio-iommu-pci"

   COMMAND=""
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_APPEND}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_KERNEL}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_INITRD}"
   COMMAND+=" ${Q_DRIVE_DOMD_ROOTFS}"

   echo "${COMMAND}"
}

function build_params_nv( )
{
   Q_MACHINE="-machine virt"
   Q_MACHINE+=",acpi=off"
   Q_MACHINE+=",secure=off"
   # Q_MACHINE+=",mte=on"
   # Q_MACHINE+=",accel=kvm"
   Q_MACHINE+=",virtualization=on"
   Q_MACHINE+=",iommu=smmuv3"
   Q_MACHINE+=",gic-version=max"
   # Q_MACHINE+=",its=off"

   Q_KVM+=" -enable-kvm"

   Q_CPU=" -cpu max"
   Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

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

   COMMAND=""
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_APPEND}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_KERNEL}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_INITRD}"
   COMMAND+=" ${Q_DRIVE_DOMD_ROOTFS}"

   echo "${COMMAND}"
}

function build_params_kvm( )
{
   Q_MACHINE="-machine virt"
   Q_MACHINE+=",acpi=off"
   Q_MACHINE+=",secure=off"
   # Q_MACHINE+=",mte=on"
   Q_MACHINE+=",accel=kvm"
   # Q_MACHINE+=",virtualization=on"
   Q_MACHINE+=",iommu=smmuv3"
   Q_MACHINE+=",gic-version=max"
   # Q_MACHINE+=",its=off"

   Q_KVM+=" -enable-kvm"

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

   Q_KERNEL=" -kernel ${KERNEL}"
   Q_APPEND=" -append \"${KERNEL_CMDLINE}\""
   Q_INITRD=" -initrd ${INITRD}"

   COMMAND=""
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_APPEND}"
   COMMAND+=" ${Q_INITRD}"

   echo "${COMMAND}"
}

function build_params_kvm_virt( )
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

   Q_KVM+=" -enable-kvm"

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

   Q_KERNEL=" -kernel ${KERNEL}"
   Q_APPEND=" -append \"${KERNEL_CMDLINE}\""
   Q_INITRD=" -initrd ${INITRD}"

   Q_DRIVE_DOMD_ROOTFS=" -drive if=none,index=1,id=rootfs_domd,file=${DOMD_ROOTFS}"
   Q_DRIVE_DOMD_ROOTFS+=" -device virtio-blk-device,drive=rootfs_domd"

   COMMAND=""
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_APPEND}"
   COMMAND+=" ${Q_INITRD}"
   COMMAND+=" ${Q_DRIVE_DOMD_ROOTFS}"

   echo "${COMMAND}"
}

function build_params_common( )
{
   Q_MEMORY=" -m 8G"

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
   COMMAND+=" ${Q_MEMORY}"
   COMMAND+=" ${Q_COMMON}"
   COMMAND+=" ${Q_SERIAL}"
   COMMAND+=" ${Q_GRAPHIC}"
   # COMMAND+=" ${Q_LOGGING}"
   # COMMAND+=" ${Q_RECORD}"
   # COMMAND+=" ${Q_MONITOR}"

   echo "${COMMAND}"
}



LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/"
LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/x86_64-linux-gnu/"
LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/aarch64-linux-gnu/"
print_info "LD_LIBRARY_PATH = '${LD_LIBRARY_PATH}'"
COMMAND="export LD_LIBRARY_PATH"
execute "${COMMAND}"



function validate_parameters( )
{
   if [ -z ${CMD_MODE+x} ]; then
      echo "'--mode' is not defined"
      exit 1
   elif [ -z ${CMD_MODE} ]; then
      echo "'--mode' is defined but empty"
      exit 1
   else
      ALLOWED_MODES=( "kvm" "kvm_virt" "virt_kvm" "nv" "nv_kvm" "kvm_nv" "uboot" "efi" )
      if [[ ! "${ALLOWED_MODES[@]}" =~ "${CMD_MODE}" ]]; then
         echo "'--mode' is defined but invalid"
         exit 1
      else
         echo "'--mode' is defined and valid"
      fi
   fi

   if [ -z ${CMD_PERF+x} ]; then
      echo "'--perf' is not defined"
      CMD_PERF=0
   else
      echo "'--perf' is defined"
      CMD_PERF=1
   fi

   if [ -z ${CMD_DEBUG+x} ]; then
      echo "'--debug' is not defined"
      CMD_DEBUG=0
   else
      echo "'--debug' is defined"
      CMD_DEBUG=1
   fi
}

function parse_arguments( )
{
   echo "Parsing arguments..."

   for option in "$@"; do
      echo "Processing option '${option}'"
      case ${option} in
         --mode=*)
            if [ -z ${CMD_MODE+x} ]; then
               CMD_MODE="${option#*=}"
               shift # past argument=value
               echo "CMD_MODE: ${CMD_MODE}"
            else
               echo "'--mode' is already set to '${CMD_MODE}'"
               exit 1
            fi
         ;;
         --perf)
            CMD_PERF=
            echo "CMD_PERF: defined"
         ;;
         --debug)
            CMD_DEBUG=
            echo "CMD_DEBUG: defined"
         ;;
         *)
            echo "undefined option: '${option}'"
            exit 1
         ;;
      esac
   done

   validate_parameters
}

function main( )
{
   parse_arguments "$@"

   COMMAND="sudo LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${QEMU_ARM64}"

   case ${CMD_MODE} in
      kvm)
         COMMAND+=$( build_params_kvm )
      ;;
      kvm_virt|virt_kvm)
         COMMAND+=$( build_params_kvm_virt )
      ;;
      nv)
         COMMAND+=$( build_params_nv )
      ;;
      kvm_nv|nv_kvm)
         COMMAND+=$( build_params_nv_kvm )
      ;;
      uboot)
         COMMAND+=$( build_params_uboot )
      ;;
      efi)
         COMMAND+=$( build_params_efi )
      ;;
      *)
         echo "undefined CMD_MODE: '${CMD_MODE}'"
         exit 1
      ;;
   esac

   COMMAND+=$( build_params_common )

   execute "${COMMAND} -machine dumpdtb=${QEMU_DTB_DUMP}"

   decompile_dt ${QEMU_DTB_DUMP} ${QEMU_DTS_DUMP}
   compile_dt ${QEMU_DTS_DUMP} ${QEMU_DTB_DUMP_RECOMPILE}

   if [[ ! "${CMD_PERF}" -eq 0 ]]; then
      PERF_RECORD_FILE="${QEMU_DUMP_DIR}/${CMD_MODE}_perf.record"
      PERF_REPORT_FILE="${QEMU_DUMP_DIR}/${CMD_MODE}_perf.report"
      PERF_ANNOTATE_FILE="${QEMU_DUMP_DIR}/${CMD_MODE}_perf.annotate"
      COMMAND="sudo ${PERF_TOOL} record -g -o ${PERF_RECORD_FILE} ${COMMAND}"
   fi

   if [[ ! "${CMD_DEBUG}" -eq 0 ]]; then
      COMMAND+=" -s -S"
   fi

   echo ${COMMAND} > ${COMMAND_FILE}
   execute "${COMMAND}"

   if [[ ! "${CMD_PERF}" -eq 0 ]]; then
      COMMAND="sudo chmod 644 ${PERF_RECORD_FILE}"
      execute "${COMMAND}"

      COMMAND=" \
            ${PERF_TOOL} report \
            -i ${PERF_RECORD_FILE} \
            > ${PERF_REPORT_FILE} \
         "
      execute "${COMMAND}"

      COMMAND=" \
            ${PERF_TOOL} report \
            --stdio \
            -i ${PERF_RECORD_FILE} \
            > ${PERF_REPORT_FILE}.stdio \
         "
      execute ${COMMAND}

      COMMAND=" \
            ${PERF_TOOL} report \
            --hierarchy \
            -i ${PERF_RECORD_FILE} \
            > ${PERF_REPORT_FILE}.hierarchy \
         "
      execute ${COMMAND}

      COMMAND=" \
            ${PERF_TOOL} report \
            --hierarchy \
            --stdio \
            -i ${PERF_RECORD_FILE} \
            > ${PERF_REPORT_FILE}.hierarchy.stdio \
         "
      execute ${COMMAND}

      COMMAND=" \
            ${PERF_TOOL} annotate \
            -i ${PERF_RECORD_FILE} \
            > ${PERF_ANNOTATE_FILE} \
         "
      # execute ${COMMAND}

      COMMAND=" \
            ${PERF_TOOL} annotate \
            --stdio
            -i ${PERF_RECORD_FILE} \
            > ${PERF_ANNOTATE_FILE}.stdio \
         "
      # execute ${COMMAND}

      COMMAND="head -50 ${PERF_REPORT_FILE}"
      execute ${COMMAND} 
   fi
}



main "$@"
