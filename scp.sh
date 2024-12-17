KEY="/home/dmytro_terletskyi/.tda/aws/epam/c8g.metal-24xl-2024.11.19.pem"
REMOTE_USER=ubuntu
REMOTE_IP=44.242.156.218
REMOTE=${REMOTE_USER}@${REMOTE_IP}
REMOTE_DIR="/home/ubuntu/workspace/yocto/"
REMOTE_PATH=${REMOTE}:${REMOTE_DIR}

cd /mnt/dev/docker/builder/epam/meta-xt-prod-qemu/build/yocto/build-dom0/tmp/deploy/images/generic-armv8-xt/
FILE=./core-image-thin-initramfs-generic-armv8-xt.rootfs-20241119024009.cpio.gz
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/rootfs.dom0.cpio.gz
FILE=./Image--6.8.0-rc1+git0+6613476e22-r0-generic-armv8-xt-20241114105406.bin
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/linux-dom0

cd /mnt/dev/docker/builder/epam/meta-xt-prod-qemu/build/yocto/build-domd/tmp/deploy/images/generic-armv8-xt/
FILE=./qemu-image-minimal-generic-armv8-xt.rootfs-20241116080357.ext4
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/rootfs.domd.ext4
FILE=./xen-generic-armv8-xt
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/xen-generic-armv8-xt
FILE=./xen-generic-armv8-xt-syms
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/xen-generic-armv8-xt-syms
FILE=./u-boot-generic-armv8-xt.bin
scp -i ${KEY} -r ${FILE} ${REMOTE_PATH}/u-boot-generic-armv8-xt.bin







scp -i ${KEY} -r ${REMOTE}:/home/ubuntu/workspace/dump/qemu/ .
