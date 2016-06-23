# Mpfr

## Description

The MPFR library is a C library for multiple-precision floating-point computations with correct rounding.

## Options Used

`LDFLAGS="-Wl,-rpath,${CROSS_DIR}/lib"`
This tells configure to search in /cross-tools for libraries.

`--with-gmp=${CROSS_DIR}`
This tells configure where to find GMP.

## Patch

1. Upstream fixes