#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



KVM_DUMP_DIR=$(dump_dir)/kvm/${TIMESTAMP}/
mkdir -p ${KVM_DUMP_DIR}

sudo -i bash -c "echo 1 > /sys/kernel/debug/tracing/events/kvm/enable"
sudo cat /sys/kernel/debug/tracing/trace_pipe | tee ${KVM_DUMP_DIR}/trace_pipe.log
