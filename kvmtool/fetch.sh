#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

mkdir -p ${KVMTOOL_DIR}/
git clone \
   --depth 1 \
   --single-branch \
   --branch ${KVMTOOL_BRANCH} \
   ${KVMTOOL_REMOTE} \
   ${KVMTOOL_SOURCE_DIR}
