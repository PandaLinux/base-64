# GCC Final

## Description

The GCC package contains the GNU compiler collection, which includes the C and C++ compilers.

## Options Used

`--enable-languages=c,c++`
This option ensures that only the C and C++ compilers are built.

`--enable-__cxa_atexit`
This option allows use of __cxa_atexit, rather than atexit, to register C++ destructors for local statics and global objects and is essential for fully standards-compliant handling of destructors. It also affects the C++ ABI and therefore results in C++ shared libraries and C++ programs that are interoperable with other Linux distributions.

`--enable-threads=posix`
This enables C++ exception handling for multi-threaded code.

`--enable-libstdcxx-time`
This enables link-time checks for the availability of clock_gettime clocks, and nanosleep and sched_yield functions, in the C library.