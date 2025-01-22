#!/usr/bin/env bash

sudo -i bash -c "echo 1 > /sys/kernel/debug/tracing/events/kvm/enable"
sudo -i bash -c "cat /sys/kernel/debug/tracing/trace_pipe"
