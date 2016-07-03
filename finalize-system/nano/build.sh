#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="nano"
PKG_VERSION="2.3.6"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "The Nano package contains a small, simple text editor."
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
    CC="gcc ${BUILD64}"             \
    ./configure --prefix=/usr       \
                --sysconfdir=/etc   \
                --enable-utf8       &&
	make ${MAKE_PARALLEL}
}

function instal() {
	make ${MAKE_PARALLEL} install

	cat > /etc/nanorc << EOF
set autoindent
set const
set fill 72
set historylog
set multibuffer
set nohelp
set regexp
set smooth
set suspend
EOF
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /usr/bin/nano ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi