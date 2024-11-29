#!/usr/bin/env bash



declare -a CPUS

parse_range( )
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
      ALLOWED_ACTIONS=( "enable" "disable" )
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

   local ENABLE=0

   case ${CMD_ACTION} in
      enable)
         ENABLE=1
      ;;
      disable)
         ENABLE=0
      ;;
      *)
         echo "undefined CMD_ACTION: '${CMD_ACTION}'"
         exit 1
      ;;
   esac

   for CPU in ${CPUS[@]}; do
      COMMAND="echo ${ENABLE} > /sys/devices/system/cpu/cpu${CPU}/online"
      echo "${COMMAND}"
      eval "${COMMAND}"
   done
}



main "$@"
