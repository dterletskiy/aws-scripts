#!/usr/bin/env bash



declare -A ARGUMENT_ACTION=(
   ['name']="action"
   ['type']="parameter"
   ['values']=$(declare -p VALUES=( "start" "stop" ))
)

declare -A ARGUMENT_DEBUG=(
   ['name']="debug"
   ['type']="option"
)

declare -A ARGUMENTS=(
   ["action"]="$(declare -p ARGUMENT_ACTION)"
   ["debug"]="$(declare -p ARGUMENT_DEBUG)"
)

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



# main "$@"



function get_inner_dict( )
{
   declare -p _INNER_DIRT_=${1}
   local KEY=${2}
   declare -p _RESULT_DICT_=${3}

   eval "${_INNER_DIRT_[${KEY}]}"
}

for COUNT in "${!ARGUMENTS[@]}"; do
   ARGUMENT=${COUNT}
   ARGUMENT_DATA=${ARGUMENTS[${COUNT}]}
   ARGUMENT_TYPE=${ARGUMENT_DATA["type"]}

   echo ${ARGUMENT}
   echo ${ARGUMENT_DATA}
   echo ${ARGUMENT_TYPE}

   # if [ "parameter" = ${ARGUMENT_TYPE} ]; then
   #    echo "parameter"
   #    declare -p ARGUMENT_VALUES=${ARGUMENT_DATA["values"]}
   #    for ARGUMENT_VALUE in "${!ARGUMENTS[@]}"; do
   #       echo ${ARGUMENT_VALUE}
   #    done
   # elif [ "option" = ${ARGUMENT_TYPE} ]; then
   #    echo "option"
   # fi
done
