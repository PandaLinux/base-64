#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="coreutils"
PKG_VERSION="8.22"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Coreutils package contains utilities for showing and setting the basic system characteristics"
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
    cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_working_mkstemp=yes
EOF

    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-noman-1.patch"

    ./configure --prefix="${HOST_TOOLS_DIR}"        \
                --build="${HOST}"                   \
                --host="${TARGET}"                  \
                --enable-install-program=hostname   \
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
if [ -f "${HOST_TOOLS_DIR}/bin/cat" ]; then
    touch DONE
fi