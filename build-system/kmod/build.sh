#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="kmod"
PKG_VERSION="18"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Kmod package contains programs for loading, inserting and removing kernel modules for Linux."
    echo -e "Kmod replaces the Module-Init-tools package."
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
    ./configure --prefix=/usr           \
                --bindir=/bin           \
                --sysconfdir=/etc       \
                --with-rootlibdir=/lib  \
                --with-zlib             \
                --with-xz

    make "${MAKE_PARALLEL}"
}

function test() {
    make "${MAKE_PARALLEL}" check
}

function instal() {
    make "${MAKE_PARALLEL}" install
    ln -sfv kmod /bin/lsmod
    for tool in depmod insmod modinfo modprobe rmmod; do
        ln -sfv ../bin/kmod /sbin/${tool}
    done
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/bin/kmod" ]; then
    touch DONE
fi