#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gcc"
PKG_VERSION="4.8.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

PATCH1="${PKG_NAME}-${PKG_VERSION}-branch_update-1.patch"
PATCH2="${PKG_NAME}-${PKG_VERSION}-pure64-1.patch"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The GCC package contains the GNU compiler collection, which includes the C and C++ compilers."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH1} ${PATCH1}
    ln -sv /patches/${PATCH2} ${PATCH2}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../${PATCH1}
    patch -Np1 -i ../${PATCH2}

    sed -i 's@\./fixinc\.sh@-c true@' gcc/Makefile.in

    mkdir   ${BUILD_DIR}  &&
    cd      ${BUILD_DIR}  &&

    SED=sed CC="gcc -isystem /usr/include"  \
    CXX="g++ -isystem /usr/include"         \
    LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib" \
    ../configure --prefix=/usr              \
                 --libexecdir=/usr/lib      \
                 --enable-threads=posix     \
                 --enable-__cxa_atexit      \
                 --enable-clocale=gnu       \
                 --enable-languages=c,c++   \
                 --disable-multilib         \
                 --disable-libstdcxx-pch    \
                 --with-system-zlib         \
                 --enable-checking=release  \
                 --enable-libstdcxx-time

    make ${MAKE_PARALLEL}
}

function runTest() {
	# TODO: Skip only those tests that are known to fail
    ulimit -s 32768
    set +e
    make ${MAKE_PARALLEL} -k check
    set -e
    ../contrib/test_summary | grep -A7 Summ
}

function instal() {
    make ${MAKE_PARALLEL} install
    cp -v ../include/libiberty.h /usr/include
    ln -sv ../usr/bin/cpp /lib
    ln -sv gcc /usr/bin/cc
    mv -v /usr/lib/libstdc++*gdb.py /usr/share/gdb/auto-load/usr/lib
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH1} ${PATCH2}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/gcc ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi