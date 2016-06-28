#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="man-db"
PKG_VERSION="2.7.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Man-DB package contains programs for finding and viewing man pages."
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
    ./configure --prefix=/usr                   \
                --libexecdir=/usr/lib           \
                --sysconfdir=/etc               \
                --disable-setuid                \
                --with-browser=/usr/bin/lynx    \
                --with-vgrind=/usr/bin/vgrind   \
                --with-grap=/usr/bin/grap

    make ${MAKE_PARALLEL}
}

function runTest() {
    make ${MAKE_PARALLEL} check || true
}

function instal() {
    make ${MAKE_PARALLEL} install
    sed -i "s:man root:root root:g" /usr/lib/tmpfiles.d/man-db.conf
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/mandb ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi