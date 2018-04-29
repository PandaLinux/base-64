#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="binutils"
PKG_VERSION="2.30"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Binutils package contains a linker, an assembler, and other tools for handling object files."
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
		 
    ../configure --prefix=${HOST_TDIR}            \
             --with-sysroot=${INSTALL_DIR}        \
             --with-lib-path=${HOST_TDIR}/lib \
             --target=${TARGET}          \
             --disable-nls              \
             --disable-werror

    make ${MAKE_PARALLEL}
    
    mkdir -v ${HOST_TDIR}/lib && ln -sv lib ${HOST_TDIR}/lib64
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
if [ -f ${TOOLS_DIR}/bin/${TARGET}-ld ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi
