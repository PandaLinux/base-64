#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="acl"
PKG_VERSION="2.2.52"

TARBALL="${PKG_NAME}-${PKG_VERSION}.src.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: ACL is a library for getting and setting POSIX Access Control Lists."
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
	sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
        libacl/__acl_to_any_text.c

    sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
    sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
    ./configure --prefix=/usr \
                --libexecdir=/usr/lib

    make ${MAKE_PARALLEL}
}

function runTest() {
    if [ -f /usr/bin/cat ];then
        make ${MAKE_PARALLEL} tests
    fi
}

function instal() {
	if [ ! -f /usr/bin/cat ];then
        make ${MAKE_PARALLEL} install install-dev install-lib

        mv -v /usr/lib/libacl.so.* /lib
        ln -sfv ../../lib/libacl.so.1 /usr/lib/libacl.so
        chmod 755 -v /lib/libacl.so.1.1.0
    fi
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;[[ ${MAKE_TESTS} = TRUE ]] && runTest;instal;popd;clean; }
# Verify installation
if [ -f /usr/lib/libacl.so ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi
