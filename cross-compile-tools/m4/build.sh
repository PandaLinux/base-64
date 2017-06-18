#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="m4"
PKG_VERSION="1.4.18"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The M4 package contains a macro processor."
    echo -e ""
    echo -e "Installation of file:"
    echo -e "M4 is required to build GMP. We will compile and install an m4.md program into ${CROSS_DIR}, so that"
    echo -e "we have a known-good version which can be used to build GMP, both in here and the temporary system."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    ./configure --prefix=${HOST_CDIR}
    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${CROSS_DIR}/bin/m4 ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi