#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail

PKG_NAME="linux"
PKG_VERSION="3.14"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.xz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: Linux Standards Base (LSB)"
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function build() {
    cat > /etc/os-release << "EOF"
NAME="Panda"
VERSION="0.1.0"
ID=panda
ID_LIKE=debian
PRETTY_NAME="Panda Linux"
VERSION_ID="0.1.0"
HOME_URL="https://github.com/PandaLinux/base-64"
BUG_REPORT_URL="https://github.com/PandaLinux/base-64/issues"
EOF

    cat > /etc/lsb-release << "EOF"
DISTRIB_ID=Panda
DISTRIB_RELEASE=0.1.0
DISTRIB_CODENAME=black
DISTRIB_DESCRIPTION="Panda Linux"
EOF
}

# Run the installation procedure
time { help;build; }
# Verify installation
if [ -f "/etc/lsb-release" ]; then
    touch DONE
fi