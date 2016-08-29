#!/usr/bin/env bash

shopt -s -o pipefail
set -e 		# Exit on error

PKG_NAME="openssl"
PKG_VERSION="1.0.1e"

TARBALL="${PKG_NAME}-${PKG_VERSION}.tar.gz"
SRC_DIR="${PKG_NAME}-${PKG_VERSION}"

PATCH1=${PKG_NAME}-${PKG_VERSION}-fix_manpages-1.patch
PATCH2=${PKG_NAME}-${PKG_VERSION}-fix_parallel_build-1.patch

function showHelp() {
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e "The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured, and Open"
    echo -e "Source toolkit implementing the Secure Sockets Layer (SSL v2/v3) and Transport Layer Security (TLS v1)"
    echo -e "protocols as well as a full-strength general purpose cryptography library."
    echo -e "--------------------------------------------------------------------------------------------------------------"
    echo -e ""
}

function prepare() {
    ln -sv /sources/${TARBALL} ${TARBALL}
    ln -sv /patches/${PATCH1} ${PATCH1}
    ln -sv /patches/${PATCH2} ${PATCH2}
}

function unpack() {
    tar xf ${TARBALL}
}

function build() {
	patch -Np1 -i ../${PATCH1}
	patch -Np1 -i ../${PATCH2}

	./Configure linux-x86_64            \
	            --openssldir=/etc/ssl   \
			    --prefix=/usr shared
	USE_ARCH=64 make CC="gcc ${BUILD64}" PERL=/usr/bin/perl LIBDIR=lib
}

function instal() {
	USE_ARCH=64 make PERL=/usr/bin/perl MANDIR=/usr/share/man LIBDIR=lib install_sw
	ln -sv ../../etc/ssl /usr/share &&
	cp -rv certs /etc/ssl
}

function configure() {
	cat > mkcabundle.pl << "EOF"
#!/usr/bin/perl -w
#
# Used to regenerate ca-bundle.crt from the Mozilla certdata.txt.
# Run as ./mkcabundle.pl > ca-bundle.crt
#

my $cvsroot = ':pserver:anonymous@cvs-mirror.mozilla.org:/cvsroot';
my $certdata = 'mozilla/security/nss/lib/ckfw/builtins/certdata.txt';

open(IN, "cvs -d $cvsroot co -p $certdata|")
    || die "could not check out certdata.txt";

my $incert = 0;

print<<EOH;
# This is a bundle of X.509 certificates of public Certificate
# Authorities.  It was generated from the Mozilla root CA list.
#
# Source: $certdata
#
EOH

while (<IN>) {
    if (/^CKA_VALUE MULTILINE_OCTAL/) {
        $incert = 1;
        open(OUT, "|openssl x509 -text -inform DER -fingerprint")
            || die "could not pipe to openssl x509";
    } elsif (/^END/ && $incert) {
        close(OUT);
        $incert = 0;
        print "\n\n";
    } elsif ($incert) {
        my @bs = split(/\\/);
        foreach my $b (@bs) {
            chomp $b;
            printf(OUT "%c", oct($b)) unless $b eq '';
        }
    } elsif (/^CVS_ID.*Revision: ([^ ]*).*/) {
        print "# Generated from certdata.txt RCS revision $1\n#\n";
    }
}
EOF

	chmod +x mkcabundle.pl
	./mkcabundle.pl > ca-bundle.crt &&
	install -Dv -m644 ca-bundle.crt /etc/ssl/certs
}

function clean() {
    rm -rf ${SRC_DIR} ${TARBALL} ${PATCH1} ${PATCH2}
}

# Run the installation procedure
time { showHelp;clean;prepare;unpack;pushd ${SRC_DIR};build;instal;configure;popd;clean; }
# Verify installation
if [ -f /usr/bin/openssl ]; then
    touch ${DONE_DIR_FINALIZE_SYSTEM}/$(basename $(pwd))
fi