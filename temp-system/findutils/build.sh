#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="findutils"
PKG_VERSION="4.4.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Findutils package contains programs to find files. These programs are provided to recursively"
    echo -e "search through a directory tree and to create, maintain, and search a database (often faster than the"
    echo -e "recursive find, but unreliable if the database has not been recently updated)."
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
    echo "gl_cv_func_wcwidth_works=yes" > config.cache
    echo "ac_cv_func_fnmatch_gnu=yes" >> config.cache

    ./configure --prefix="${HOST_TOOLS_DIR}"    \
                --build="${HOST}"               \
                --host="${TARGET}"              \
                --cache-file=config.cache

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_TOOLS_DIR}/bin/find" ]; then
    touch DONE
fi