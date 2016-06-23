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
    sed -i "s@/usr/include@${HOST_TDIR}/include@g" ext/Errno/Errno_pm.PL

    ./configure.gnu --prefix=${HOST_TDIR} \
                    -Dcc=gcc

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
    ln -sfv ${HOST_TDIR}/bin/perl /usr/bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${HOST_TDIR}/bin/perl ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi