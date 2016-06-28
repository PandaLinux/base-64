#!/usr/bin/env bash

shopt -s -o pipefail
set -e

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: Linux Standards Base (LSB)"
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function build() {
    cat > /etc/os-release << "EOF"
NAME="Panda"
VERSION="0.1.5"
ID=panda
ID_LIKE=debian
PRETTY_NAME="Panda Linux"
VERSION_ID="0.1.5"
HOME_URL="https://github.com/PandaLinux/base-64"
BUG_REPORT_URL="https://github.com/PandaLinux/base-64/issues"
EOF

    cat > /etc/lsb-release << "EOF"
DISTRIB_ID=Panda
DISTRIB_RELEASE=0.1.5
DISTRIB_CODENAME=black
DISTRIB_DESCRIPTION="Panda Linux"
EOF
}

# Run the installation procedure
time { showHelp;build; }
# Verify installation
if [ -f /etc/lsb-release ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi