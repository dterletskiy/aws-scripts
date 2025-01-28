#!/usr/bin/env bash

# https://www.kernel.org/doc/html/v4.14/dev-tools/gdb-kernel-debugging.html
# https://www.kernel.org/doc/html/latest/dev-tools/gdb-kernel-debugging.html



readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



DUMP_DIR=$(dump_dir)/gdb/${TIMESTAMP}/
mkdir -p ${DUMP_DIR}
COMMAND_FILE=${DUMP_DIR}/command.txt
LOG_FILE=${DUMP_DIR}/log.txt

LINUX_ROOT=/home/ubuntu/workspace/kernel/torvalds/linux/
LINUX=${LINUX_ROOT}/vmlinux
LINUX_SOURCE=${LINUX_ROOT}
LINUX_SCRIPT=${LINUX_ROOT}/scripts/gdb/vmlinux-gdb.py

SBP_NAMED=(
   # "FUNCTION_NAME"
)

HBP_NAMED=(
   # "FUNCTION_NAME"

   primary_entry
   __primary_switch
   __primary_switched
   finalise_el2
   # elx_sync
   # __finalise_el2

   start_kernel
   # boot_cpu_init
   # page_address_init
   # pr_notice
   # early_security_init
   # setup_arch
   # setup_boot_config
   # setup_command_line
   # setup_nr_cpu_ids
   # setup_per_cpu_areas
   # smp_prepare_boot_cpu
   # boot_cpu_hotplug_init
   # early_trace_init
   # init_timers
   # srcu_init
   # hrtimers_init
   # softirq_init
   # timekeeping_init
   # time_init
)

SBP_ADDR=(
   # "0xABCDEF10"
)

HBP_ADDR=(
   # "0xABCDEF10"
)

SBP_CODE=(
   # "FILE:LINE"
   # "init/main.c:1008"
)

HBP_CODE=(
   # "FILE:LINE"
)







COMMAND="objdump -S ${LINUX} > ${DUMP_DIR}/$(basename ${LINUX}).objdump"
execute "${COMMAND}"

COMMAND="gdb-multiarch"
COMMAND="gdb"
COMMAND+=" ${LINUX}"
# # COMMAND+=" -q"
# # COMMAND+=" --nh"
# # COMMAND+=" -tui"
# # COMMAND+=" -ex \"layout regs\""
COMMAND+=" -ex \"set logging file ${LOG_FILE}\""
COMMAND+=" -ex \"set logging on\""
COMMAND+=" -ex \"add-auto-load-safe-path ${LINUX_SCRIPT}\""
COMMAND+=" -ex \"set directories ${LINUX_SOURCE}\""
COMMAND+=" -ex \"target remote :1234\""
COMMAND+=" -ex \"set disassemble-next-line on\""
COMMAND+=" -ex \"lx-symbols\""
for BP in "${SBP_NAMED[@]}"; do
   COMMAND+=" -ex \"b ${BP}\""
done
for BP in "${HBP_NAMED[@]}"; do
   COMMAND+=" -ex \"hb ${BP}\""
done
for BP in "${SBP_ADDR[@]}"; do
   COMMAND+=" -ex \"b *${BP}\""
done
for BP in "${HBP_ADDR[@]}"; do
   COMMAND+=" -ex \"hb *${BP}\""
done
for BP in "${SBP_CODE[@]}"; do
   COMMAND+=" -ex \"b ${BP[0]}:${BP[1]}\""
done
for BP in "${HBP_CODE[@]}"; do
   COMMAND+=" -ex \"hb ${BP[0]}:${BP[1]}\""
done

echo ${COMMAND} > ${COMMAND_FILE}

execute "${COMMAND}"
