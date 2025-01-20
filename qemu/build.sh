#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

execute " \
   cd ${QEMU_BUILD_DIR} \
"

execute " \
   make V=1 -j96 \
"
