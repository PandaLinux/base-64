#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="readline"
PKG_VERSION="6.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH="${PKG_NAME}-${PKG_VERSION}-branch_update-4.patch"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Readline package is a set of libraries that offers command-line editing and history"
    echo -e "capabilities."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../${PATCH}

    ./configure --prefix=/usr \
                --libdir=/lib

    make ${MAKE_PARALLEL} SHLIB_LIBS=-lncurses
}

function instal() {
    make ${MAKE_PARALLEL} SHLIB_LIBS=-lncurses install
    mv -v /lib/lib{readline,history}.a /usr/lib
    ln -svf ../../lib/$(readlink /lib/libreadline.so) /usr/lib/libreadline.so
    ln -svf ../../lib/$(readlink /lib/libhistory.so) /usr/lib/libhistory.so
    rm -v /lib/lib{readline,history}.so
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /usr/lib/libreadline.so ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi