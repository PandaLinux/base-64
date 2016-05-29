#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="zlib"
PKG_VERSION="1.2.8"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Zlib package contains compression and decompression routines used by some programs."
    echo -e ""
    echo -e "Installation of Zlib:"
    echo -e "Several packages in the temporary system use Zlib, including Binutils, GCC, and Util-linux, so we will"
    echo -e "add it to ${HOST_TOOLS_DIR}."
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
    ./configure --prefix="${HOST_TOOLS_DIR}"

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
if [ -f "${HOST_TOOLS_DIR}/lib/libz.so" ]; then
    touch DONE
fi