#!/usr/bin/env bash



readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh



readonly OPTION_DELIMITER=","
# IFS=","

readonly PARAMETER_REQUIRED="REQUIRED"
readonly PARAMETER_OPTIONAL="OPTIONAL"

readonly PARAMETER_TYPE_ARGUMENT="ARGUMENT"
readonly PARAMETER_TYPE_OPTION="OPTION"

readonly OPTION_DEFINED="DEFINED"
readonly OPTION_NOT_DEFINED="UNDEFINED"

declare -a CMD_PARAMETERS=( )



function split_string_add_to_array( )
{
   local LOCAL_STRING=${1}
   local LOCAL_DELIMITER=${2}
   declare -n LOCAL_ARRAY=${3}

   IFS="${LOCAL_DELIMITER}" read -r -a __ARRAY__ <<< "${LOCAL_STRING}"
   LOCAL_ARRAY+=("${__ARRAY__[@]}")
}

function print_parameters_help( )
{
   for _PARAMETER_ in "${CMD_PARAMETERS[@]}"; do
      local PARAMETER=${_PARAMETER_^^}
      local _NAME_="CMD_${PARAMETER}_NAME"
      local _TYPE_="CMD_${PARAMETER}_TYPE"

      local STRING="--${!_NAME_}:"$'\n'
      STRING+="   type: '${!_TYPE_}'"$'\n'
      if [ ${!_TYPE_} == ${PARAMETER_TYPE_ARGUMENT} ]; then
         local _ALLOWED_VALUES_="CMD_${PARAMETER}_ALLOWED_VALUES"
         local _REQUIRED_="CMD_${PARAMETER}_REQUIRED"

         STRING+="   required: '${!_REQUIRED_}'"$'\n'

         declare -n __ARRAY__=${_ALLOWED_VALUES_}
         STRING+="   allowed values: '${__ARRAY__[*]}'"$'\n'
      elif [ ${!_TYPE_} == ${PARAMETER_TYPE_OPTION} ]; then
         local _DEFINED_="CMD_${PARAMETER}_DEFINED"

         STRING+=""
      else
         print_error "undefined parameter type: '${PARAMETER}'"
         exit 1
      fi
      print_info ${STRING}
   done
}

