#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gcc"
PKG_VERSION="4.8.3"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"
BUILD_DIR="${PKG_NAME}-build"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The GCC package contains the GNU compiler collection, which includes the C and C++ compilers."
    echo -e ""
    echo -e "Installation of GCC:"
    echo -e "We will compile GCC, as a cross-compiler that will create executables for our target architecture, statically"
    echo -e "so that it will not need to look for Glibc's startfiles, which do not yet exist in ${HOST_TOOLS_DIR}. We will"
    echo -e "use this cross-compiler, plus the cross-linker we have just installed with Binutils, to compile Glibc. After"
    echo -e "Glibc is installed into ${HOST_TOOLS_DIR}, we can rebuild GCC so that it will then be able to build"
    echo -e "executables that link against the libraries in ${HOST_TOOLS_DIR}."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "../../sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-branch_update-1.patch"
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-pure64_specs-1.patch"

    printf '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "%s/lib/"\n' "${HOST_TOOLS_DIR}" >> gcc/config/linux.h
    printf '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h

    touch "${HOST_TOOLS_DIR}/include/limits.h"

    mkdir   "${BUILD_DIR}"  &&
    cd      "${BUILD_DIR}"  &&

    AR=ar LDFLAGS="-Wl,-rpath,${HOST_CROSS_TOOLS_DIR}/lib"          \
    ../configure --prefix="${HOST_CROSS_TOOLS_DIR}"                 \
                 --build="${HOST}"                                  \
                 --host="${HOST}"                                   \
                 --target="${TARGET}"                               \
                 --with-sysroot="${INSTALL_DIR}"                    \
                 --with-local-prefix="${HOST_TOOLS_DIR}"            \
                 --with-native-system-header-dir="${HOST_TOOLS_DIR}/include" \
                 --disable-nls                                      \
                 --disable-shared                                   \
                 --with-mpfr="${HOST_CROSS_TOOLS_DIR}"              \
                 --with-gmp="${HOST_CROSS_TOOLS_DIR}"               \
                 --with-isl="${HOST_CROSS_TOOLS_DIR}"               \
                 --with-cloog="${HOST_CROSS_TOOLS_DIR}"             \
                 --with-mpc="${HOST_CROSS_TOOLS_DIR}"               \
                 --without-headers                                  \
                 --with-newlib                                      \
                 --disable-decimal-float                            \
                 --disable-libgomp                                  \
                 --disable-libmudflap                               \
                 --disable-libssp                                   \
                 --disable-libatomic                                \
                 --disable-libitm                                   \
                 --disable-libsanitizer                             \
                 --disable-libquadmath                              \
                 --disable-threads                                  \
                 --disable-multilib                                 \
                 --disable-target-zlib                              \
                 --with-system-zlib                                 \
                 --enable-languages=c                               \
                 --enable-checking=release

    make "${MAKE_PARALLEL}" all-gcc all-target-libgcc
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install-gcc install-target-libgcc
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_CROSS_TOOLS_DIR}/bin/${TARGET}-gcc" ]; then
    touch DONE
fi