#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="linux"
PKG_VERSION="3.14"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Linux Kernel contains a make target that installs “sanitized” kernel headers."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "/sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    xzcat ../"patch-${PKG_VERSION}.21.xz" | patch -Np1 -i -

    # Prepare for compilation
    make "${MAKE_PARALLEL}" mrproper
    # Set default configuration
    make "${MAKE_PARALLEL}" defconfig
    # Compile the kernel image and modules
    make "${MAKE_PARALLEL}"
    # Install the modules
    make "${MAKE_PARALLEL}" modules_install
    # Install the firmware
    make "${MAKE_PARALLEL}" firmware_install
}

function instal() {
    # Install the kernel
    cp -v arch/x86_64/boot/bzImage "/boot/${VM_LINUZ}"
    # Install the map file
    cp -v System.map "/boot/${SYSTEM_MAP}"
    # Backup kernel configuration file
    cp -v .config "/boot/${CONFIG_BACKUP}"

    # Generate grub configuration file
    grub-mkconfig -o /boot/grub/grub.cfg
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;test;instal;popd;clean; }
# Verify installation
if [ -f "/usr/include/asm/a.out.h" ]; then
    touch DONE
fi