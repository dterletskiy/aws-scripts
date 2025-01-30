#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



echo ${DELIMITER}
COMMAND="./stress-ng --cpu 1 --timeout 120s --metrics-brief"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./stress-ng --cpu 4 --timeout 120s --metrics-brief"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./stress-ng --matrix 1 --timeout 120s --metrics-brief"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./stress-ng --matrix 4 --timeout 120s --metrics-brief"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./stress-ng --memcpy 1 --timeout 120s --metrics-brief"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./stress-ng --memcpy 4 --timeout 120s --metrics-brief"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./sysbench --test=memory --time=60 --threads=1 run"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./sysbench --test=memory --time=60 --threads=4 run"
echo "${COMMAND}"
eval "${COMMAND}"

echo ${DELIMITER}
COMMAND="./sysbench --test=cpu --cpu-max-prime=20000 run"
echo "${COMMAND}"
eval "${COMMAND}"
