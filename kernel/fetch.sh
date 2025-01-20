#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

execute " \
   mkdir -p ${KERNEL_DIR}/ \
"

execute " \
   git clone \
      --depth 1 \
      --single-branch \
      --branch ${KERNEL_BRANCH} \
      ${KERNEL_REMOTE} \
      "${KERNEL_SOURCE_DIR}" \
"
