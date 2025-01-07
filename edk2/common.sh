# https://www.kraxel.org/blog/2022/05/edk2-virt-quickstart/



readonly SCRIPT_DIR_COMMON="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source ${SCRIPT_DIR_COMMON}/../common.sh

EDK2_REMOTE="https://github.com/tianocore/edk2.git"
EDK2_BRANCH="edk2-stable202411"

EDK2_DIR=$(root_dir)/edk2/${EDK2_BRANCH}/
EDK2_SOURCE_DIR=${EDK2_DIR}/source/
EDK2_DEPLOY_DIR=${EDK2_DIR}/deploy/
