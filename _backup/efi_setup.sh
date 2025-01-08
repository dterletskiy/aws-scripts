######################################################################
# Setup efi xen on host
######################################################################

lsblk -o NAME,SIZE,MODEL

DISK="/dev/nvme1n1"
ESP_PART="${DISK}p1"
ESP_PART_MOUNT_POINT="/mnt/esp/"
XEN_EFI_PATH="/home/${USER}/tda/xen.efi"
XEN_CFG_PATH="/home/${USER}/tda/xen.cfg"

sudo parted ${DISK} --script mklabel gpt
sudo parted ${DISK} --script mkpart ESP fat32 1MiB 513MiB
sudo parted ${DISK} --script set 1 boot on
sudo parted ${DISK} --script set 1 esp on

sudo mkfs.fat -F32 ${ESP_PART}

sudo mkdir -p ${ESP_PART_MOUNT_POINT}
sudo mount ${ESP_PART} ${ESP_PART_MOUNT_POINT}

sudo mkdir -p ${ESP_PART_MOUNT_POINT}/EFI/xen
sudo cp ${XEN_EFI_PATH} ${ESP_PART_MOUNT_POINT}/EFI/xen/xen.efi
sudo cp ${XEN_CFG_PATH} ${ESP_PART_MOUNT_POINT}/EFI/xen/xen.cfg

sudo mkdir -p ${ESP_PART_MOUNT_POINT}/EFI/BOOT
sudo cp ${XEN_EFI_PATH} ${ESP_PART_MOUNT_POINT}/EFI/BOOT/BOOTAA64.EFI
# sudo cp ${XEN_CFG_PATH} ${ESP_PART_MOUNT_POINT}/EFI/BOOT/BOOTAA64.cfg

sudo efibootmgr --create --disk ${DISK} --part 1 --label "Xen Hypervisor" --loader /EFI/xen/xen.efi
sudo efibootmgr --create --disk ${DISK} --part 1 --label "Stop boot" --loader /EFI/BOOT/BOOTAA64.EFI
sudo efibootmgr --bootorder 0005,0004,0003,0000,0001,0002

sudo umount ${ESP_PART_MOUNT_POINT}
