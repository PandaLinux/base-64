FROM alpine:3.9 as BASE

MAINTAINER Abhimanyu Saharan <desk.abhimanyu@gmail.com>

ENV TERM=xterm
ENV SRC="/src"
ENV INSTALL_DIR="/tmp/panda64"
ENV LOGS_DIR="/tmp/panda64/logs"
ENV DONE_DIR="/tmp/panda64/done"
ENV TEMP_SYSTEM_DIR="/tmp/panda64/temp-system"
ENV BUILD_SYSTEM_DIR="/tmp/panda64/build-system"
ENV CONFIGURE_SYSTEM_DIR="/tmp/panda64/configure-system"
ENV FINALIZE_SYSTEM_DIR="/tmp/panda64/finalize-system"
ENV TARGET="x86_64-panda-linux-gnu"
ENV PATH="/tools/bin:$PATH"
ENV BUILD64="-m64"
ENV LC_ALL="POSIX"
ENV VM_LINUZ="vmlinuz-5.2.8-systemd"
ENV SYSTEM_MAP="System.map-5.2.8"
ENV MAKE_TESTS=TRUE
ENV MAKE_PARALLEL=-j8
ENV DO_BACKUP=FALSE
ENV WGET_OPTIONS="--tries=3 --continue --progress=dot:giga"

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



FROM BASE
ADD . $SRC

WORKDIR $SRC
RUN /bin/bash install.sh