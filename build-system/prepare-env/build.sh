#!/usr/bin/env bash


shopt -s -o pipefail
set -e 		# Exit on error

function build() {
    # Create necessary directories
    mkdir -pv /{bin,boot,dev,{etc/,}opt,home,lib,mnt}
    mkdir -pv /{proc,media/{floppy,cdrom},run/shm,sbin,srv,sys}
    mkdir -pv /var/{lock,log,mail,spool}
    mkdir -pv /var/{opt,cache,lib/{misc,locate},local}
    install -dv -m 0750 /root
    install -dv -m 1777 {/var,}/tmp
    ln -sv ../run /var/run
    mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
    mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
    mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -pv /usr/{,local/}share/man/man{1..8}

    # Creating Essential Symlinks
    ln -sv ${HOST_TDIR}/bin/{bash,cat,echo,grep,pwd,stty} /bin
    ln -sv ${HOST_TDIR}/bin/file /usr/bin
    ln -sv ${HOST_TDIR}/lib/libgcc_s.so{,.1} /usr/lib
    ln -sv ${HOST_TDIR}/lib/libstdc++.so{.6,} /usr/lib
    sed -e "s${HOST_TDIR}/usr/" "${HOST_TDIR}/lib/libstdc++.la" > /usr/lib/libstdc++.la
    ln -sv bash /bin/sh

    mkdir -pv /usr/lib64
    ln -sv ${HOST_TDIR}/lib/libstdc++.so{.6,} /usr/lib64
    ln -sv /proc/self/mounts /etc/mtab

    # Creating the passwd and group Files
    cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:/bin:/bin/false
daemon:x:2:6:/sbin:/bin/false
messagebus:x:27:27:D-Bus Message Daemon User:/dev/null:/bin/false
nobody:x:65534:65533:Unprivileged User:/dev/null:/bin/false
EOF

    cat > /etc/group << "EOF"
root:x:0:
bin:x:1:
sys:x:2:
kmem:x:3:
tty:x:5:
tape:x:4:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:27:
systemd-journal:x:28:
mail:x:30:
wheel:x:39:
nogroup:x:65533:
EOF
}

# Run the installation procedure
time { build; }
# Verify installation
if [ -f /bin/sh ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi