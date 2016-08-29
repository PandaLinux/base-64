#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="clfs-network-scripts"
PKG_VERSION="20140224"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
    # Hostname
    echo "panda" > /etc/hostname

    cat > /etc/hosts << "EOF"
# Begin /etc/hosts (no network card version)

127.0.0.1 localhost
127.0.0.1 panda

# End /etc/hosts (no network card version)
EOF

    cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 8.8.8.8
nameserver 8.8.4.4

# End /etc/resolv.conf
EOF

}

function instal() {
    make install
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /sbin/ifup ]; then
    touch ${DONE_DIR_CONFIGURE_SYSTEM}/$(basename $(pwd))
fi