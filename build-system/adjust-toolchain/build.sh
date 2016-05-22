#!/usr/bin/env bash

set +h		# disable hashall
shopt -s -o pipefail
set -e 		# Exit on error

function build() {
    # Adjust GCC's specs so that they point to the new dynamic linker
    gcc -dumpspecs | \
    perl -p -e "s@${HOST_TOOLS_DIR}/lib/ld@/lib/ld@g;" \
         -e "s@\*startfile_prefix_spec:\n@$_/usr/lib/ @g;" > \
         $(dirname $(gcc --print-libgcc-file-name))/specs
}

# Run the installation procedure
time { build; }
# Verify installation
echo 'main(){}' > dummy.c
gcc dummy.c

if [ $(readelf -l a.out | grep ': /lib') ]; then
    touch DONE
fi