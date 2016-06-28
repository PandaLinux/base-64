#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="grub"
PKG_VERSION="2.02~beta2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The GRUB package contains the GRand Unified Bootloader."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	unset CFLAGS CXXFLAGS

	./configure --prefix=/usr           \
				--sbindir=/sbin         \
				--sysconfdir=/etc       \
				--disable-grub-emu-usb  \
				--disable-efiemu        \
				--disable-werror

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /sbin/grub-install ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi