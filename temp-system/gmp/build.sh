#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gmp"
PKG_VERSION="6.1.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: GMP is a library for arithmetic on arbitrary precision integers, rational numbers, and"
    echo -e "floating-point numbers."
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
	source ~/.bashrc

	CXX=g++                             \
    CC_FOR_BUILD=gcc                    \
    ./configure --prefix=${HOST_TDIR}   \
                --build=${HOST}         \
                --host=${TARGET}        \
                --enable-cxx

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
if [ -f ${TOOLS_DIR}/lib/libgmp.so ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi
