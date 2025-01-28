#!/usr/bin/env bash

readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR}/common.sh
source ${SCRIPT_DIR}/../_backup/main.sh

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')



clear



# readonly CMD_ACTION_NAME="action"
# readonly CMD_ACTION_TYPE=${PARAMETER_TYPE_ARGUMENT}
# readonly CMD_ACTION_REQUIRED=${PARAMETER_REQUIRED}
# declare -a CMD_ACTION_ALLOWED_VALUES=( "enable" "disable" "on" "off" )
# declare -a CMD_ACTION_VALUES=( )

# readonly CMD_MACHINE_NAME="machine"
# readonly CMD_MACHINE_TYPE=${PARAMETER_TYPE_ARGUMENT}
# readonly CMD_MACHINE_REQUIRED=${PARAMETER_REQUIRED}
# declare -a CMD_MACHINE_ALLOWED_VALUES=( "kvm" "nested" )
# declare -a CMD_MACHINE_VALUES=( )

# readonly CMD_DEBUG_NAME="debug"
# readonly CMD_DEBUG_TYPE=${PARAMETER_TYPE_OPTION}
# CMD_DEBUG_DEFINED=${OPTION_NOT_DEFINED}

# declare -a CMD_PARAMETERS=( ACTION MODE DEBUG )

# function main( )
# {
#    parse_arguments "$@"
# }

# main "$@"



# declare -a ALLOWED_VALUES=( "enable" "disable" "on" "off" )
# declare -a DEFAULT_VALUES=( "enable" "disable" "on" "off" )
# define_parameter "action" ${PARAMETER_TYPE_ARGUMENT} ${PARAMETER_REQUIRED} ALLOWED_VALUES DEFAULT_VALUES

define_parameter "machine" ${PARAMETER_TYPE_ARGUMENT} ${PARAMETER_REQUIRED} "armve kvm" ""
define_parameter "cpu" ${PARAMETER_TYPE_ARGUMENT} ${PARAMETER_REQUIRED} "armve kvm" ""
define_parameter "debug" ${PARAMETER_TYPE_OPTION}

function main( )
{
   parse_arguments "$@"
}

main "$@"
