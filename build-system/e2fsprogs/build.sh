#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="e2fsprogs"
PKG_VERSION="1.42.13"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The E2fsprogs package contains the utilities for handling the ext2 file system. It also supports"
    echo -e "the ext3 and ext4 journaling file systems."
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
    mkdir -pv   ${BUILD_DIR}  &&
    cd          ${BUILD_DIR}  &&

    ../configure --prefix=/usr          \
                --bindir=/bin           \
                 --with-root-prefix=""  \
                 --enable-elf-shlibs    \
                 --disable-libblkid     \
                 --disable-libuuid      \
                 --disable-fsck         \
                 --disable-uuidd

    make ${MAKE_PARALLEL}
}

function runTest() {
    make ${MAKE_PARALLEL} check
}

function instal() {
    make ${MAKE_PARALLEL} install
    make ${MAKE_PARALLEL} install-libs
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /sbin/e2fsck ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi