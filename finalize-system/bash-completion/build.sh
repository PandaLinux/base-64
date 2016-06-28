#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="bash-completion"
PKG_VERSION="20060301"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="bash_completion"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: Programmable bash completion."
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
	install -v -m644 bash_completion.sh /etc/profile.d/70-bash_completion.sh &&
	cp -v bash_completion /etc/ &&
	install -dv /etc/bash_completion.d &&
	install -dv /usr/share/bash-completion &&
	cp -v contrib/* /usr/share/bash-completion/ &&
	install -dv /usr/share/doc/bash-completion &&
	cp -v README /usr/share/doc/bash-completion/
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;popd;clean; }
# Verify installation
if [ -f /etc/bash_completion ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi