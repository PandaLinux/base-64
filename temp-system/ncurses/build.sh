#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="ncurses"
PKG_VERSION="6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Ncurses package contains libraries for terminal-independent handling of character screens."
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
    ./configure --prefix=${HOST_TDIR}    \
                --with-shared            \
                --build=${HOST}          \
                --host=${TARGET}         \
                --without-debug          \
                --without-ada            \
                --enable-overwrite       \
                --with-build-cc=gcc

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${TOOLS_DIR}/bin/tic ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi
