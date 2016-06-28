#!/usr/bin/env bash

source variables.sh
source functions.sh

#-----------------------------------------------------------------------------------------------------------------------
#                               M I N I M U M   H O S T   R E Q U I R E M E N T S
#-----------------------------------------------------------------------------------------------------------------------
BASH_MIN_REQ="2.05"
BINUTILS_MIN_REQ="2.12"
BISON_MIN_REQ="1.875"
BZIP2_MIN_REQ="1.0.2"
COREUTILS_MIN_REQ="5.0"
DIFFUTILS_MIN_REQ="2.8"
FINDUTILS_MIN_REQ="4.1.20"
GAWK_MIN_REQ="3.1.5"
GCC_MIN_REQ="4.1.2"
GCC_MAX_REQ="5.3.0"
GLIBC_MIN_REQ="2.2.5"
GLIBC_MAX_REQ="2.22"
GREP_MIN_REQ="2.5"
GZIP_MIN_REQ="1.2.4"
MAKE_MIN_REQ="3.80"
NCURSES_MIN_REQ="5.3"
PATCH_MIN_REQ="2.5.4"
SED_MIN_REQ="3.0.2"
TAR_MIN_REQ="1.22"
TEXINFO_MIN_REQ="4.7"
XZ_MIN_REQ="4.999.8"

#-----------------------------------------------------------------------------------------------------------------------
#                                     C U R R E N T   V E R S I O N S
#-----------------------------------------------------------------------------------------------------------------------
BASH_CURR=$(bash --version | head -n1 | cut -d"(" -f1 | cut -d" " -f4)
BINUTILS_CURR=$(ld --version | head -n1 | cut -d" " -f7)
BISON_CURR=$(bison --version | head -n1 | cut -d" " -f4)
BZIP2_CURR=$(bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f8 | cut -d"," -f1)
COREUTILS_CURR=$(chown --version | head -n1 | cut -d" " -f4)
DIFFUTILS_CURR=$(diff --version | head -n1 | cut -d" " -f4)
FINDUTILS_CURR=$(find --version | head -n1 | cut -d" " -f4)
GAWK_CURR=$(gawk --version | head -n1 | cut -d" " -f3)
GCC_CURR=$(gcc --version | head -n1 | cut -d" " -f4)
GLIBC_CURR=$(ldd $(which ${SHELL}) | grep libc.so | cut -d ' ' -f 3 | ${SHELL} | head -n 1 | cut -d ' ' -f 1-7 | cut -d" " -f6 | cut -d"-" -f1)
GREP_CURR=$(grep --version | head -n1 | cut -d" " -f4)
GZIP_CURR=$(gzip --version | head -n1 | cut -d" " -f2)
MAKE_CURR=$(make --version | head -n1 | cut -d" " -f3)
NCURSES_CURR=$(tic -V | cut -d" " -f2)
PATCH_CURR=$(patch --version | head -n1 | cut -d" " -f3)
SED_CURR=$(sed --version | head -n1 | cut -d" " -f4)
TAR_CURR=$(tar --version | head -n1 | cut -d" " -f4)
TEXINFO_CURR=$(makeinfo --version | head -n1 | cut -d" " -f4)
XZ_CURR=$(xz --version | head -n1 | cut -d" " -f4)

#-----------------------------------------------------------------------------------------------------------------------
#                                       V E R I F Y   R E Q U I R E M E N T S
#-----------------------------------------------------------------------------------------------------------------------

_list_min=(BASH BINUTILS BISON BZIP2 COREUTILS DIFFUTILS FINDUTILS GAWK GCC GLIBC GREP GZIP MAKE NCURSES PATCH SED TAR \
       TEXINFO XZ)

# Checks for minimum requirements
for progs in ${_list_min[@]}; do
    min="${progs}_MIN_REQ"
    cur="${progs}_CURR"

    if [ "$(printf "${!min}\n${!cur}" | sort -V | head -n1)" = "${!cur}" ] && [ "${!cur}" != "${!min}" ]; then
        echo error "$progs Found: v${!cur}, Required: v${!min}"
        exit 1
    fi
done

_list_max=(GCC GLIBC)
# Checks for maximum recommended requirements
for progs in ${_list_max[@]}; do
    max="${progs}_MAX_REQ"
    cur="${progs}_CURR"

    if [ "$(printf "${!cur}\n${!max}" | sort -V | head -n1)" = "${!max}" ] && [ "${!cur}" != "${!max}" ]; then
        echo error "$progs Found: v${!cur}, Recommended: v${!max}"
        exit 1
    fi
done

echo norm 'int main(){}' | gcc -v -o /dev/null -x c - > dummy.log 2>&1

if ! grep -q ' error' dummy.log; then
    rm dummy.log
    echo success "Your host meets all our requirements!"
else
    echo error "Compilation FAILED. If you like, you can also view dummy.log for more details."
    exit 0
fi