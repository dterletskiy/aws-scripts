# links:
# https://github.com/eauger/qemu/commits/v9.0-nv-rfcv3/
# https://git.kernel.org/pub/scm/linux/kernel/git/maz/arm-platforms.git/refs/heads
# https://lists.gnu.org/archive/html/qemu-arm/2021-03/msg00853.html
# https://patchew.org/QEMU/20230227163718.62003-1-miguel.luis@oracle.com/
# https://lists.gnu.org/archive/html/qemu-devel/2024-02/msg02067.html
# https://lore.kernel.org/all/20240209160039.677865-1-eric.auger@redhat.com/
# https://patchwork.kernel.org/project/kvm/cover/20231222-kvm-arm64-sme-v2-0-da226cb180bb@kernel.org/



ROOT_DIR=/home/ubuntu/workspace/
YOCTO_DIR=${ROOT_DIR}/yocto/
DUMP_DIR=${ROOT_DIR}/dump/

PERF_TOOL="/home/ubuntu/workspace/kernel/source/tools/perf/perf"

function execute( )
{
	local COMMAND="${@}"
   echo "${COMMAND}"
   eval "${COMMAND}"
}
