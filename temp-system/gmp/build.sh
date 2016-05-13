#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gmp"
PKG_VERSION="6.0.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}a.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: GMP is a library for arithmetic on arbitrary precision integers, rational numbers, and"
    echo -e "floating-point numbers."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "../../sources/$TARBALL" "$TARBALL"
    source "${CONFIG_FILE}"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    CC_FOR_BUILD=gcc \
    ./configure --prefix="${HOST_TOOLS_DIR}"    \
                --build="${HOST}"               \
                --host="${TARGET}"              \
                --enable-cxx

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
if [ -f "${HOST_TOOLS_DIR}/lib/libgmp.so" ]; then
    touch DONE
fi