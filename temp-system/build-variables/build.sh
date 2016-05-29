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

}

# Run the installation procedure
time { build; }
# There is no need for verification
touch DONE