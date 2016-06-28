#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="dbus"
PKG_VERSION="1.9.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: D-Bus is a message bus system, a simple way for applications to talk to one another."
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
    ./configure --prefix=/usr                   \
                --sysconfdir=/etc               \
                --libexecdir=/usr/lib/dbus-1.0  \
                --localstatedir=/var            \
                --with-systemdsystemunitdir=/lib/systemd/system

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install

    mv -v /usr/lib/libdbus-1.so.* /lib
    ln -sfv ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
    ln -sv /etc/machine-id /var/lib/dbus
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /usr/lib/libdbus-1.so ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi