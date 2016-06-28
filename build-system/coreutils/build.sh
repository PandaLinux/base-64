#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="coreutils"
PKG_VERSION="8.23"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH=${PKG_NAME}-${PKG_VERSION}-uname-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The Coreutils package contains utilities for showing and setting the basic system characteristics"
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

    FORCE_UNSAFE_CONFIGURE=1                            \
    ./configure --prefix=/usr                           \
                --enable-no-install-program=kill,uptime \
                --enable-install-program=hostname       \
                --libexecdir=/usr/lib

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install

    mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date} /bin
    mv -v /usr/bin/{dd,df,echo,false,hostname,ln,ls,mkdir,mknod} /bin
    mv -v /usr/bin/{pwd,rm,rmdir,sleep,stty,true,uname} /bin
    mv -v /usr/bin/chroot /usr/sbin

    # Workaround
    cp -v /usr/bin/mv /bin
    rm -v /usr/bin/mv
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /bin/cat ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
    rm -v ${DONE_DIR_BUILD_SYSTEM}/acl
fi
