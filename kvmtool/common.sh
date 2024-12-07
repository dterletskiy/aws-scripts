readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

KVMTOOL_REMOTE="https://git.kernel.org/pub/scm/linux/kernel/git/will/kvmtool.git"
KVMTOOL_BRANCH="master"

KVMTOOL_DIR=${ROOT_DIR}/kvmtool/
KVMTOOL_SOURCE_DIR=${KVMTOOL_DIR}/source/
KVMTOOL_DEPLOY_DIR=${KVMTOOL_DIR}/deploy/
