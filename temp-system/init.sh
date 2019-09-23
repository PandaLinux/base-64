#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

source "$SRC"/variables.sh

echo warn "Constructing temporary system..."

_list=(binutils_pass1 gcc_pass1 linux_headers glibc libstdc++ binutils_pass2 gcc_pass2 tcl expect dejagnu m4 ncurses
  bash bison bzip2 coreutils diffutils file findutils gawk gettext grep gzip make patch perl python3 sed tar texinfo xz)

for i in "${_list[@]}"; do
  case $i in
  *)
    pushd "${i}"
    echo empty
    echo warn "Building ---> ${i}"
    bash build.sh
    echo success "Finished ---> ${i}"
    popd
    ;;
  esac
done
echo empty

set +e

echo warn "Stripping"
strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
find /tools/{lib,libexec} -name \*.la -delete
