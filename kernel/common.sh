readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

# KERNEL_REMOTE="https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/"
# KERNEL_BRANCH=master

KERNEL_REMOTE="https://git.kernel.org/pub/scm/linux/kernel/git/maz/arm-platforms.git/"
# KERNEL_BRANCH="kvm-arm64/nv-6.11-sve-WIP"
KERNEL_BRANCH="kvm-arm64/nv-next"

KERNEL_DIR=${ROOT_DIR}/kernel/${KERNEL_BRANCH}/
KERNEL_SOURCE_DIR=${KERNEL_DIR}/source/
KERNEL_BUILD_DIR=${KERNEL_DIR}/build/
KERNEL_DEPLOY_DIR=${KERNEL_DIR}/deploy/
