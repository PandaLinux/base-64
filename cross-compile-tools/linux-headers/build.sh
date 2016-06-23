#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="linux"
PKG_VERSION="3.14"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH=patch-${PKG_VERSION}.21.xz

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
    # Apply the linux sublevel patch
    xzcat ../${PATCH} | patch -Np1 -i -
    make ${MAKE_PARALLEL} mrproper
}

function runTest() {
    make ${MAKE_PARALLEL} ARCH=x86_64 headers_check
}

function instal() {
    make ${MAKE_PARALLEL} ARCH=x86_64 INSTALL_HDR_PATH=${HOST_TDIR} headers_install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;runTest;instal;popd;clean; }
# Verify installation
if [ -f ${TOOLS_DIR}/include/asm/a.out.h ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi