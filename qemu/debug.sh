#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



XEN=${YOCTO_DIR}/xen-syms

COMMAND="gdb-multiarch"
COMMAND+=" -q"
COMMAND+=" --nh"
COMMAND+=" -tui"
COMMAND+=" -ex \"target remote localhost:1234\""
COMMAND+=" -ex \"layout regs\""
COMMAND+=" -ex \"set disassemble-next-line on\""
# COMMAND+=" -ex \"show configuration\""
# COMMAND+=" -ex \"set architecture auto\""
# COMMAND+=" -ex \"file ${XEN}\""
# COMMAND+=" -ex \"set solib-search-path ${LIB_PATH}\""
# COMMAND+=" -ex \"set directories ${SRC_PATH}\""
# COMMAND+=" -ex \"add-symbol-file ${SYMBOLS_FILE} ${SYMBOLS_OFFSET}\""
# COMMAND+=" -ex \"b *${BREAK_ADDR}\""
# COMMAND+=" -ex \"b ${BREAK_NAME}\""
# COMMAND+=" -ex \"b ${BREAK_FILE}:${BREAK_LINE}\""
# COMMAND+=" -ex \"info breakpoints\""
# COMMAND+=" -ex \"info files\""
COMMAND+=" ${XEN}

execute "${COMMAND}"
