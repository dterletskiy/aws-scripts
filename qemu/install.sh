#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

cd ${QEMU_SOURCE_DIR}
make install DESTDIR=${QEMU_DEPLOY_DIR}
