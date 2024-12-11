#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



XEN=${YOCTO_DIR}/xen-generic-armv8-xt

COMMAND="gdb-multiarch"
COMMAND+=" -q"
COMMAND+=" --nh"
COMMAND+=" -tui"
COMMAND+=" -ex \"target remote localhost:1234\""
COMMAND+=" -ex \"layout regs\""
COMMAND+=" -ex \"set disassemble-next-line on\""
COMMAND+=" -ex \"show configuration\""
COMMAND+=" -ex \"file ${XEN}\""
COMMAND+=" -ex \"set architecture auto\""

execute "${COMMAND}"
