#!/usr/bin/env bash

source ./common.sh

cd ${KERNEL_DIR}/source/

make V=1 -j48
