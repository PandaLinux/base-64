#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="binutils"
PKG_VERSION="2.25.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Binutils package contains a linker, an assembler, and other tools for handling object files."
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
    mkdir   ${BUILD_DIR}  &&
    cd      ${BUILD_DIR}  &&

    CC="gcc -isystem /usr/include"          \
    LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
    ../configure --prefix=/usr              \
                 --libdir=/usr/lib          \
                 --enable-shared            \
                 --disable-multilib         \
                 --enable-64-bit-bfd        \
                 --enable-gold=yes          \
                 --enable-plugins           \
                 --enable-threads

    make ${MAKE_PARALLEL} tooldir=/usr
}

function runTest() {
    make ${MAKE_PARALLEL} check || true
}

function instal() {
    make ${MAKE_PARALLEL} tooldir=/usr install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/ld ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi