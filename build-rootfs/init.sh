#!/usr/bin/env bash

shopt -s -o pipefail
set -e # Exit on error

echo warn "Constructing root filesystem..."

_list=(bash)

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
