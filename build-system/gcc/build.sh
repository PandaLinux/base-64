#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gcc"
PKG_VERSION="5.3.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

BUILD_DIR="${PKG_NAME}-build"

PATCH=${PKG_NAME}-${PKG_VERSION}-pure64-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The GCC package contains the GNU compiler collection, which includes the C and C++ compilers."
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

    sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in

    mkdir   ${BUILD_DIR}  &&
    cd      ${BUILD_DIR}  &&

    SED=sed CC="gcc -isystem /usr/include"  \
    CXX="g++ -isystem /usr/include"         \
    LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
    ../configure --prefix=/usr              \
                 --libexecdir=/usr/lib      \
                 --enable-languages=c,c++   \
                 --disable-multilib         \
                 --with-system-zlib         \
                 --enable-install-libiberty

    make ${MAKE_PARALLEL}
}

function runTest() {
	# TODO: Skip only those tests that are known to fail
    ulimit -s 32768
    make ${MAKE_PARALLEL} -k check || true
}

function instal() {
    make ${MAKE_PARALLEL} install
    ln -sv ../usr/bin/cpp /lib
    ln -sv gcc /usr/bin/cc
    mv -v /usr/lib/libstdc++*gdb.py /usr/share/gdb/auto-load/usr/lib
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/gcc ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi