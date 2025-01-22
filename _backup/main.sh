#!/usr/bin/env bash



readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh



readonly OPTION_DELIMITER=","

readonly PARAMETER_REQUIRED=0xFFFA
readonly PARAMETER_OPTIONAL=0xAAAF

readonly PARAMETER_TYPE_ARGUMENT=0xFFFB
readonly PARAMETER_TYPE_OPTIONAL=0xBBBF



readonly CMD_ACTION_NAME="action"
readonly CMD_ACTION_REQUIRED=${PARAMETER_REQUIRED}
readonly CMD_ACTION_TYPE=${PARAMETER_TYPE_ARGUMENT}
declare -a CMD_ACTION_ALLOWED_VALUES=( "enable" "disable" "on" "off" )
declare -a CMD_ACTION_VALUES=( )
function validate_cmd_action( )
{
   validate_parameter ${CMD_ACTION_NAME} CMD_ACTION_VALUES CMD_ACTION_ALLOWED_VALUES ${CMD_ACTION_REQUIRED}
}



function split_string_add_to_array( )
{
   local LOCAL_STRING=${1}
   local LOCAL_DELIMITER=${2}
   declare -n LOCAL_ARRAY=${3}

   IFS="${LOCAL_DELIMITER}" read -r -a __ARRAY__ <<< "${LOCAL_STRING}"
   LOCAL_ARRAY+=("${__ARRAY__[@]}")
}

function validate_parameter( )
{
   local LOCAL_PARAMETER_NAME=${1}
   declare -n LOCAL_PARAMETER_VALUES=${2}
   declare -n LOCAL_PARAMETER_VALUES_ALLOWED=${3}
   local LOCAL_PARAMETER_CRITICAL=${4}

   if [ -z ${CMD_ACTION_VALUES+x} ]; then
      print_error "'${LOCAL_PARAMETER_NAME}' is not defined"
      if [[ ${PARAMETER_REQUIRED} -eq ${LOCAL_PARAMETER_CRITICAL} ]]; then
         exit 1
      fi
   elif [ -z ${CMD_ACTION_VALUES} ]; then
      print_error "'${LOCAL_PARAMETER_NAME}' is defined but empty"
      exit 1
   elif [[ 0 -eq ${#CMD_ACTION_VALUES[@]} ]]; then
      print_error "'${LOCAL_PARAMETER_NAME}' is defined but empty"
      exit 1
   fi

   for ITEM in "${LOCAL_PARAMETER_VALUES[@]}"; do
      print_info ${ITEM}

      if [[ ! "${LOCAL_PARAMETER_VALUES_ALLOWED[@]}" =~ "${ITEM}" ]]; then
         print_error "'${LOCAL_PARAMETER_NAME}' is defined but invalid"
         exit 1
      else
         print_ok "'${LOCAL_PARAMETER_NAME}' is defined and valid"
      fi
   done
}

function validate_parameters( )
{
   validate_cmd_action


   # if [ -z ${CMD_DEBUG+x} ]; then
   #    echo "'--debug' is not defined"
   #    CMD_DEBUG=0
   # else
   #    echo "'--debug' is defined"
   #    CMD_DEBUG=1
   # fi
}

function parse_arguments( )
{
   echo "Parsing arguments..."

   for option in "$@"; do
      echo "Processing option '${option}'"
      case ${option} in
         --action=*)
            local __TEMP__="${option#*=}"
            if [ -z ${__TEMP__} ]; then
               print_error "'action' is defined but empty"
               exit 1
            fi
            split_string_add_to_array ${__TEMP__} ${OPTION_DELIMITER} CMD_ACTION_VALUES
         ;;
         --debug)
            CMD_DEBUG=
            echo "CMD_DEBUG: defined"
         ;;
         *)
            echo "undefined option: '${option}'"
            exit 1
         ;;
      esac
   done

   validate_parameters
}

function main( )
{
   parse_arguments "$@"

   case ${CMD_ACTION_VALUES} in
      enable|on)
         cpu_on_off 1 CPUS
      ;;
      disable|off)
         cpu_on_off 0 CPUS
      ;;
      watch)
         cpu_watch ${CMD_MEASURE_SECONDS} CPUS
      ;;
      *)
         echo "undefined CMD_ACTION_VALUES: '${CMD_ACTION_VALUES}'"
         exit 1
      ;;
   esac
}



# main "$@"

parse_arguments "$@"

