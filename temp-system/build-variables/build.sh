#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

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

echo -e "\nThere is a bug in the installer."
echo -e "You need to restart the installation as a workaround until we can come up with something better.\n"

read -p "Restart? [Y/n]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "\nRun the following command to set the environment:"
    echo -e "source ~/.bashrc\n"
    echo -e "Restart the installer only after setting the environment manually!!\n"
    exit 0
else
    touch ${DONE_DIR_TEMP_SYSTEM}/$(basename $(pwd))
fi