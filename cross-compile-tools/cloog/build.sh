#!/usr/bin/env bash

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
    ln -sv "../../sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    LDFLAGS="-Wl,-rpath,${HOST_CROSS_TOOLS_DIR}/lib"        \
    ./configure --prefix="${HOST_CROSS_TOOLS_DIR}"          \
                --disable-static                            \
                --with-gmp-prefix="${HOST_CROSS_TOOLS_DIR}" \
                --with-isl-prefix="${HOST_CROSS_TOOLS_DIR}"

    cp -v Makefile{,.orig}
    sed '/cmake/d' Makefile.orig > Makefile

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
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
if [ -f "${HOST_CROSS_TOOLS_DIR}/lib/libcloog-isl.so" ]; then
    touch DONE
fi