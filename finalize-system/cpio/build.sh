#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="cpio"
PKG_VERSION="2.11"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The cpio package contains tools for archiving."
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
	sed -i -e '/gets is a/d' gnu/stdio.in.h &&
	CC="gcc ${BUILD64}"             \
	./configure --prefix=/usr       \
                --bindir=/bin       \
                --libdir=/usr/lib   \
                --libexecdir=/tmp   \
                --enable-mt         \
                --with-rmt=/usr/sbin/rmt &&
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
if [ -f /bin/cpio ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi