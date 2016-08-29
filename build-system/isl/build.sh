#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="isl"
PKG_VERSION="0.15"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: ISL is a library for manipulating sets and relations of integer points bounded by linear"
    echo -e "constraints."
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
    CC="gcc -isystem /usr/include" \
    LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
    ./configure --prefix=/usr

    make ${MAKE_PARALLEL}
}

function runTest() {
    make ${MAKE_PARALLEL} check
}

function instal() {
    make ${MAKE_PARALLEL} install
    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/libisl*gdb.py /usr/share/gdb/auto-load/usr/lib
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/lib/libisl.so ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi