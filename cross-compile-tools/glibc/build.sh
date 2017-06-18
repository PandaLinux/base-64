#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="glibc"
PKG_VERSION="2.25"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Glibc package contains the main C library. This library provides the basic routines for"
    echo -e "allocating memory, searching directories, opening and closing files, reading and writing files, string"
    echo -e "handling, pattern matching, arithmetic, and so on."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    mkdir   ${BUILD_DIR}  &&
    cd      ${BUILD_DIR}  &&

    BUILD_CC=gcc CC="${TARGET}-gcc ${BUILD64}"          \
    AR="${TARGET}-ar" RANLIB="${TARGET}-ranlib"         \
    ../configure --prefix=${HOST_TDIR}                  \
                 --host=${TARGET}                       \
                 --build=${HOST}                        \
                 --enable-kernel=3.12.0                 \
                 --with-binutils=${HOST_CDIR}/bin       \
                 --with-headers=${HOST_TDIR}/include    \
                 --enable-obsolete-rpc

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
if [ -f ${TOOLS_DIR}/bin/ldd ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi
