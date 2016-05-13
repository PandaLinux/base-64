#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="glibc"
PKG_VERSION="2.19"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Glibc package contains the main C library. This library provides the basic routines for"
    echo -e "allocating memory, searching directories, opening and closing files, reading and writing files, string"
    echo -e "handling, pattern matching, arithmetic, and so on."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "../../sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    mkdir   "${BUILD_DIR}"  &&
    cd      "${BUILD_DIR}"  &&

    echo "libc_cv_ssp=no" > config.cache &&

    BUILD_CC="gcc" CC="${TARGET}-gcc ${BUILD64}"                \
    AR="${CLFS_TARGET}-ar" RANLIB="${CLFS_TARGET}-ranlib"       \
    ../configure --prefix="${HOST_TOOLS_DIR}"                   \
                 --host="${TARGET}"                             \
                 --build="${HOST}"                              \
                 --disable-profile                              \
                 --enable-kernel=2.6.32                         \
                 --with-binutils="${HOST_CROSS_TOOLS_DIR}/bin"  \
                 --with-headers="${HOST_TOOLS_DIR}/include"     \
                 --enable-obsolete-rpc                          \
                 --cache-file=config.cache

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_TOOLS_DIR}/bin/ldd" ]; then
    touch DONE
fi