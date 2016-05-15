#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="linux"
PKG_VERSION="3.14"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Linux Kernel contains a make target that installs “sanitized” kernel headers."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "/sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    xzcat ../"patch-${PKG_VERSION}.21.xz" | patch -Np1 -i -

    make "${MAKE_PARALLEL}" mrproper
}

function test() {
    make "${MAKE_PARALLEL}" headers_check
}

function instal() {
    make "${MAKE_PARALLEL}" INSTALL_HDR_PATH=/usr headers_install
    find /usr/include -name .install -or -name ..install.cmd | xargs rm -fv
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;test;instal;popd;clean; }
# Verify installation
if [ -f "/usr/include/asm/a.out.h" ]; then
    touch DONE
fi