#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="dpkg"
PKG_VERSION="1.18.7"

TARBALL="${PKG_NAME}_${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: This package provides the low-level infrastructure for handling the installation and removal of "
    echo -e "Debian software packages."
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
	export USE_ARCH=64                          &&
	CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"    \
	./configure --prefix=/usr                   \
				--sysconfdir=/etc               \
                --libdir=/usr/lib               \
                --localstatedir=/var            &&
	make ${MAKE_PARALLEL} PERL_LIBDIR=$(perl -V:sitelib | cut -d\' -f2)
}

function instal() {
	make ${MAKE_PARALLEL} PERL_LIBDIR=$(perl -V:sitelib | cut -d\' -f2) install &&
	unset USE_ARCH
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/dpkg ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi