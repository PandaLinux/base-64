#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gcc"
PKG_VERSION="4.8.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

PATCH1=${PKG_NAME}-${PKG_VERSION}-branch_update-1.patch
PATCH2=${PKG_NAME}-${PKG_VERSION}-pure64_specs-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The GCC package contains the GNU compiler collection, which includes the C and C++ compilers."
    echo -e ""
    echo -e "Installation of GCC:"
    echo -e "We will compile GCC, as a cross-compiler that will create executables for our target architecture, statically"
    echo -e "so that it will not need to look for Glibc's startfiles, which do not yet exist in ${TOOLS_DIR}. We will"
    echo -e "use this cross-compiler, plus the cross-linker we have just installed with Binutils, to compile Glibc. After"
    echo -e "Glibc is installed into ${TOOLS_DIR}, we can rebuild GCC so that it will then be able to build"
    echo -e "executables that link against the libraries in ${TOOLS_DIR}."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
    ln -sv ../../patches/${PATCH1} ${PATCH1}
    ln -sv ../../patches/${PATCH2} ${PATCH2}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../${PATCH1}
    patch -Np1 -i ../${PATCH2}

    printf '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "%s/lib/"\n' "${HOST_TDIR}" >> gcc/config/linux.h
    printf '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h

    mkdir   ${BUILD_DIR}  &&
    cd      ${BUILD_DIR}  &&

    AR=ar LDFLAGS="-Wl,-rpath,${HOST_CDIR}/lib"   \
    ../configure --prefix=${HOST_CDIR}            \
                 --build=${HOST}                  \
                 --target=${TARGET}               \
                 --host=${HOST}                   \
                 --with-sysroot=${INSTALL_DIR}    \
                 --with-local-prefix=${HOST_TDIR} \
                 --with-native-system-header-dir=${HOST_TDIR}/include \
                 --disable-nls                    \
                 --disable-static                 \
                 --enable-languages=c,c++         \
                 --enable-__cxa_atexit            \
                 --enable-threads=posix           \
                 --disable-multilib               \
                 --with-mpc=${HOST_CDIR}          \
                 --with-mpfr=${HOST_CDIR}         \
                 --with-gmp=${HOST_CDIR}          \
                 --with-cloog=${HOST_CDIR}        \
                 --with-isl=${HOST_CDIR}          \
                 --with-system-zlib               \
                 --enable-checking=release        \
                 --enable-libstdcxx-time

    make ${MAKE_PARALLEL} AS_FOR_TARGET=${TARGET}-as \
                          LD_FOR_TARGET=${TARGET}-ld
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH1} ${PATCH2}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${CROSS_DIR}/${TARGET}/lib/libtsan.so ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi