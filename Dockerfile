#FROM bash:5.0.17 as BASH
#FROM nolze/binutils-all as BINUTILS

FROM scratch as BASE
MAINTAINER Abhiamanyu Saharan <desk.abhimanyu@gmail.com>
LABEL version="1.0"
LABEL description="Automated temporary system build"

# Add minimal root filesystem
#ADD rootfs-1.0.0-x86_64.tar.xz /
#
## Copy missing utilities
#COPY --from=BASH /usr/local/bin/bash /usr/local/bin/bash
#COPY --from=BINUTILS /usr/local /usr/local
#
#CMD ["ls","/bin/make"]