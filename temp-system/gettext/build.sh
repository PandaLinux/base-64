#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gettext"
PKG_VERSION="0.19.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Gettext package contains utilities for internationalization and localization. These allow"
    echo -e "programs to be compiled with NLS (Native Language Support), enabling them to output messages in the user's"
    echo -e "native language."
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
    cd gettext-tools
    echo "gl_cv_func_wcwidth_works=yes" > config.cache

    ./configure --prefix="${HOST_TOOLS_DIR}"    \
                --build="${HOST}"               \
                --host="${TARGET}"              \
                --disable-shared                \
                --cache-file=config.cache

    make "${MAKE_PARALLEL}" -C gnulib-lib
    make "${MAKE_PARALLEL}" -C src msgfmt msgmerge xgettext
}

function test() {
    echo ""
}

function instal() {
    cp -v src/{msgfmt,msgmerge,xgettext} "${HOST_TOOLS_DIR}/bin"
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_TOOLS_DIR}/bin/msgfmt" ]; then
    touch DONE
fi