readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

QEMU_REMOTE="https://github.com/dterletskiy/qemu.git"
QEMU_BRANCH="v9.2.0-nv-2"

QEMU_DIR=$(root_dir)/qemu/${QEMU_BRANCH}/
QEMU_SOURCE_DIR=${QEMU_DIR}/source/
QEMU_BUILD_DIR=${QEMU_DIR}/build/
QEMU_DEPLOY_DIR=${QEMU_DIR}/deploy/
