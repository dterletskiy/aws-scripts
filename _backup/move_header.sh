#!/usr/bin/env bash



QEMU_ROOT_DIR=/mnt/dev/tmp/qemu_eauger/
KERNEL_ROOT_DIR=/mnt/dev/tmp/arm-platforms/



QEMU_HEADERS_PATH=${QEMU_ROOT_DIR}/linux-headers/linux/
KERNEL_HEADERS_PATH=${KERNEL_ROOT_DIR}/include/linux/
declare -a HEADERS=(
      const.h
      iommufd.h
      kvm.h
      memfd.h
      mman.h
      nvme_ioctl.h
      psci.h
      psp-sev.h
      stddef.h
      userfaultfd.h
      vduse.h
      vfio.h
      vfio_ccw.h
      vfio_zdev.h
      vhost.h
      vhost_types.h
      virtio_config.h
      virtio_ring.h
   )



QEMU_ASM_HEADERS_PATH=${QEMU_ROOT_DIR}/linux-headers/asm-arm64/
KERNEL_ASM_HEADERS_PATH=${KERNEL_ROOT_DIR}/arch/arm64/include/uapi/asm/
declare -a ASM_HEADERS=(
      bitsperlong.h
      kvm.h
      mman.h
      sve_context.h
      unistd.h
   )



function find_file( )
{
   local search_dir="$1"
   local file_name="$2"
   local -a found_files

   while IFS= read -r -d $'\0' file; do
      found_files+=("$file")
   done < <(find "$search_dir" -type f -name "${file_name}" -print0)

   local file_count="${#found_files[@]}"
   if (( file_count > 1 )); then
      echo "Warning: found ${file_count} '${file_name}' files."
   elif (( file_count == 0 )); then
      echo "File '${file_name}' was not found in '$search_dir'."
      return 1
   fi

   for file in "${found_files[@]}"; do
      local file_size=$(stat -c "%s" "${file}")
      echo "File size '${file}': ${file_size} bytes"
   done
}

function test_file( )
{
   local QEMU_DIR=${1}
   local KERNEL_DIR=${2}
   local FILE=${3}

   if ! [ -f ${QEMU_DIR}/${FILE} ]; then
      echo "QEMU_FATAL: '${QEMU_DIR}/${FILE}' file was not found"
      exit 1
   else
      FILE_SIZE=$(stat -c "%s" "${QEMU_DIR}/${FILE}")
      echo "QEMU_INFO: '${QEMU_DIR}/${FILE}' size: ${FILE_SIZE} bytes"
   fi

   if ! [ -f ${KERNEL_DIR}/${FILE} ]; then
      echo "KERNEL_ERROR: '${KERNEL_DIR}/${FILE}' file was not found"
      find_file ${KERNEL_ROOT_DIR} ${FILE}
   else
      FILE_SIZE=$(stat -c "%s" "${KERNEL_DIR}/${FILE}")
      echo "KERNEL_INFO: '${KERNEL_DIR}/${FILE}' size: ${FILE_SIZE} bytes"
      # cp -v ${KERNEL_DIR}/${FILE} ${QEMU_DIR}/${FILE}
   fi
}

function test_files( )
{
   local QEMU_DIR=${1}
   local KERNEL_DIR=${2}
   declare -n FILES=${3}

   for FILE in ${FILES[@]}; do
      echo ""
      test_file ${QEMU_DIR} ${KERNEL_DIR} ${FILE}
      echo ""
   done
}



test_files ${QEMU_HEADERS_PATH} ${KERNEL_HEADERS_PATH} HEADERS
test_files ${QEMU_ASM_HEADERS_PATH} ${KERNEL_ASM_HEADERS_PATH} ASM_HEADERS
