readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

# KVMTOOL_REMOTE="https://git.kernel.org/pub/scm/linux/kernel/git/will/kvmtool.git"
# KVMTOOL_BRANCH="master"

# KVMTOOL_REMOTE="https://github.com/dterletskiy/kvmtool.git"
# KVMTOOL_BRANCH="exp"

KVMTOOL_REMOTE="https://git.kernel.org/pub/scm/linux/kernel/git/maz/kvmtool.git/"
KVMTOOL_BRANCH="arm64/nv-6.5"
# KVMTOOL_BRANCH="arm64/nv-6.13"

KVMTOOL_DIR=${ROOT_DIR}/kvmtool/${KVMTOOL_BRANCH}/
KVMTOOL_SOURCE_DIR=${KVMTOOL_DIR}/source/
KVMTOOL_DEPLOY_DIR=${KVMTOOL_DIR}/deploy/
