#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="kbd"
PKG_VERSION="2.0.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Kbd package contains key-table files and keyboard utilities."
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
    PKG_CONFIG_PATH="/tools/lib/pkgconfig"  \
    ./configure --prefix=/usr               \
                --disable-vlock             \
                --enable-optional-progs

    make ${MAKE_PARALLEL}
}

function runTest() {
    make ${MAKE_PARALLEL} check
}

function instal() {
    make ${MAKE_PARALLEL} install
    mv -v /usr/bin/{loadkeys,setfont} /bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /bin/setfont ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi