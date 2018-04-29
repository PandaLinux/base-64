#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="less"
PKG_VERSION="530"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Less package contains a text file viewer."
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
    ./configure --prefix=/usr   \
                --sysconfdir=/etc

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
    mv -v /usr/bin/less /bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /bin/less ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi
