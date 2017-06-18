#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="diffutils"
PKG_VERSION="3.5"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Diffutils package contains programs that show the differences between files or directories."
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
	sed -i '233,237 s/max)/max) \\/' lib/intprops.h

    ./configure --prefix=${HOST_TDIR}    \
                --build=${HOST}          \
                --host=${TARGET}

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
if [ -f ${TOOLS_DIR}/bin/diff ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi