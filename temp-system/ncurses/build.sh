#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="ncurses"
PKG_VERSION="5.9"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Ncurses package contains libraries for terminal-independent handling of character screens."
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
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-bash_fix-1.patch"

    ./configure --prefix="${HOST_TOOLS_DIR}"    \
                --with-shared                   \
                --build="${HOST}"               \
                --host="${TARGET}"              \
                --without-debug                 \
                --without-ada                   \
                --enable-overwrite              \
                --with-build-cc=gcc

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
if [ -f "${HOST_TOOLS_DIR}/bin/tic" ]; then
    touch DONE
fi