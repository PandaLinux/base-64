#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="isl"
PKG_VERSION="0.15"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: ISL is a library for manipulating sets and relations of integer points bounded by linear"
    echo -e "constraints."
    echo -e ""
    echo -e "Installation of ISL:"
    echo -e "We will install ISL and CLooG to enable extra functionality for GCC. They are not strictly required,"
    echo -e "but GCC can link to them to enable its new loop generation feature called Graphite."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    LDFLAGS="-Wl,-rpath,${HOST_CDIR}/lib"      \
    ./configure --prefix=${HOST_CDIR}          \
                --disable-static               \
                --with-gmp-prefix=${HOST_CDIR}

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
if [ -f ${CROSS_DIR}/lib/libisl.so ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi