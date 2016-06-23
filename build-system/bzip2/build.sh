#!/usr/bin/env bash

shopt -s -o pipefail

PKG_NAME="bzip2"
PKG_VERSION="1.0.6"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Bzip2 package contains programs for compressing and decompressing files. Compressing text"
    echo -e "files with bzip2 yields a much better compression percentage than with the traditional gzip."
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
    sed -i -e 's:ln -s -f $(PREFIX)/bin/:ln -s :' Makefile
    sed -i 's@X)/man@X)/share/man@g' ./Makefile

    make ${MAKE_PARALLEL} -f Makefile-libbz2_so
    make ${MAKE_PARALLEL} clean
}

function instal() {
    make ${MAKE_PARALLEL} PREFIX=/usr install

    cp -v bzip2-shared /bin/bzip2
    cp -av libbz2.so* /lib
    ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
    rm -v /usr/bin/{bunzip2,bzcat,bzip2}
    ln -sv bzip2 /bin/bunzip2
    ln -sv bzip2 /bin/bzcat
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /bin/bzip2 ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi