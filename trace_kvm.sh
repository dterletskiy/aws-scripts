#!/usr/bin/env bash

sudo -i
echo 1 > /sys/kernel/debug/tracing/events/kvm/enable
cat /sys/kernel/debug/tracing/trace_pipe
