#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="libtool"
PKG_VERSION="2.4.6"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Libtool package contains the GNU generic library support script. It wraps the complexity of"
    echo -e "using shared libraries in a consistent, portable interface."
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
    ./configure --prefix=/usr

    make ${MAKE_PARALLEL}
}

function runTest() {
    make ${MAKE_PARALLEL} check || true
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/libtool ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi