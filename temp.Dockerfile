FROM alpine:3.9

MAINTAINER Abhimanyu Saharan <desk.abhimanyu@gmail.com>

ENV TERM=xterm \
    SRC="/src" \
    INSTALL_DIR="/tmp/panda64" \
    TEMP_SYSTEM_DIR="/tmp/panda64/temp-system" \
    BUILD_SYSTEM_DIR="/tmp/panda64/build-system" \
    CONFIGURE_SYSTEM_DIR="/tmp/panda64/configure-system" \
    FINALIZE_SYSTEM_DIR="/tmp/panda64/finalize-system" \
    TARGET="x86_64-panda-linux-gnu" \
    PATH="/tools/bin:$PATH" \
    FORCE_UNSAFE_CONFIGURE=1 \
    MAKE_TESTS=TRUE \
    MAKE_PARALLEL=-j8

RUN apk add --no-cache --virtual .deps \
    bash binutils bison bzip2 \
    coreutils curl \
    diffutils \
    file findutils \
    gawk gcc g++ grep gzip \
    make \
    ncurses \
    patch python3 \
    sed \
    tar texinfo \
    wget \
    xterm xz

ADD rootfs $SRC

WORKDIR $SRC
RUN /bin/bash install.sh temp-system