#!/usr/bin/env bash

# Usage:
#  Parameters:
#     --cation: action to be performed
#           - 'on' of 'enable' - enable cpu cores mentioned in '--cpus' parameter.
#           - 'off' of 'disable' - enable cpu cores mentioned in '--cpus' parameter.
#           - 'watch' - calculate core load in percentage during the time mentioned in the '--ms' paraneter
#                       in second for the cores mentioned in '--cpus' parameter.
#     --cpus: list of the cpus/cores separeted by ',' what will be effected by the action.
#              It is also possible to set the cores range using '-'.
#     --ms: time measurement in the second for actions: 'watch'
# 
# Examples:
#     cpus.sh --action=watch --cpus=0-7 --ms=10
#     sudo cpus.sh --action=off --cpus=1-3,6,7
#     sudo cpus.sh --action=on --cpus=1-3



declare -a CPUS

# This function parses "grep 'cpu' /proc/stat" output and build dictionaty
# where keys are the cores numbers mentioned in the firtst parameter and
# values are the vectors of values for this core. 
function __build_cpu_stat__( )
{
   local LOCAL_GREP_OUTPUT=${1}
   declare -n LOCAL_CPU_DATA=${2}

   # Processing each string
   while IFS= read -r line; do
      # Splitting string to array
      read -a items <<< "$line"

      # Test if string starts from 'cpu'
      if [[ ${items[0]} =~ ^cpu[0-9]+$ ]]; then
         # Gettinf core number
         CORE=${items[0]#cpu}

         # Removing first item ('cpuX') and storing array
         CORE_DATA=("${items[@]:1}")

         # Storing array to the didictionary
         LOCAL_CPU_DATA[${CORE}]=${CORE_DATA[*]}
      fi
   done <<< "${LOCAL_GREP_OUTPUT}"
}

function __calc_core_load__( )
{
   declare -n LOCAL_START_CORE_DATA=${1}
   declare -n LOCAL_STOP_CORE_DATA=${2}

   START_CORE_LOAD_DATA=$(( LOCAL_START_CORE_DATA[0] + LOCAL_START_CORE_DATA[1] + LOCAL_START_CORE_DATA[2] ))
   START_CORE_ALL_DATA=$(( START_CORE_LOAD_DATA + LOCAL_START_CORE_DATA[3] ))

   STOP_CORE_LOAD_DATA=$(( LOCAL_STOP_CORE_DATA[0] + LOCAL_STOP_CORE_DATA[1] + LOCAL_STOP_CORE_DATA[2] ))
   STOP_CORE_ALL_DATA=$(( STOP_CORE_LOAD_DATA + LOCAL_STOP_CORE_DATA[3] ))

   CORE_LOAD_DELTA=$(( STOP_CORE_LOAD_DATA - START_CORE_LOAD_DATA ))
   CORE_ALL_DELTA=$(( STOP_CORE_ALL_DATA - START_CORE_ALL_DATA ))

   CORE_LOAD=$(( CORE_LOAD_DELTA * 100 / CORE_ALL_DELTA ))
   echo ${CORE_LOAD}
}

function cpu_watch( )
{
   local LOCAL_MEASURE_SECONDS=${1}
   declare -n LOCAL_CPUS=${2}

   local START_TIME=$(date +%s.%N | cut -b1-14)
   local START_METRIX=$(grep 'cpu' /proc/stat)
   sleep ${LOCAL_MEASURE_SECONDS}
   local STOP_METRIX=$(grep 'cpu' /proc/stat)
   local STOP_TIME=$(date +%s.%N | cut -b1-14)

   declare -A START_CPU_DATA
   __build_cpu_stat__ "${START_METRIX}" START_CPU_DATA
   declare -A STOP_CPU_DATA
   __build_cpu_stat__ "${STOP_METRIX}" STOP_CPU_DATA

   for CORE in ${LOCAL_CPUS[@]}; do
      read -a START_CORE_DATA <<< "${START_CPU_DATA[${CORE}]}"
      read -a STOP_CORE_DATA <<< "${STOP_CPU_DATA[${CORE}]}"

      CORE_LOAD=$(__calc_core_load__ START_CORE_DATA STOP_CORE_DATA)
      echo "Core ${CORE} load ${CORE_LOAD}%"
   done
}

function cpu_on_off( )
{
   local LOCAL_ENABLE=${1}
   declare -n LOCAL_CPUS=${2}

   for CPU in ${LOCAL_CPUS[@]}; do
      COMMAND="echo ${LOCAL_ENABLE} > /sys/devices/system/cpu/cpu${CPU}/online"
      echo "${COMMAND}"
      eval "${COMMAND}"
   done
}

function parse_range( )
{
   local INPUT_STRING="${1}"
   local -n RESULT_ARRAY=${2}

   IFS=',' read -r -a tokens <<< "${INPUT_STRING}"

   for token in "${tokens[@]}"; do
      if [[ "${token}" =~ ^[0-9]+$ ]]; then
         RESULT_ARRAY+=("${token}")
      elif [[ "${token}" =~ ^([0-9]+)-([0-9]+)$ ]]; then
         start=${BASH_REMATCH[1]}
         end=${BASH_REMATCH[2]}
         if (( start <= end )); then
            for (( i=start; i<=end; i++ )); do
               RESULT_ARRAY+=("${i}")
            done
         else
            echo "Error: invalid range '${token}' (end is less then begin)"
            exit 2
         fi
      else
            echo "Error: invalid '${token}'"
            exit 2
      fi
   done
}

function validate_parameters( )
{
   if [ -z ${CMD_ACTION+x} ]; then
      echo "'--action' is not defined"
      exit 1
   elif [ -z ${CMD_ACTION} ]; then
      echo "'--action' is defined but empty"
      exit 1
   else
      ALLOWED_ACTIONS=( "enable" "disable" "on" "off" )
      if [[ ! "${ALLOWED_ACTIONS[@]}" =~ "${ALLOWED_ACTIONS}" ]]; then
         echo "'--action' is defined but invalid"
         exit 1
      else
         echo "'--action' is defined and valid"
      fi
   fi

   if [ -z ${CMD_CPUS+x} ]; then
      echo "'--cpus' is not defined"
      exit 1
   elif [ -z ${CMD_CPUS} ]; then
      echo "'--cpus' is defined but empty"
      exit 1
   else
      parse_range "${CMD_CPUS}" CPUS
   fi

   if [ -z ${CMD_MEASURE_SECONDS+x} ]; then
      echo "'--ms' is not set => '1' will be used"
      CMD_MEASURE_SECONDS=1
   fi

   if [ -z ${CMD_DEBUG+x} ]; then
      echo "'--debug' is not defined"
      CMD_DEBUG=0
   else
      echo "'--debug' is defined"
      CMD_DEBUG=1
   fi
}

function parse_arguments( )
{
   echo "Parsing arguments..."

   for option in "$@"; do
      echo "Processing option '${option}'"
      case ${option} in
         --action=*)
            if [ -z ${CMD_ACTION+x} ]; then
               CMD_ACTION="${option#*=}"
               shift # past argument=value
               echo "CMD_ACTION: ${CMD_ACTION}"
            else
               echo "'--action' is already set to '${CMD_ACTION}'"
               exit 1
            fi
         ;;
         --cpus=*)
            if [ -z ${CMD_CPUS+x} ]; then
               CMD_CPUS="${option#*=}"
               shift # past argument=value
               echo "CMD_CPUS: ${CMD_CPUS}"
            else
               echo "'--cpus' is already set to '${CMD_CPUS}'"
               exit 1
            fi
         ;;
         --ms=*)
            if [ -z ${CMD_MEASURE_SECONDS+x} ]; then
               CMD_MEASURE_SECONDS="${option#*=}"
               shift # past argument=value
               echo "CMD_MEASURE_SECONDS: ${CMD_MEASURE_SECONDS}"
            else
               echo "'--ms' is already set to '${CMD_MEASURE_SECONDS}'"
               exit 1
            fi
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

   case ${CMD_ACTION} in
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
         echo "undefined CMD_ACTION: '${CMD_ACTION}'"
         exit 1
      ;;
   esac

}



main "$@"


