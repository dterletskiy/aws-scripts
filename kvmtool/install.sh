#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

cd ${KVMTOOL_SOURCE_DIR}
make install prefix=${KVMTOOL_DEPLOY_DIR}
# make install DESTDIR=${KVMTOOL_DEPLOY_DIR}
