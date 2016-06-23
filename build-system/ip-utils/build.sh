#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="iputils"
PKG_VERSION="s20121221"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH="${PKG_NAME}-${PKG_VERSION}-fixes-2.patch"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The IPutils package contains programs for basic networking."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH} ${PATCH}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    patch -Np1 -i ../${PATCH}

    make ${MAKE_PARALLEL}                           \
    IPV4_TARGETS="tracepath ping clockdiff rdisc"   \
    IPV6_TARGETS="tracepath6 traceroute6"
}

function instal() {
    install -v -m755 ping /bin
    install -v -m755 clockdiff /usr/bin
    install -v -m755 rdisc /usr/bin
    install -v -m755 tracepath /usr/bin
    install -v -m755 trace{path,route}6 /usr/bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /bin/ping ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi
