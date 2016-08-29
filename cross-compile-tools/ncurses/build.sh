#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="ncurses"
PKG_VERSION="6.0"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Ncurses package contains libraries for terminal-independent handling of character screens."
    echo -e ""
    echo -e "Installation of file:"
    echo -e "When Ncurses is compiled, it executes tic to create a terminfo database in {prefix}/share/terminfo. If"
    echo -e "possible, the Makefile will use the tic binary that was just compiled in its source tree, but this does"
    echo -e "not work when Ncurses is cross-compiled. To allow the Ncurses build in Constructing a Temporary System to"
    echo -e "succeed, we will build and install a tic program that can be run on the host system."
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
	AWK=gawk                            \
    ./configure --prefix=${HOST_CDIR}   \
                --without-debug

    make ${MAKE_PARALLEL} -C include
    make ${MAKE_PARALLEL} -C progs tic
}

function instal() {
    install -v -m755 progs/tic ${HOST_CDIR}/bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f ${CROSS_DIR}/bin/tic ]; then
    touch ${DONE_DIR_CROSS_COMPILE_TOOLS}/$(basename $(pwd))
fi