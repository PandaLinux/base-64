#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="flex"
PKG_VERSION="2.5.39"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Flex package contains a utility for generating programs that recognize patterns in text."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    ./configure --prefix=/usr

    make ${MAKE_PARALLEL}
}

function runTest() {
    if [ -f /usr/bin/bison ];then
        make ${MAKE_PARALLEL} check || true
    fi
}

function instal() {
    if [ ! -f /usr/bin/bison ]; then
        make ${MAKE_PARALLEL} install

        cat > /usr/bin/lex << "EOF"
#!/bin/sh
# Begin /usr/bin/lex

exec /usr/bin/flex -l "$@"

# End /usr/bin/lex
EOF
        chmod -v 755 /usr/bin/lex
fi
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/flex ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi