#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gzip"
PKG_VERSION="1.6"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Gzip package contains programs for compressing and decompressing files."
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
                --bindir=/bin

    make ${MAKE_PARALLEL}
}

function runTest() {
    set +e
    make ${MAKE_PARALLEL} check
    set -e
}

function instal() {
    make ${MAKE_PARALLEL} install
    mv -v /bin/z{egrep,cmp,diff,fgrep,force,grep,less,more,new} /usr/bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /bin/gzip ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi