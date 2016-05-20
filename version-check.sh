#!/usr/bin/env bash

source variables.sh
source functions.sh

# TODO: Prettify the version check for better readability
# Simple script to list version numbers of critical development tools

echo warn "Checking system..."
echo empty
echo warn "Bash:        ${BOLD}$(bash --version | head -n1 | cut -d" " -f2-4)${NORM}"
echo warn "Binutils:    ${BOLD}$(ld --version | head -n1 | cut -d" " -f3-)${NORM}"
echo warn "Bison:       ${BOLD}$(bison --version | head -n1)${NORM}"
echo warn "Bzip2:       ${BOLD}$(bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-)${NORM}"
echo warn "Coreutils:   ${BOLD}$(chown --version | head -n1 | cut -d")" -f2)${NORM}"
echo warn "Diffutils:   ${BOLD}$(diff --version | head -n1)${NORM}"
echo warn "Findutils:   ${BOLD}$(find --version | head -n1)${NORM}"
echo warn "Gawk:        ${BOLD}$(gawk --version | head -n1)${NORM}"
echo warn "GCC:         ${BOLD}$(gcc --version | head -n1)${NORM}"
echo warn "G++:         ${BOLD}$(g++ --version | head -n1)${NORM}"
echo warn "Glibc:       ${BOLD}$(ldd $(which ${SHELL}) | grep libc.so | cut -d ' ' -f 3 | ${SHELL} | head -n 1 | cut -d ' ' -f 1-7)${NORM}"
echo warn "Grep:        ${BOLD}$(grep --version | head -n1)${NORM}"
echo warn "Gzip:        ${BOLD}$(gzip --version | head -n1)${NORM}"
echo warn "Make:        ${BOLD}$(make --version | head -n1)${NORM}"
echo warn "Ncurses:     ${BOLD}$(tic -V)${NORM}"
echo warn "Patch:       ${BOLD}$(patch --version | head -n1)${NORM}"
echo warn "Sed:         ${BOLD}$(sed --version | head -n1)${NORM}"
echo warn "Tar:         ${BOLD}$(tar --version | head -n1)${NORM}"
echo warn "Makeinfo:    ${BOLD}$(makeinfo --version | head -n1)${NORM}"
echo warn "Xz-utils:    ${BOLD}$(xz --version | head -n1)${NORM}"

echo norm 'int main(){}' | gcc -v -o /dev/null -x c - > dummy.log 2>&1

if ! grep -q ' error' dummy.log; then
    echo success "Compilation successful" && rm dummy.log
else
    echo error "Compilation FAILED. If you like, you can also view dummy.log for more details."
    exit 1
fi