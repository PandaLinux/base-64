#!/usr/bin/env bash

shopt -s -o pipefail
set -e

PKG_NAME="busybox"
PKG_VERSION="1.20.2"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.bz2"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH="${PKG_NAME}-${PKG_VERSION}-sys-resource.patch"

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: BusyBox combines tiny versions of many common UNIX utilities into a single small executable."
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

	# Set default configuration
    make ${MAKE_PARALLEL} ARCH=x86_64 defconfig

    sed 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/'                         -i .config
    sed 's/CONFIG_FEATURE_HAVE_RPC=y/# CONFIG_FEATURE_HAVE_RPC is not set/'     -i .config
    sed 's/CONFIG_FEATURE_MOUNT_NFS=y/# CONFIG_FEATURE_MOUNT_NFS is not set/'   -i .config
	sed 's/CONFIG_FEATURE_INETD_RPC=y/# CONFIG_FEATURE_INETD_RPC is not set/'   -i .config

	make ${MAKE_PARALLEL}
}

function instal() {
	cp -v busybox /bin
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;popd;clean; }
# Verify installation
if [ -f /bin/busybox ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi