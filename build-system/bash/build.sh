#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="bash"
PKG_VERSION="4.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH=${PKG_NAME}-${PKG_VERSION}-branch_update-5.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Bash package contains the Bourne-Again SHell."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../${PATCH}

    ./configure --prefix=/usr           \
                --without-bash-malloc   \
                --with-installed-readline

    make ${MAKE_PARALLEL}
}

function runTest() {
    make ${MAKE_PARALLEL} tests
}

function instal() {
    make ${MAKE_PARALLEL} install
    mv -v /usr/bin/bash /bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /bin/bash ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi