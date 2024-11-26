#!/usr/bin/env bash

source ./common.sh

cd ${QEMU_DIR}/source/ && make install DESTDIR=${QEMU_DIR}/deploy/
