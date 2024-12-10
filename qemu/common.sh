readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

# QEMU_REMOTE="https://github.com/eauger/qemu.git"
# QEMU_BRANCH="v9.0-nv-rfcv3"

QEMU_REMOTE="https://github.com/dterletskiy/qemu_eauger.git"
QEMU_BRANCH="v9.0-nv-rfcv3-ext"

QEMU_DIR=${ROOT_DIR}/qemu/
QEMU_SOURCE_DIR=${QEMU_DIR}/source/
QEMU_DEPLOY_DIR=${QEMU_DIR}/deploy/
