#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="sudo"
PKG_VERSION="1.8.8"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: Sudo (su "do") allows a system administrator to delegate authority to give certain users (or "
    echo -e "groups of users) the ability to run some (or all) commands as root or another user while providing an audit "
    echo -e "trail of the commands and their arguments."
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
    CC="gcc ${BUILD64}"                     \
    ./configure --prefix=/usr               \
                --libdir=/usr/lib           \
                --libexecdir=/usr/lib       \
                --enable-noargs-shell       \
                --with-ignore-dot           \
                --with-all-insults          \
                --enable-shell-sets-home    \
                --without-pam &&
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
if [ -f /usr/bin/sudo ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi