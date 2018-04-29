#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="util-linux"
PKG_VERSION="2.32"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Util-linux package contains miscellaneous utility programs. Among them are utilities for"
    echo -e "handling file systems, consoles, partitions, and messages."
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
	mkdir -pv /var/lib/hwclock

    ./configure --enable-write \
    ADJTIME_PATH=/var/lib/hwclock/adjtime

    make ${MAKE_PARALLEL}
}

function runTest(){
	chown -Rv nobody . &&
	su nobody -s /bin/bash -c "PATH=${PATH} make -k check" || true
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[ ${MAKE_TESTS} == TRUE ] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /bin/mount ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi
