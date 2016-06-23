#!/usr/bin/env bash

function build() {
    cat >> ~/.bashrc << EOF
export CC="${TARGET}-gcc ${BUILD64}"
export CXX="${TARGET}-g++ ${BUILD64}"
export AR="${TARGET}-ar"
export AS="${TARGET}-as"
export RANLIB="${TARGET}-ranlib"
export LD="${TARGET}-ld"
export STRIP="${TARGET}-strip"
EOF

    source ~/.bashrc
}

# Run the installation procedure
time { build; }

echo ""
echo "If you don't see any result for CC, please stop the installer."
echo "CC   : ${CC}"
echo ""

read -p "Continue? [Y/n]: " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Run the following command to set the environment:"
    echo "source ~/.bashrc"
    exit 0
else
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi