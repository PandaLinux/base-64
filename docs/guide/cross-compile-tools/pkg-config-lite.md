# Pkg Config Lite

## Description

Pkg-config-lite is a tool to help you insert the correct compiler options on the command line when compiling applications and libraries.

## Options Used

`--host=${TARGET}`
Several packages that we will cross-compile later will try to search for `${TARGET}-pkg-config`. Setting this option ensures that Pkg-config-lite will create a hard link in `${CROSS_DIR}/bin` with this name, so that it will be used instead of any similarly-named program that might exist on the host.

`--with-pc-path`
This sets the default PKG_CONFIG_PATH to `${TOOLS_DIR}/lib/pkgconfig` and `${TOOLS}/share/pkgconfig`.