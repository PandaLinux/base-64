#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="file"
PKG_VERSION="5.19"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

function help() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "Description: The File package contains a utility for determining the type of a given file or files."
    echo -e ""
    echo -e "Installation of file:"
    echo -e "One method that file uses for identifying a given file is to run “magic tests”, where it compares"
    echo -e "the file's contents to data in “magic files”, which contain information about a number of standard"
    echo -e "file formats. When File is compiled, it will run file -C to combine the information from the magic"
    echo -e "files in its source tree into a single magic.mgc file, which it will use after it is installed. When"
    echo -e "we build File in while constructing a temp system, it will be cross-compiled, so it will not be able"
    echo -e "to run the file program that it just built, which means that we need one that will run on the host system."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv "../../sources/$TARBALL" "$TARBALL"
}

function unpack() {
    tar xf "${TARBALL}"
}

function build() {
    ./configure --prefix="${HOST_CROSS_TOOLS_DIR}" --disable-static
    make "${MAKE_PARALLEL}"
}

function test() {
    echo ""
}

function instal() {
    make "${MAKE_PARALLEL}" install
}

function clean() {
    rm -rf "${SRC_DIR}" "${TARBALL}"
}

# Run the installation procedure
time { help;clean;prepare;unpack;pushd "${SRC_DIR}";build;[[ "${MAKE_TESTS}" = TRUE ]] && test;instal;popd;clean; }
# Verify installation
if [ -f "${HOST_CROSS_TOOLS_DIR}/bin/file" ]; then
    touch DONE
fi