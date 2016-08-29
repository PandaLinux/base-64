#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="linux"
PKG_VERSION="4.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH=patch-${PKG_VERSION}.7.xz

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Linux Kernel contains a make target that installs “sanitized” kernel headers."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    xzcat ../${PATCH} | patch -Np1 -i -

	# Cleanup the kernel source tree
	make ${MAKE_PARALLEL} distclean
    # Prepare for compilation
    make ${MAKE_PARALLEL} mrproper
    # Set default configuration
    make ${MAKE_PARALLEL} ARCH=x86_64 defconfig
    # Compile the kernel image and modules
    make ${MAKE_PARALLEL} ARCH=x86_64
}

function instal() {
	# Install the modules
    make ${MAKE_PARALLEL} ARCH=x86_64 modules_install
    # Install the firmware
    make ${MAKE_PARALLEL} ARCH=x86_64 firmware_install

    # Install the kernel
    cp -v arch/x86_64/boot/bzImage /boot/${VM_LINUZ}
    # Install the map file
    cp -v System.map /boot/${SYSTEM_MAP}

    # Generate grub configuration file
    mkdir -pv /boot/grub &&
    grub-mkconfig -o /boot/grub/grub.cfg
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /boot/${VM_LINUZ} ] && [ -f /boot/grub/grub.cfg ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi