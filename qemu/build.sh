#!/usr/bin/env bash

source ./common.sh

cd ${QEMU_DIR}/source/ && make V=1 -j48
