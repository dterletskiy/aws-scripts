readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

QEMU_DIR=${ROOT_DIR}/qemu/
QEMU_REMOTE="https://github.com/eauger/qemu.git"
QEMU_BRANCH="v9.0-nv-rfcv3"
