#!/usr/bin/env bash

set +h		# disable hashall
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
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "../../sources/$TARBALL" "$TARBALL"
    source "${CONFIG_FILE}"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-branch_update-1.patch"
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-pure64_specs-1.patch"

    printf '\n#undef STANDARD_STARTFILE_PREFIX_1\n#define STANDARD_STARTFILE_PREFIX_1 "%s/lib/"\n' "${HOST_TOOLS_DIR}" >> gcc/config/linux.h
    printf '\n#undef STANDARD_STARTFILE_PREFIX_2\n#define STANDARD_STARTFILE_PREFIX_2 ""\n' >> gcc/config/linux.h

    cp -v gcc/Makefile.in{,.orig}
    sed 's@\./fixinc\.sh@-c true@' gcc/Makefile.in.orig > gcc/Makefile.in

    mkdir   "${BUILD_DIR}"  &&
    cd      "${BUILD_DIR}"  &&

    ../configure --prefix="${HOST_TOOLS_DIR}"               \
                 --build="${HOST}"                          \
                 --host="${TARGET}"                         \
                 --target="${TARGET}"                       \
                 --with-local-prefix="${HOST_TOOLS_DIR}"    \
                 --disable-multilib                         \
                 --disable-nls                              \
                 --enable-languages=c,c++                   \
                 --disable-libstdcxx-pch                    \
                 --with-system-zlib                         \
                 --with-native-system-header-dir="${HOST_TOOLS_DIR}/include" \
                 --disable-libssp                           \
                 --enable-checking=release                  \
                 --enable-libstdcxx-time

    cp -v Makefile{,.orig}
    sed "/^HOST_\(GMP\|ISL\|CLOOG\)\(LIBS\|INC\)/s:/tools:/cross-tools:g" \
        Makefile.orig > Makefile

    make "${MAKE_PARALLEL}" AS_FOR_TARGET="${AS}" \
                            LD_FOR_TARGET="${LD}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install
    cp -v ../include/libiberty.h "${HOST_TOOLS_DIR}/include"
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_TOOLS_DIR}/bin/gcc" ]; then
    touch DONE
fi