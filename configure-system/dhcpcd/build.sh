#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="dhcpcd"
PKG_VERSION="6.3.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The DHCPCD package provides a DHCP Client for network configuration."
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
    ./configure --prefix=/usr           \
                --sbindir=/sbin         \
                --sysconfdir=/etc       \
                --dbdir=/var/lib/dhcpcd \
                --libexecdir=/usr/lib/dhcpcd

    make ${MAKE_PARALLEL}
}

function instal() {
    make ${MAKE_PARALLEL} install
}

function configure() {
cat > /etc/dhcpcd.conf << "EOF"
# dhcpcd configuration eth0 interface
# See dhcpcd.conf(5) for details.

interface eth0
# dhcpcd-run-hooks uses these options.
option subnet_mask, routers, domain_name_servers

# The default timeout for waiting for a DHCP response is 30 seconds
# which may be too long or too short and can be changed here.
timeout 16
EOF

    # Network Interface configuration at boot
    systemctl enable dhcpcd@eth0
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /usr/lib/libacl.so ]; then
    touch ${DONE_DIR_CONFIGURE_SYSTEM}/$(basename $(pwd))
fi