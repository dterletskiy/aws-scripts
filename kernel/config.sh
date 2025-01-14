#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

mkdir -p ${KERNEL_BUILD_DIR}
cd ${KERNEL_BUILD_DIR}

cp -v /boot/config-$(uname -r) ${KERNEL_BUILD_DIR}/.config
# make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} localmodconfig
# make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} oldconfig
make O=${KERNEL_BUILD_DIR} -C ${KERNEL_SOURCE_DIR} menuconfig

${KERNEL_SOURCE_DIR}/scripts/config --state SYSTEM_TRUSTED_KEYS
${KERNEL_SOURCE_DIR}/scripts/config --state SYSTEM_REVOCATION_KEYS
${KERNEL_SOURCE_DIR}/scripts/config --state CONFIG_SYSTEM_TRUSTED_KEYS ""
${KERNEL_SOURCE_DIR}/scripts/config --state CONFIG_SYSTEM_REVOCATION_KEYS ""

${KERNEL_SOURCE_DIR}/scripts/config --disable SYSTEM_TRUSTED_KEYS
${KERNEL_SOURCE_DIR}/scripts/config --disable SYSTEM_REVOCATION_KEYS
${KERNEL_SOURCE_DIR}/scripts/config --set-str CONFIG_SYSTEM_TRUSTED_KEYS ""
${KERNEL_SOURCE_DIR}/scripts/config --set-str CONFIG_SYSTEM_REVOCATION_KEYS ""

${KERNEL_SOURCE_DIR}/scripts/config --state SYSTEM_TRUSTED_KEYS
${KERNEL_SOURCE_DIR}/scripts/config --state SYSTEM_REVOCATION_KEYS
${KERNEL_SOURCE_DIR}/scripts/config --state CONFIG_SYSTEM_TRUSTED_KEYS ""
${KERNEL_SOURCE_DIR}/scripts/config --state CONFIG_SYSTEM_REVOCATION_KEYS ""
