#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh



clear



KVMTOOL_DUMP_DIR=$(dump_dir)/kvmtool/${TIMESTAMP}/
mkdir -p ${KVMTOOL_DUMP_DIR}
KVMTOOL_DT_DUMP_DIR=${KVMTOOL_DUMP_DIR}/dtb/
mkdir -p ${KVMTOOL_DT_DUMP_DIR}
KVMTOOL_DTB_DUMP=${KVMTOOL_DT_DUMP_DIR}/original.dtb
KVMTOOL_DTS_DUMP=${KVMTOOL_DT_DUMP_DIR}/original.dts
KVMTOOL_DTB_DUMP_RECOMPILE=${KVMTOOL_DT_DUMP_DIR}/recompiled.dtb

EFI=$(root_dir)/edk2/edk2-stable202411/source/Build/ArmVirtKvmTool-AARCH64/DEBUG_GCC5/FV/KVMTOOL_EFI.fd

UBOOT=$(yocto_dir)/u-boot-generic-armv8-xt.bin

XEN=$(yocto_dir)/xen-generic-armv8-xt
XEN_CMDLINE="dom0_mem=3G,max:3G loglvl=all guest_loglvl=all console=dtuart"

DOM0_KERNEL=$(yocto_dir)/linux-dom0
DOM0_KERNEL_CMDLINE="root=/dev/ram verbose loglevel=7 console=hvc0 earlyprintk=xen"
DOM0_INITRD=$(yocto_dir)/rootfs.dom0.cpio.gz

DOMD_ROOTFS=$(yocto_dir)/rootfs.domd.ext4
FULL_IMG=$(yocto_dir)/full_bench_efi.img



function build_params_kernel( )
{
   local COMMAND=""

   COMMAND+=" -k ${DOM0_KERNEL}"
   COMMAND+=" -p \"${DOM0_KERNEL_CMDLINE}\""
   COMMAND+=" -i ${DOM0_INITRD}"

   echo "${COMMAND}"
}

function build_params_xen( )
{
   local COMMAND=""

   COMMAND+=" -k ${DOM0_KERNEL}"
   COMMAND+=" -p \"${DOM0_KERNEL_CMDLINE}\""
   COMMAND+=" -i ${DOM0_INITRD}"

   COMMAND+=" -x ${XEN}"
   COMMAND+=" -y \"${XEN_CMDLINE}\""

   echo "${COMMAND}"
}

function build_params_efi( )
{
   local COMMAND=""

   COMMAND+=" -f ${EFI}"

   echo "${COMMAND}"
}

function build_params_common( )
{
   local COMMAND=""

   COMMAND+=" -d ${FULL_IMG}"

   COMMAND+=" -m 8G"
   COMMAND+=" -c 1"
   COMMAND+=" --debug"
   COMMAND+=" --e2h0"
   COMMAND+=" --nested"
   COMMAND+=" --dump-dtb ${KVMTOOL_DTB_DUMP}"

   echo "${COMMAND}"
}



function validate_parameters( )
{
   if [ -z ${CMD_MODE+x} ]; then
      echo "'--mode' is not defined"
      exit 1
   elif [ -z ${CMD_MODE} ]; then
      echo "'--mode' is defined but empty"
      exit 1
   else
      ALLOWED_MODES=( "kernel" "xen" "efi" )
      if [[ ! "${ALLOWED_MODES[@]}" =~ "${CMD_MODE}" ]]; then
         echo "'--mode' is defined but invalid"
         exit 1
      else
         echo "'--mode' is defined and valid"
      fi
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

   COMMAND="sudo ${KVMTOOL_SOURCE_DIR}/lkvm run"

   case ${CMD_MODE} in
      kernel)
         COMMAND+=$( build_params_kernel )
      ;;
      xen)
         COMMAND+=$( build_params_xen )
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
   execute ${COMMAND}

   decompile_dt ${KVMTOOL_DTB_DUMP} ${KVMTOOL_DTS_DUMP}
   compile_dt ${KVMTOOL_DTS_DUMP} ${KVMTOOL_DTB_DUMP_RECOMPILE}
}



main "$@"
