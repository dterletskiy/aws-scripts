#!/usr/bin/env bash

source ./common.sh

mkdir -p ${QEMU_DIR}/
git clone \
   --depth 1 \
   --single-branch \
   --branch ${QEMU_BRANCH} \
   ${QEMU_REMOTE} \
   "${QEMU_DIR}/source/"
