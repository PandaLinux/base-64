#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

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
    ln -sv ../../sources/${TARBALL} ${TARBALL}
    ln -sv ../../patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    xzcat ../${PATCH} | patch -Np1 -i -

	make ${MAKE_PARALLEL} distclean
    make ${MAKE_PARALLEL} mrproper
}

function runTest() {
    make ${MAKE_PARALLEL} headers_check
}

function instal() {
    make ${MAKE_PARALLEL} INSTALL_HDR_PATH=/usr headers_install
    find /usr/include -name .install -or -name ..install.cmd | xargs rm -fv
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/include/asm/a.out.h ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi