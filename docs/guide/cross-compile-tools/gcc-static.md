# GCC Static

## Description

The GCC package contains the GNU compiler collection, which includes the C and C++ compilers.

## Options Used

`--build=${HOST}`
This specifies the system on which the cross-compiler is being built.

`--with-local-prefix=${TOOLS_DIR}`
The purpose of this switch is to remove `/usr/local/include` from gcc's include search path. This is not absolutely essential, however, it helps to minimize the influence of the host system.

`--with-native-system-headers-dir=tools/include`
This switch ensures that GCC will search for the system headers in `tools/include` and that host system headers will not be searched.

`--disable-shared`
This tells GCC not to create a shared library.

`--without-headers`
Disables GCC from using the target's Libc when cross compiling.

`--with-newlib`
This causes GCC to enable the inhibit_libc flag, which prevents libgcc from building code that uses libc support.

`--disable-decimal-float`
Disables support for the C decimal floating point extension.

`--disable-lib*`
These options prevent GCC from building a number of libraries that are not needed at this time.

`--disable-threads`
This will prevent GCC from looking for the multi-thread include files, since they haven't been created for this architecture yet. GCC will be able to find the multi-thread information after the Glibc headers are created.

`--disable-target-zlib`
This tells GCC not to build the copy of Zlib in its source tree.

`--with-system-zlib`
This tells GCC to link to the system-installed zlib instead of the one in its source tree.

`--enable-languages=c`
This option ensures that only the C compiler is built.

`--enable-checking=release`
This option selects the complexity of the internal consistency checks and adds error checking within the compiler.

`all-gcc all-target-libgcc`
 Compiles only the parts of GCC that are needed at this time, rather than the full package.

## Patch

1. The branch update patch contains a number of updates to the 4.8.3 branch by the GCC developers

2. Pure64 specs patch make a couple of essential adjustments to GCC's specs to ensure GCC uses our build environment.