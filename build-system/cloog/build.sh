#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="cloog"
PKG_VERSION="0.18.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: CLooG is a library to generate code for scanning Z-polyhedra. In other words, it finds code that"
    echo -e "reaches each integral point of one or more parameterized polyhedra. GCC links with this library in order to"
    echo -e "enable the new loop generation code known as Graphite."
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
    CC="gcc -isystem /usr/include"          \
    LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
    ./configure --prefix=/usr \
                --with-isl=system

    sed -i '/cmake/d' Makefile

    make "${MAKE_PARALLEL}"
}

function test() {
    make "${MAKE_PARALLEL}" check
}

function instal() {
    make "${MAKE_PARALLEL}" install
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/usr/lib/libcloog-isl.so" ]; then
    touch DONE
fi