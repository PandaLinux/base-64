#!/usr/bin/env bash

shopt -s -o pipefail

PKG_NAME="bzip2"
PKG_VERSION="1.0.6"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Bzip2 package contains programs for compressing and decompressing files. Compressing text"
    echo -e "files with bzip2 yields a much better compression percentage than with the traditional gzip."
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
    cp -v Makefile{,.orig}
    sed -e 's@^\(all:.*\) test@\1@g' Makefile.orig > Makefile

    make CC="${CC}" AR="${AR}" RANLIB="${RANLIB}"
}

function test() {
    echo ""
}

function instal() {
    make PREFIX="${HOST_TOOLS_DIR}" install
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_TOOLS_DIR}/bin/bzip2" ]; then
    touch DONE
fi