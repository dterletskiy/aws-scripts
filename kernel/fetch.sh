#!/usr/bin/env bash

source ./common.sh

mkdir -p ${KERNEL_DIR}/
git clone \
   --depth 1 \
   --single-branch \
   --branch ${KERNEL_BRANCH} \
   ${KERNEL_REMOTE} \
   "${KERNEL_DIR}/source/"
