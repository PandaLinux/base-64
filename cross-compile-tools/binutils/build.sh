#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="binutils"
PKG_VERSION="2.28"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Binutils package contains a linker, an assembler, and other tools for handling object files."
    echo -e ""
    echo -e "Installation of Binutils:"
    echo -e "It is important that Binutils be compiled before Glibc and GCC because both Glibc and GCC perform various"
    echo -e "tests on the available linker and assembler to determine which of their own features to enable."
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

    AR=ar AS=as \
    ../configure --prefix=${HOST_CDIR}              \
                 --host=${HOST}                     \
                 --target=${TARGET}                 \
                 --with-sysroot=${INSTALL_DIR}      \
                 --with-lib-path=${HOST_TDIR}/lib   \
                 --disable-nls                      \
                 --disable-static                   \
                 --enable-64-bit-bfd                \
                 --disable-multilib                 \
                 --enable-gold=yes                  \
                 --enable-plugins                   \
				 --enable-threads                   \
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
if [ -f ${CROSS_DIR}/bin/${TARGET}-ld ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi