#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="file"
PKG_VERSION="5.19"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv "../../sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    ./configure --prefix=/cross-tools --disable-static
    make $MAKE_PARALLEL
}

function test() {
    echo ""
}

function instal() {
    make $MAKE_PARALLEL install
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { clean;prepare;unpack;pushd ${SRC_DIR};build;[[ $MAKE_TESTS = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/cross-tools/bin/file" ]; then
    touch DONE
fi