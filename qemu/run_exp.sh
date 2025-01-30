#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh
source ${SCRIPT_DIR}/../_backup/main.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



define_required_argument "boot" "uboot efi xen kernel" ""
define_optional_argument "ram" "" "8G"
define_optional_argument "kvm" "on off" "off"
define_optional_argument "armve" "on off" "off"
define_optional_argument "smp"
define_optional_argument "sme" "on off none" "none"
define_option "debug"



function build_params_machine( )
{
   Q_MACHINE="-machine virt"
   Q_MACHINE+=",acpi=off"
   Q_MACHINE+=",secure=off"
   # Q_MACHINE+=",mte=on"
   Q_MACHINE+=",iommu=smmuv3"
   Q_MACHINE+=",gic-version=max"
   # Q_MACHINE+=",its=off"

   if [ "${CMD_ARMVE_VALUES[0]}" == "on" ]; then
      Q_MACHINE+=",virtualization=on"
   elif [ "${CMD_ARMVE_VALUES[0]}" == "off" ]; then
      Q_MACHINE+=",virtualization=off"
   fi

   if [ "${CMD_KVM_VALUES[0]}" == "on" ]; then
      Q_MACHINE+=",accel=kvm"
   fi

   echo "${Q_MACHINE}"
}

function build_params_cpu( )
{
   Q_CPU=" -cpu max"
   Q_CPU+=",smp ${CMD_SMP_VALUES[0]}"

   if [ "${CMD_SME_VALUES[0]}" == "on" ]; then
      Q_MACHINE+=",sme=on"
   elif [ "${CMD_SME_VALUES[0]}" == "off" ]; then
      Q_MACHINE+=",sme=off"
   fi

   echo "${Q_CPU}"
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
   COMMAND+=$( build_params_machine )
   COMMAND+=$( build_params_cpu )

   print_ok "${COMMAND}"
}

main "$@"
