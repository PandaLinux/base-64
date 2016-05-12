#!/usr/bin/env bash

source variables.sh

# Simple script to list version numbers of critical development tools
bash --version | head -n1 | cut -d" " -f2-4
echo -n "${BOLD}Binutils:${NORM} "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "${BOLD}Coreutils:${NORM} "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
gcc --version | head -n1
g++ --version | head -n1
ldd $(which ${SHELL}) | grep libc.so | cut -d ' ' -f 3 | ${SHELL} | head -n 1 | cut -d ' ' -f 1-7
grep --version | head -n1
gzip --version | head -n1
make --version | head -n1
tic -V
patch --version | head -n1
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1
xz --version | head -n1
echo 'main(){}' | gcc -v -o /dev/null -x c - > dummy.log 2>&1
if ! grep -q ' error' dummy.log; then
  echo "${REV}Compilation successful${NORM}" && rm dummy.log
else
  echo 1>&2  "${REV}Compilation FAILED - more development packages may need to be \
installed. If you like, you can also view dummy.log for more details.${NORM}"
fi