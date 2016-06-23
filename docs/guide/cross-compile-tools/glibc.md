# Glibc

## Description

The Glibc package contains the main C library. This library provides the basic routines for allocating memory, searching directories, opening and closing files, reading and writing files, string handling, pattern matching, arithmetic, and so on.

## Options Used

`BUILD_CC="gcc"`
This sets Glibc to use the current compiler on our system. This is used to create the tools Glibc uses during its build.

`CC="${TARGET}-gcc ${BUILD64}"`
Forces Glibc to build using our target architecture GCC utilizing the 64 Bit flags.

`AR="${TARGET}-ar"`
This forces Glibc to use the ar utility we made for our target architecture.

`RANLIB="${TARGET}-ranlib"`
This forces Glibc to use the ranlib utility we made for our target architecture.

`--disable-profile`
This builds the libraries without profiling information. Omit this option if profiling on the temporary tools is necessary.

`--enable-kernel=2.6.32`
This tells Glibc to compile the library with support for 2.6.32 and later Linux kernels.

`--with-binutils=${CROSS_DIR}/bin`
This tells Glibc to use the Binutils that are specific to our target architecture.

`--with-headers=${TOOLS_DIR}/include`
This tells Glibc to compile itself against the headers recently installed to the `${TOOLS_DIR}` directory, so that it knows exactly what features the kernel has and can optimize itself accordingly.

`--enable-obsolete-rpc`
This tells Glibc to install rpc headers that are not installed by default but may be needed by other packages.

`--cache-file=config.cache`
This tells Glibc to utilize a premade cache file.