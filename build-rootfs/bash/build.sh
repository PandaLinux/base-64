#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="bash"
PKG_VERSION="5.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Bash package contains the Bourne-Again SHell."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    wget http://ftp.gnu.org/gnu/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    ./configure --prefix="${INSTALL_DIR}/usr" \
                --without-bash-malloc

    make "${MAKE_PARALLEL}"
}

function runInstall() {
    make "${MAKE_PARALLEL}" install
    mv -v "${INSTALL_DIR}/usr/bin/bash" "${INSTALL_DIR}/bin/bash"
    ln -sv "${INSTALL_DIR}/bin/bash" "${INSTALL_DIR}/bin/sh"
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;runInstall;popd;clean; }