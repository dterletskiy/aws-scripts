readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

KERNEL_DIR=${ROOT_DIR}/kernel/
KERNEL_REMOTE="https://git.kernel.org/pub/scm/linux/kernel/git/maz/arm-platforms.git/"
KERNEL_BRANCH="kvm-arm64/nv-6.11-sve-WIP"