function validate_argument( )
{
   local LOCAL_PARAMETER_NAME=${1}
   declare -n LOCAL_PARAMETER_VALUES=${2}
   declare -n LOCAL_PARAMETER_VALUES_ALLOWED=${3}
   local LOCAL_PARAMETER_CRITICAL=${4}

   if [[ 0 -eq ${#LOCAL_PARAMETER_VALUES[@]} ]]; then
      if [[ ${PARAMETER_REQUIRED} -eq ${LOCAL_PARAMETER_CRITICAL} ]]; then
         print_error "'${LOCAL_PARAMETER_NAME}' is not defined but it is required"
         exit 1
      fi
   else
      for ITEM in "${LOCAL_PARAMETER_VALUES[@]}"; do
         if [[ ! "${LOCAL_PARAMETER_VALUES_ALLOWED[@]}" =~ "${ITEM}" ]]; then
            print_error "'${LOCAL_PARAMETER_NAME}' is defined but invalid: '${ITEM}'"
            exit 1
         else
            # print_ok "'${LOCAL_PARAMETER_NAME}' is defined and valid: '${ITEM}'"
            :
         fi
      done
   fi
}

function validate_option( )
{
   local LOCAL_OPTION_NAME=${1}
   local LOCAL_OPTION_DEFINED=${2}

   if [ "${LOCAL_OPTION_DEFINED}" == "${OPTION_DEFINED}" ]; then
      # print_info "'${LOCAL_OPTION_NAME}' defined"
      :
   else
      # print_info "'${LOCAL_OPTION_NAME}' not defined"
      :
   fi
}

function validate_parameters( )
{
   for _PARAMETER_ in "${CMD_PARAMETERS[@]}"; do
      local PARAMETER=${_PARAMETER_^^}
      local _NAME_="CMD_${PARAMETER}_NAME"
      local _TYPE_="CMD_${PARAMETER}_TYPE"

      if [ ${!_TYPE_} == ${PARAMETER_TYPE_ARGUMENT} ]; then
         local _VALUES_="CMD_${PARAMETER}_VALUES"
         local _ALLOWED_VALUES_="CMD_${PARAMETER}_ALLOWED_VALUES"
         local _REQUIRED_="CMD_${PARAMETER}_REQUIRED"
         validate_argument ${!_NAME_} ${_VALUES_} ${_ALLOWED_VALUES_} ${!_REQUIRED_}
      elif [ ${!_TYPE_} == ${PARAMETER_TYPE_OPTION} ]; then
         local _DEFINED_="CMD_${PARAMETER}_DEFINED"
         validate_option ${!_NAME_} ${!_DEFINED_}
      else
         print_error "undefined parameter type: '${PARAMETER}'"
         exit 1
      fi
   done
}

function parse_arguments( )
{
   for option in "$@"; do
      if [[ ${option} == --help ]]; then
         print_parameters_help
         exit 0
      fi

      local OPTION_PROCESSED=0
      for _PARAMETER_ in "${CMD_PARAMETERS[@]}"; do
         local PARAMETER=${_PARAMETER_^^}
         local _NAME_="CMD_${PARAMETER}_NAME"
         local _TYPE_="CMD_${PARAMETER}_TYPE"
         local _VALUES_="CMD_${PARAMETER}_VALUES"

         if [ ${!_TYPE_} == ${PARAMETER_TYPE_ARGUMENT} ]; then
            if [[ ${option} == --${!_NAME_}=* ]]; then
               local __TEMP__="${option#*=}"
               if [ -z "${__TEMP__}" ]; then
                  print_error "'--${!_NAME_}' is defined but has no value"
                  exit 1
               fi
               split_string_add_to_array "${__TEMP__}" ${OPTION_DELIMITER} ${_VALUES_}
               OPTION_PROCESSED=1
               break
            fi
         elif [ ${!_TYPE_} == ${PARAMETER_TYPE_OPTION} ]; then
            if [[ ${option} == --${!_NAME_} ]]; then
               local _DEFINED_="CMD_${PARAMETER}_DEFINED"
               declare "${!_DEFINED_}=${OPTION_DEFINED}"
               OPTION_PROCESSED=1
               break
            fi
         fi
      done

      if [[ ${OPTION_PROCESSED} -eq 0 ]]; then
         print_error "unsupported parameter '${option}'"
         exit 1
      fi
   done

   validate_parameters
}



function define_argument( )
{
   local LOCAL_NAME=${1}
   local LOCAL_TYPE=${2}
   local LOCAL_REQUIRED=${3}
   # declare -n LOCAL_PARAMETER_VALUES_ALLOWED=${4}
   declare -a LOCAL_PARAMETER_VALUES_ALLOWED=(${4})
   # declare -n LOCAL_PARAMETER_VALUES_DEFAULT=${5}
   declare -a LOCAL_PARAMETER_VALUES_DEFAULT=(${5})

   local LOCAL_NAME_UP="${LOCAL_NAME^^}"

   eval "readonly CMD_${LOCAL_NAME_UP}_NAME=\"${LOCAL_NAME}\""
   eval "readonly CMD_${LOCAL_NAME_UP}_TYPE=${PARAMETER_TYPE_ARGUMENT}"
   eval "readonly CMD_${LOCAL_NAME_UP}_REQUIRED=${PARAMETER_REQUIRED}"
   eval "declare -g CMD_${LOCAL_NAME_UP}_ALLOWED_VALUES=(\"${LOCAL_PARAMETER_VALUES_ALLOWED[@]}\")"
   eval "declare -g CMD_${LOCAL_NAME_UP}_DEFAULT_VALUES=(\"${LOCAL_PARAMETER_VALUES_DEFAULT[@]}\")"
   eval "declare -g CMD_${LOCAL_NAME_UP}_VALUES=( )"
}

function define_option( )
{
   local LOCAL_NAME=${1}
   local LOCAL_TYPE=${2}

   local LOCAL_NAME_UP="${LOCAL_NAME^^}"

   eval "readonly CMD_${LOCAL_NAME_UP}_NAME=\"${LOCAL_NAME}\""
   eval "readonly CMD_${LOCAL_NAME_UP}_TYPE=${PARAMETER_TYPE_OPTION}"
   eval "readonly CMD_${LOCAL_NAME_UP}_DEFINED=${OPTION_NOT_DEFINED}"
}

function define_parameter( )
{
   local LOCAL_NAME=${1}
   local LOCAL_TYPE=${2}

   if [ ${LOCAL_TYPE} == ${PARAMETER_TYPE_ARGUMENT} ]; then
      define_argument "$@"
   elif [ ${LOCAL_TYPE} == ${PARAMETER_TYPE_OPTION} ]; then
      define_option "$@"
   else
      print_error "undefined parameter type: '${LOCAL_NAME}'"
      exit 1
   fi

   CMD_PARAMETERS+=( "${LOCAL_NAME}" )
   test_defined_parameter ${LOCAL_NAME}
}

function test_defined_parameter( )
{
   local LOCAL_NAME=${1}
   local LOCAL_NAME_UP="${LOCAL_NAME^^}"


   local _NAME_="CMD_${LOCAL_NAME_UP}_NAME"
   if [ -z ${!_NAME_+x} ]; then
      print_error "'${_NAME_}' is not defined"
      exit 1
   fi

   local _TYPE_="CMD_${LOCAL_NAME_UP}_TYPE"
   if [ -z ${!_TYPE_+x} ]; then
      print_error "'${_TYPE_}' is not defined"
      exit 1
   fi

   if [ ${!_TYPE_} == ${PARAMETER_TYPE_ARGUMENT} ]; then
      local _REQUIRED_="CMD_${LOCAL_NAME_UP}_REQUIRED"
      if [ -z ${!_REQUIRED_+x} ]; then
         print_error "'${_REQUIRED_}' is not defined"
         exit 1
      fi

      local _ALLOWED_VALUES_="CMD_${LOCAL_NAME_UP}_ALLOWED_VALUES"
      if ! declare -p ${_ALLOWED_VALUES_} 2>/dev/null | grep -q 'declare -a'; then
         print_error "'${_ALLOWED_VALUES_}' is not defined 3"
      fi

      local _VALUES_="CMD_${LOCAL_NAME_UP}_VALUES"
      if ! declare -p ${_VALUES_} 2>/dev/null | grep -q 'declare -a'; then
         print_error "'${_VALUES_}' is not defined 3"
      fi
   elif [ ${!_TYPE_} == ${PARAMETER_TYPE_OPTION} ]; then
      local _DEFINED_="CMD_${LOCAL_NAME_UP}_DEFINED"
      if [ -z ${!_DEFINED_+x} ]; then
         print_error "'${_DEFINED_}' is not defined"
         exit 1
      fi
   else
      print_error "undefined parameter type: '${!_NAME_}'"
      exit 1
   fi
}
