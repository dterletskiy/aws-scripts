KEY="/home/dmytro_terletskyi/.tda/aws/epam/c8g.metal-24xl-2024.11.19.pem"
REMOTE_USER=ubuntu
REMOTE_IP=44.243.52.210
REMOTE=${REMOTE_USER}@${REMOTE_IP}
REMOTE_DIR="/home/ubuntu/workspace/yocto/"
REMOTE_PATH=${REMOTE}:${REMOTE_DIR}

cd /mnt/dev/docker/builder/epam/meta-xt-prod-qemu/build/yocto/build-dom0/tmp/deploy/images/generic-armv8-xt/
FILE=core-image-thin-initramfs-generic-armv8-xt.rootfs.cpio.gz
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/rootfs.dom0.cpio.gz
FILE=Image-generic-armv8-xt.bin
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/linux-dom0
FILE=vmlinux
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/vmlinux-dom0

cd /mnt/dev/docker/builder/epam/meta-xt-prod-qemu/build/yocto/build-domd/tmp/deploy/images/generic-armv8-xt/
FILE=qemu-image-minimal-generic-armv8-xt.rootfs.ext4
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/rootfs.domd.ext4
FILE=xen-generic-armv8-xt
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/${FILE}
FILE=xen-generic-armv8-xt.uImage
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/${FILE}
FILE=xen-generic-armv8-xt-syms
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/${FILE}
FILE=u-boot-generic-armv8-xt.bin
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/${FILE}

cd /mnt/dev/docker/builder/epam/meta-xt-prod-qemu/build/yocto/build-dom0/tmp/work/generic_armv8_xt-poky-linux/linux-generic-armv8/6.8.0-rc1+git/image/boot/
FILE=vmlinux-6.8.0-rc1-yocto-tiny
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/vmlinux-dom0

cd /mnt/dev/docker/builder/epam/meta-xt-prod-qemu/build/yocto/build-dom0/tmp/work-shared/generic-armv8-xt/kernel-source/
FILE=scripts
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/${FILE}

cd /mnt/dev/docker/builder/epam/meta-xt-prod-qemu/build/
FILE=full.img
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/${FILE}







scp -i ${KEY} -r ${REMOTE}:/home/ubuntu/workspace/dump/ /home/dmytro_terletskyi/Downloads/aws/dump/
