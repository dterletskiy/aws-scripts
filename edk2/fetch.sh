#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

mkdir -p ${EDK2_DIR}/
git clone \
   --depth 1 \
   --single-branch \
   --branch ${EDK2_BRANCH} \
   ${EDK2_REMOTE} \
   ${EDK2_SOURCE_DIR}
