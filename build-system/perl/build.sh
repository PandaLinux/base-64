#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="perl"
PKG_VERSION="5.20.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Perl package contains the Practical Extraction and Report Language."
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
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0

    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

    ./configure.gnu --prefix=/usr                   \
                    -Dvendorprefix=/usr             \
                    -Dman1dir=/usr/share/man/man1   \
                    -Dman3dir=/usr/share/man/man3   \
                    -Dpager="/bin/less -isR"        \
                    -Dusethreads -Duseshrplib

    make ${MAKE_PARALLEL}
}

function runTest() {
    set +e
    make ${MAKE_PARALLEL} runTest
    set -e
}

function instal() {
    make ${MAKE_PARALLEL} install
    unset BUILD_ZLIB BUILD_BZIP2
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/perl ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi