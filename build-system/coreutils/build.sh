#!/usr/bin/env bash

set +h		# disable hashall
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
    ln -sv "/sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-uname-1.patch"
    patch -Np1 -i ../"${PKG_NAME}-${PKG_VERSION}-noman-1.patch"

    FORCE_UNSAFE_CONFIGURE=1                            \
    ./configure --prefix=/usr                           \
                --enable-no-install-program=kill,uptime \
                --enable-install-program=hostname       \
                --libexecdir=/usr/lib

    make -j1
}

function test() {
    make "${MAKE_PARALLEL}" NON_ROOT_USERNAME=nobody check-root
    echo "dummy:x:1000:nobody" >> /etc/group
    chown -Rv nobody .
    su nobody -s /bin/bash \
              -c "PATH=$PATH make ${MAKE_PARALLEL} RUN_EXPENSIVE_TESTS=yes -k check || true"
    sed -i '/dummy/d' /etc/group
}

function instal() {
    make "${MAKE_PARALLEL}" install

    mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date} /bin
    mv -v /usr/bin/{dd,df,echo,false,hostname,ln,ls,mkdir,mknod} /bin
    mv -v /usr/bin/{mv,pwd,rm,rmdir,stty,true,uname} /bin
    mv -v /usr/bin/chroot /usr/sbin
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build; }#[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "/bin/cat" ]; then
    touch DONE
    rm -v ../acl/DONE
fi