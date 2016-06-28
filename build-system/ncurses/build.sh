#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="ncurses"
PKG_VERSION="6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH=${PKG_NAME}-${PKG_VERSION}-gcc-5.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Ncurses package contains libraries for terminal-independent handling of character screens."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../${PATCH}

    ./configure --prefix=/usr                \
                --with-shared                \
                --without-debug              \
                --enable-widec               \
                --enable-pc-files

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install

    mv -v /usr/lib/libncursesw.so.* /lib
	ln -svf ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

	for lib in ncurses form panel menu ; do
		echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
        ln -sfv lib${lib}w.a /usr/lib/lib${lib}.a
	done
	ln -sfv libncurses++w.a /usr/lib/libncurses++.a
	ln -sfv ncursesw6-config /usr/bin/ncurses6-config
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/tic ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi