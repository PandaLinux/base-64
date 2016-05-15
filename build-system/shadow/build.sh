#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="shadow"
PKG_VERSION="4.2.1"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Shadow package contains programs for handling passwords in a secure way."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "/sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    sed -i src/Makefile.in \
        -e 's/groups$(EXEEXT) //' -e 's/= nologin$(EXEEXT)/= /'
    find man -name Makefile.in -exec sed -i \
        -e 's/man1\/groups\.1 //' -e 's/man8\/nologin\.8 //' '{}' \;

    ./configure --sysconfdir=/etc

    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install

    sed -i /etc/login.defs \
        -e 's@#\(ENCRYPT_METHOD \).*@\1SHA512@' \
        -e 's@/var/spool/mail@/var/mail@'

    mv -v /usr/bin/passwd /bin
    touch /var/log/lastlog
    chgrp -v utmp /var/log/lastlog
    chmod -v 664 /var/log/lastlog
    pwconv
    grpconv
    passwd root
}

function passwd() {
  echo "${1}:root" | chpasswd
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/bin/su" ]; then
    touch DONE
fi