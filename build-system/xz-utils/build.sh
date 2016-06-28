#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="xz"
PKG_VERSION="5.2.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The XZ Utils package contains programs for compressing and decompressing files. Compressing text"
    echo -e "files with XZ Utils yields a much better compression percentage than with the traditional gzip."
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
    make ${MAKE_PARALLEL} check
}

function instal() {
    make ${MAKE_PARALLEL} install
    mv -v /usr/bin/{xz,lzma,lzcat,unlzma,unxz,xzcat} /bin
    mv -v /usr/lib/liblzma.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /bin/xz ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi