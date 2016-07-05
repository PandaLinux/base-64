#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="cvs"
PKG_VERSION="1.11.23"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH1=${PKG_NAME}-${PKG_VERSION}-zlib-1.patch
PATCH2=${PKG_NAME}-${PKG_VERSION}-getline_fix-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "The Concurrent Versioning System (CVS) is a version control system."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH1} ${PATCH1}
    ln -sv /patches/${PATCH2} ${PATCH2}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	patch -Np1 -i ../${PATCH1}
	patch -Np1 -i ../${PATCH2}

	CC="gcc ${BUILD64}"         \
	./configure --prefix=/usr   \
				--libdir=/usr/lib

	make ${MAKE_PARALLEL}
}

function instal() {
	make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH1} ${PATCH2}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/cvs ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi