#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



QEMU_DUMP_DIR=${DUMP_DIR}/qemu/${TIMESTAMP}/
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

DTB=/home/ubuntu/workspace/dump/kvmtool/2024.12.19_10.01.39/dtb/original.dtb

UBOOT=${YOCTO_DIR}/u-boot-generic-armv8-xt.bin

XEN=${YOCTO_DIR}/xen-generic-armv8-xt
XEN_CMD_LINE="dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"

DOM0_KERNEL=${YOCTO_DIR}/linux-dom0
DOM0_KERNEL_CMD_LINE="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen"
DOM0_INITRD=${YOCTO_DIR}/rootfs.dom0.cpio.gz

DOMD_ROOTFS=${YOCTO_DIR}/rootfs.domd.ext4
FULL_IMAGE=${YOCTO_DIR}/full.img



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
   # Q_MACHINE+=" -enable-kvm

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

   Q_MEMORY=" -m 8G"

   Q_COMMON=""
   Q_COMMON+=" -nodefaults"
   Q_COMMON+=" -no-reboot"

   Q_BIOS=" -bios ${UBOOT}"

   Q_DTB=" -dtb ${DTB}"

   Q_SERIAL=" -serial mon:stdio"

   Q_GRAPHIC=" -nographic"

   Q_DRIVE_FULL=" -drive if=none,index=1,id=full,file=${FULL_IMAGE}"
   Q_DRIVE_FULL+=" -device virtio-blk-device,drive=full"


   COMMAND="${QEMU_ARM64}"
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_MEMORY}"
   COMMAND+=" ${Q_COMMON}"
   COMMAND+=" ${Q_BIOS}"
   COMMAND+=" ${Q_DTB}"
   COMMAND+=" ${Q_SERIAL}"
   COMMAND+=" ${Q_GRAPHIC}"
   COMMAND+=" ${Q_DRIVE_FULL}"
   # COMMAND+=" -device loader,file=${XEN},force-raw=on,addr=0x50000000"
   # COMMAND+=" -device loader,file=${DOM0_KERNEL},addr=0x60000000"
   # COMMAND+=" -device loader,file=${DOM0_INITRD},addr=0x52000000"

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
   # Q_MACHINE+=" -enable-kvm

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

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
   # Q_LOGGING+=" -pidfile ${QEMU_PID_DUMP}"

   Q_RECORD=" -icount shift=auto,rr=record,rrfile=${QEMU_RECORD_DUMP}"

   Q_MONITOR+=" -monitor tcp:127.0.0.1:4444,server,nowait"

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
   # COMMAND+=" ${Q_LOGGING}"
   # COMMAND+=" ${Q_RECORD}"
   # COMMAND+=" ${Q_MONITOR}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_APPEND}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_KERNEL}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_INITRD}"
   COMMAND+=" ${Q_DRIVE_DOMD_ROOTFS}"
   COMMAND+=" ${Q_SERIAL}"
   COMMAND+=" ${Q_GRAPHIC}"

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
   # Q_MACHINE+=" -enable-kvm

   Q_CPU=" -cpu max"
   Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

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
   # Q_LOGGING+=" -pidfile ${QEMU_PID_DUMP}"

   Q_RECORD=" -icount shift=auto,rr=record,rrfile=${QEMU_RECORD_DUMP}"

   Q_MONITOR+=" -monitor tcp:127.0.0.1:4444,server,nowait"

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
   # COMMAND+=" ${Q_LOGGING}"
   # COMMAND+=" ${Q_RECORD}"
   # COMMAND+=" ${Q_MONITOR}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_APPEND}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_KERNEL}"
   COMMAND+=" ${Q_GUEST_LOADER_DOM0_INITRD}"
   COMMAND+=" ${Q_DRIVE_DOMD_ROOTFS}"
   COMMAND+=" ${Q_SERIAL}"
   COMMAND+=" ${Q_GRAPHIC}"

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
   # Q_MACHINE+=" -enable-kvm

   Q_CPU=" -cpu max"
   # Q_CPU+=",sme=off"
   # Q_CPU+=" -smp 4"

   Q_MEMORY=" -m 8G"

   Q_COMMON=""
   Q_COMMON+=" -nodefaults"
   Q_COMMON+=" -no-reboot"

   Q_KERNEL=" -kernel ${DOM0_KERNEL}"
   Q_APPEND=" -append \"${DOM0_KERNEL_CMD_LINE}\""
   Q_INITRD=" -initrd ${DOM0_INITRD}"

   Q_SERIAL=" -serial mon:stdio"

   Q_GRAPHIC=" -nographic"

   COMMAND="${QEMU_ARM64}"
   COMMAND+=" ${Q_MACHINE}"
   COMMAND+=" ${Q_CPU}"
   COMMAND+=" ${Q_MEMORY}"
   COMMAND+=" ${Q_COMMON}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_KERNEL}"
   COMMAND+=" ${Q_INITRD}"
   COMMAND+=" ${Q_SERIAL}"
   COMMAND+=" ${Q_GRAPHIC}"

   echo "${COMMAND}"
}



LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/"
LD_LIBRARY_PATH+=":${QEMU_DIR}/lib/x86_64-linux-gnu/"
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
      ALLOWED_MODES=( "kvm" "nv" "nv_kvm" "kvm_nv" "uboot" )
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

   COMMAND="sudo LD_LIBRARY_PATH=${LD_LIBRARY_PATH} "

   case ${CMD_MODE} in
      kvm)
         COMMAND+=$( build_params_kvm )
      ;;
      nv)
         COMMAND+=$( build_params_nv )
      ;;
      kvm_nv|nv_kvm)
         COMMAND+=$( build_params_nv_kvm )
      ;;
      uboot)
         COMMAND+=$( build_params )
      ;;
      *)
         echo "undefined CMD_MODE: '${CMD_MODE}'"
         exit 1
      ;;
   esac

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
