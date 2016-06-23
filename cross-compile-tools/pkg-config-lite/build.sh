#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="pkg-config-lite"
PKG_VERSION="0.28-1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: Pkg-config-lite is a tool to showHelp you insert the correct compiler options on the command line"
    echo -e "when compiling applications and libraries."
    echo -e ""
    echo -e "Installation of file:"
    echo -e "Several packages in the temporary system will use pkg-config to find various required and optional dependencies."
    echo -e "Unfortunately, this could result in those packages finding libraries on the host system and trying to link"
    echo -e "against them, which will not work. To avoid this problem, we will install a pkg-config binary in"
    echo -e "${CROSS_DIR} and configure it so that it will look for Pkg-config files only in ${TOOLS_DIR}."
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
    ./configure --prefix=${HOST_CDIR}   \
                --host=${TARGET}        \
                --with-pc-path=${HOST_TDIR}/lib/pkgconfig:${HOST_TDIR}/share/pkgconfig

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
if [ -f ${CROSS_DIR}/bin/pkg-config ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi