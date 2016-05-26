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
    make -j1 mrproper
    # Set default configuration
    make -j1 defconfig
    # Compile the kernel image and modules
    make -j1
}

function instal() {
	# Install the modules
    make -j1 modules_install
    # Install the firmware
    make -j1 firmware_install
    
    # Install the kernel
    cp -v arch/x86_64/boot/bzImage "/boot/${VM_LINUZ}"
    # Install the map file
    cp -v System.map "/boot/${SYSTEM_MAP}"
    # Backup kernel configuration file
    cp -v .config "/boot/${CONFIG_BACKUP}"

    # Generate grub configuration file
    mkdir -pv "/boot/grub" &&
    grub-mkconfig -o "/boot/grub/grub.cfg"
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;test;instal;popd;clean; }
# Verify installation
if [ -f "/boot/${VM_LINUZ}" && -f "/boot/grub/grub.cfg" ]; then
    touch DONE
fi
