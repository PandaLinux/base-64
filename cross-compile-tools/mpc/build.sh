#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="mpc"
PKG_VERSION="1.0.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: MPC is a C library for the arithmetic of complex numbers with arbitrarily high precision"
    echo -e "and correct rounding of the result."
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
    LDFLAGS="-Wl,-rpath,${HOST_CROSS_TOOLS_DIR}/lib"    \
    ./configure --prefix="${HOST_CROSS_TOOLS_DIR}"      \
                --disable-static                        \
                --with-gmp="${HOST_CROSS_TOOLS_DIR}"    \
                --with-mpfr="${HOST_CROSS_TOOLS_DIR}"
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
if [ -f "${HOST_CROSS_TOOLS_DIR}/lib/libmpc.so" ]; then
    touch DONE
fi