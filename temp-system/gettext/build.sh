#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="gettext"
PKG_VERSION="0.19.8.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Gettext package contains utilities for internationalization and localization. These allow"
    echo -e "programs to be compiled with NLS (Native Language Support), enabling them to output messages in the user's"
    echo -e "native language."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    cd gettext-tools

	EMACS="no"                           \
    ./configure --prefix=${HOST_TDIR}    \
                --build=${HOST}          \
                --host=${TARGET}         \
                --disable-shared         \

    make ${MAKE_PARALLEL} -C gnulib-lib
    make ${MAKE_PARALLEL} -C intl pluralx.c
    make ${MAKE_PARALLEL} -C src msgfmt msgmerge xgettext
}

function instal() {
    cp -v src/{msgfmt,msgmerge,xgettext} ${HOST_TDIR}/bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${TOOLS_DIR}/bin/msgfmt ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi