#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="findutils"
PKG_VERSION="4.4.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Findutils package contains programs to find files. These programs are provided to recursively"
    echo -e "search through a directory tree and to create, maintain, and search a database (often faster than the"
    echo -e "recursive find, but unreliable if the database has not been recently updated)."
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
    ./configure --prefix=/usr                   \
                --libexecdir=/usr/lib/locate    \
                --localstatedir=/var/lib/locate

    make ${MAKE_PARALLEL}
}

function runTest() {
    make ${MAKE_PARALLEL} check
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
if [ -f /usr/bin/find ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi