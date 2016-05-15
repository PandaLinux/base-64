#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="expect"
PKG_VERSION="5.45"

TARBALL="${PKG_NAME}${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Expect package contains a program for carrying out scripted dialogues with other interactive"
    echo -e "programs."
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
    ./configure --prefix="${HOST_TOOLS_DIR}"    \
    --with-tcl="${HOST_TOOLS_DIR}/lib"          \
    --with-tclinclude="${HOST_TOOLS_DIR}/include"

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" SCRIPTS="" install
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_TOOLS_DIR}/bin/expect" ]; then
    touch DONE
fi