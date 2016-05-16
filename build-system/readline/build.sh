#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="readline"
PKG_VERSION="6.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Readline package is a set of libraries that offers command-line editing and history"
    echo -e "capabilities."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "/sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-branch_update-4.patch"

    ./configure --prefix=/usr \
                --libdir=/lib

    make "${MAKE_PARALLEL}" SHLIB_LIBS=-lncurses
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" SHLIB_LIBS=-lncurses install
    mv -v /lib/lib{readline,history}.a /usr/lib
    ln -svf ../../lib/$(readlink /lib/libreadline.so) /usr/lib/libreadline.so
    ln -svf ../../lib/$(readlink /lib/libhistory.so) /usr/lib/libhistory.so
    rm -v /lib/lib{readline,history}.so
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/usr/lib/libreadline.so" ]; then
    touch DONE
fi