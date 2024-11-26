#!/usr/bin/env bash

source ./common.sh

mkdir -p ${QEMU_DIR}/
git clone \
	--depth 1 \
	--single-branch \
	--branch master \
	https://gitlab.com/qemu-project/qemu.git \
	"${QEMU_DIR}/source/"
