#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

execute " \
   mkdir -p ${QEMU_DIR}/ \
"

execute " \
   git clone \
      --depth 1 \
      --single-branch \
      --branch ${QEMU_BRANCH} \
      ${QEMU_REMOTE} \
      ${QEMU_SOURCE_DIR} \
"
