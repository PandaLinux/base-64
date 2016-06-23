#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="coreutils"
PKG_VERSION="8.22"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH=${PKG_NAME}-${PKG_VERSION}-noman-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Coreutils package contains utilities for showing and setting the basic system characteristics"
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv ../../sources/${TARBALL} ${TARBALL}
    ln -sv ../../patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    cat > config.cache << EOF
fu_cv_sys_stat_statfs2_bsize=yes
gl_cv_func_working_mkstemp=yes
EOF

    patch -Np1 -i ../${PATCH}

    ./configure --prefix=${HOST_TDIR}             \
                --build=${HOST}                   \
                --host=${TARGET}                  \
                --enable-install-program=hostname \
                --cache-file=config.cache

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${TOOLS_DIR}/bin/cat ]; then
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi