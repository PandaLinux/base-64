#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="texinfo"
PKG_VERSION="6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Texinfo package contains programs for reading, writing, and converting info pages."
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
    PERL=`which perl`                    \
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
if [ -f ${TOOLS_DIR}/bin/info ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi