#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="ncurses"
PKG_VERSION="5.9"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Ncurses package contains libraries for terminal-independent handling of character screens."
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
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-branch_update-4.patch"

    ./configure --prefix=/usr                \
                --libdir=/lib                \
                --with-shared                \
                --without-debug              \
                --enable-widec               \
                --with-manpage-format=normal \
                --enable-pc-files            \
                --with-default-terminfo-dir=/usr/share/terminfo

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install

    mv -v /lib/lib{panelw,menuw,formw,ncursesw,ncurses++w}.a /usr/lib
    ln -svf ../../lib/$(readlink /lib/libncursesw.so) /usr/lib/libncursesw.so
    ln -svf ../../lib/$(readlink /lib/libmenuw.so) /usr/lib/libmenuw.so
    ln -svf ../../lib/$(readlink /lib/libpanelw.so) /usr/lib/libpanelw.so
    ln -svf ../../lib/$(readlink /lib/libformw.so) /usr/lib/libformw.so
    rm -v /lib/lib{ncursesw,menuw,panelw,formw}.so

    for lib in curses ncurses form panel menu ; do
        echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
        ln -sfv lib${lib}w.a /usr/lib/lib${lib}.a
    done
    ln -sfv libncursesw.so /usr/lib/libcursesw.so
    ln -sfv libncursesw.a /usr/lib/libcursesw.a
    ln -sfv libncurses++w.a /usr/lib/libncurses++.a
    ln -sfv ncursesw5-config /usr/bin/ncurses5-config
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/usr/bin/tic" ]; then
    touch DONE
fi