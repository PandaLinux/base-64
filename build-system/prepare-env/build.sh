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
adm:x:3:16:adm:/var/adm:/bin/false
lp:x:10:9:lp:/var/spool/lp:/bin/false
messagebus:x:27:27:D-Bus Message Daemon User:/dev/null:/bin/false
mail:x:30:30:mail:/var/mail:/bin/false
news:x:31:31:news:/var/spool/news:/bin/false
operator:x:50:0:operator:/root:/bin/bash
postmaster:x:51:30:postmaster:/var/spool/mail:/bin/false
systemd-bus-proxy:x:71:72:systemd Bus Proxy:/:/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
systemd-network:x:76:76:systemd Network Management:/:/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
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
console:x:17:
cdrw:x:18:
mail:x:30:
news:x:31:news
messagebus:x:27:
nogroup:x:65533:
systemd-bus-proxy:x:72:
systemd-journal:x:28:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
wheel:x:39:
users:x:1000:
nobody:x:65533:
EOF
}

# Run the installation procedure
time { build; }
# Verify installation
if [ -f /bin/sh ]; then
    touch ${DONE_DIR_BUILD_SYSTEM}/$(basename $(pwd))
fi