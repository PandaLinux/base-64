#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="wget"
PKG_VERSION="1.15"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "GNU Wget is a non-interactive utility for retrieving files using HTTP, HTTPS and FTP."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    CC="gcc ${BUILD64}"             \
    ./configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --libdir=/usr/lib   &&
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
if [ -f /usr/bin/wget ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi