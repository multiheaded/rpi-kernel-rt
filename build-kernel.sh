#!/bin/bash

sudo apt install -y git bc bison flex libssl-dev make libc6-dev libncurses5-dev kmod sudo wget

export KERNEL_VERSION=5.15.y
export INSTALL_DTBS_PATH=~/rpi-kernel/rt-kernel
export KERNEL=kernel8
export ARCH=arm64
export INSTALL_MOD_PATH=~/rpi-kernel/rt-kernel
export CROSS_COMPILE=~/rpi-kernel/cross-pi-gcc-10.3.0-64/bin/aarch64-linux-gnu-

mkdir -p ${INSTALL_MOD_PATH}

cd ~/rpi-kernel

wget https://altushost-swe.dl.sourceforge.net/project/raspberry-pi-cross-compilers/Bonus%20Raspberry%20Pi%20GCC%2064-Bit%20Toolchains/Raspberry%20Pi%20GCC%2064-Bit%20Cross-Compiler%20Toolchains/Bullseye/GCC%2010.3.0/cross-gcc-10.3.0-pi_64.tar.gz

tar xf cross-gcc-10.3.0-pi_64.tar.gz

git clone --depth 1 https://github.com/raspberrypi/linux.git -b rpi-${KERNEL_VERSION}

cd ~/rpi-kernel/linux/
wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/5.15/patch-5.15.21-rt30.patch.gz

zcat patch-5.15.21-rt30.patch.gz | patch -p1
make bcm2711_defconfig
cp ../config-rt-5.15 .config
#config uses `make bcm2711_defconf` as default
# enable bpf jit
# disable kvm to get full rt preempt option
# use 1kHz Kernel scheduling frequency
# disable idle scheduling

make -j12 Image modules dtbs && \
sudo -E make -j4 modules_install dtbs_install

cd ${INSTALL_MOD_PATH}
sudo mv broadcom boot
sudo mv overlays boot/
tar cvpfz kernel8_5.15_rt.tgz boot lib
