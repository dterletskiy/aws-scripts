#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

# cd ${KERNEL_SOURCE_DIR}

execute " \
   make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} V=1 -j96 \
"
