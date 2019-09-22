#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="linux"
PKG_VERSION="5.2.8"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

LINK="https://www.kernel.org/pub/$PKG_NAME/kernel/v5.x/$TARBALL"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Linux Kernel contains a make target that installs “sanitized” kernel headers."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    wget "$WGET_OPTIONS" "$LINK" -O "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    make "${MAKE_PARALLEL}" distclean
    make "${MAKE_PARALLEL}" mrproper
}

function instal() {
    make "${MAKE_PARALLEL}" INSTALL_HDR_PATH=dest headers_install
    cp -rv dest/include/* /tools/include
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /tools/include/asm/a.out.h ]; then
    touch "${DONE_DIR_TEMP_SYSTEM}"/$(basename $(pwd))
fi
