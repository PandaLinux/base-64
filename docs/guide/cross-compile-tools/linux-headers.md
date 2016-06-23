# Linux Headers

## Description

The Linux Kernel contains a make target that installs `sanitized` kernel headers.

## Options Used

`make mrproper`
Ensures that the kernel source directory is clean.

`make ARCH=x86_64 headers_check`
Sanitizes the raw kernel headers so that they can be used by userspace programs.

`make ARCH=x86_64 INSTALL_HDR_PATH=${TOOLS_DIR} headers_install`
This will install the kernel headers into `${TOOLS_DIR}/include`.