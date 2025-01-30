# links:
# https://github.com/eauger/qemu/commits/v9.0-nv-rfcv3/
# https://git.kernel.org/pub/scm/linux/kernel/git/maz/arm-platforms.git/refs/heads
# https://lists.gnu.org/archive/html/qemu-arm/2021-03/msg00853.html
# https://patchew.org/QEMU/20230227163718.62003-1-miguel.luis@oracle.com/
# https://lists.gnu.org/archive/html/qemu-devel/2024-02/msg02067.html
# https://lore.kernel.org/all/20240209160039.677865-1-eric.auger@redhat.com/
# https://patchwork.kernel.org/project/kvm/cover/20231222-kvm-arm64-sme-v2-0-da226cb180bb@kernel.org/
# 
# https://www.arm.com/products/silicon-ip-cpu/neoverse?utm_source=google&utm_medium=cpc&utm_content=text_txt_na_neoverse&utm_campaign=mk30_brand-paid_products_2023_awareness_keyword_na&utm_term=neoverse&gad_source=1&gclid=Cj0KCQiAo5u6BhDJARIsAAVoDWsh29Hz1cni80TeoRhLXsxiJbYfS8c2uRxbgY5h_QlsZEv8szoXCMMaAiObEALw_wcB
# https://www.arm.com/products/silicon-ip-cpu/neoverse/neoverse-v2
# https://developer.arm.com/documentation/102375/latest/



readonly COMMON_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

readonly TIMESTAMP=$(date +'%Y.%m.%d_%H.%M.%S')
readonly DELIMITER="---------------------------------------------------------------------------------------------------"



readonly SHELL_FW=${COMMON_SCRIPT_DIR}/submodules/dterletskiy/shell_fw/
source ${SHELL_FW}/constants/console.sh
source ${SHELL_FW}/constants/constants.sh
source ${SHELL_FW}/base.sh
source ${SHELL_FW}/print.sh
source ${SHELL_FW}/ui.sh
source ${SHELL_FW}/drive.sh



function root_dir( )
{
   echo "/home/ubuntu/workspace/"
}

function yocto_dir( )
{
   echo "$(root_dir)/yocto/"
}

function dump_dir( )
{
   echo "$(root_dir)/dump/"
}

function dump_dir( )
{
   echo "$(root_dir)/dump/"
}

function backup_dir( )
{
   echo "$(root_dir)/backup/"
}

function compile_dt( )
{
   local IN_DTS=${1}
   local OUT_DTB=${2}

   local COMMAND="dtc -I dts -O dtb -o ${OUT_DTB} ${IN_DTS}"
   execute "${COMMAND}"
}

function decompile_dt( )
{
   local IN_DTB=${1}
   local OUT_DTS=${2}

   local COMMAND="dtc -I dtb -O dts -o ${OUT_DTS} ${IN_DTB}"
   execute "${COMMAND}"
}
