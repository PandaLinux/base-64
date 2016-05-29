#!/usr/bin/env bash

# Setup .bash_profile which sets up a clean environment for the installation procedure
cat > ~/.bash_profile << "EOF"
exec env -i HOME=${HOME} TERM=${TERM} PS1='\u:\w\$ ' /bin/bash
EOF

# Setup .bashrc file
cat > ~/.bashrc << "EOF"
. variables.sh

set +h
umask 022

INSTALL_DIR="${INSTALL_DIR}"
HOST_TOOLS_DIR="${HOST_TOOLS_DIR}"
HOST_CROSS_TOOLS_DIR="${HOST_CROSS_TOOLS_DIR}"
MAKE_TESTS="TRUE"
MAKE_PARALLEL="-j$(cat /proc/cpuinfo | grep processor | wc -l)"
TARGET="${TARGET}"
PATH="${TMP_PATH}"
HOST="${HOST}"
BUILD64="${BUILD64}"
LC_ALL="${LC_ALL}"
VM_LINUZ="${VM_LINUZ}"
SYSTEM_MAP="${SYSTEM_MAP}"
CONFIG_BACKUP="${CONFIG_BACKUP}"

export INSTALL_DIR HOST_TOOLS_DIR HOST_CROSS_TOOLS_DIR MAKE_TESTS MAKE_PARALLEL TARGET PATH HOST BUILD64 LC_ALL \
       VM_LINUZ SYSTEM_MAP CONFIG_BACKUP
unset CFLAGS CXXFLAGS
EOF

# To have the environment fully prepared for building the temporary tools,
# source the just-created user profile
source ~/.bash_profile