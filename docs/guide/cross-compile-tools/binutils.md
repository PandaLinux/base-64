# Binutils

## Description

The Binutils package contains a linker, an assembler, and other tools for handling object files.

## Options Used

`AR=ar AS=as`
This prevents Binutils from compiling with `${HOST}-ar` and `${HOST}-as` as they are provided by this package and therefore not installed yet.

`--host=${HOST}`
When used with `--target`, this creates a cross-architecture executable that creates files for `${TARGET}` but runs on `${HOST}`.

`--target=${TARGET}`
When used with `--host`, this creates a cross-architecture executable that creates files for `${TARGET}` but runs on `${HOST}`.

`--with-sysroot=${INSTALL_DIR}`
Tells configure to build a linker that uses `${INSTALL_DIR}` as its root directory for its search paths.

`--with-lib-path=${TOOLS_DIR}/lib`
This tells the configure script to specify the library search path during the compilation of Binutils, resulting in `${TOOLS_DIR}/lib` being passed to the linker. This prevents the linker from searching through library directories on the host.

`--disable-nls`
This disables internationalization as i18n is not needed for the cross-compile tools.

`--disable-multilib`
This option disables the building of a multilib capable Binutils.

`--enable-64-bit-bfd`
This adds 64 bit support to Binutils.

`--disable-werror`
This prevents the build from stopping in the event that there are warnings from the host's compiler.