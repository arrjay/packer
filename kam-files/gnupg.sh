#!/bin/sh

set -e

. /root/.profile

# bleah. build gnupg and deps from source here for latest.
# note the spaces around the sha512, that is by design.
pkg_add bzip2
pkg_add gmake
pkg_add gtk+2
pkg_add libusb1
pkg_add pcsc-lite
pkg_add pcsc-tools
pkg_add ccid
# this one was a suprise...
pkg_add gcc

# enable pcscd for next time
rcctl enable pcscd

mkdir -p /usr/local/src
mkdir -p /usr/local/dist
ftp -o /usr/local/dist/npth-1.3.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/npth/npth-1.3.tar.bz2
sha512=$(sha512 /usr/local/dist/npth-1.3.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " 97b0278cc9448adb42c4a83b8e7bafeed939acaf3dd3a201a1b103df4e48f24224d4bdaeb97903ad1884914ce363cbceffe948a7c1db4f19abf87ca5964f5699" ] ; then
  echo "bad sum for npth-1.3.tar.bz2, got ${sha512}" 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/npth-1.3.tar.bz2 -C /usr/local/src
cd /usr/local/src/npth-1.3
./configure
make
make install

ftp -o /usr/local/dist/libgpg-error-1.27.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/libgpg-error/libgpg-error-1.27.tar.bz2
sha512=$(sha512 /usr/local/dist/libgpg-error-1.27.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " 51b313c1159074fdbbce84f63bd8afd84b3b58cd608714865b25bed84c1862d050708aa06ac3dab92f1906593df5121161e594c2809653b0fb2c236cae5dcc2f" ] ; then
  echo 'bad sum for libgpg-error-1.27.tar.bz2' 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/libgpg-error-1.27.tar.bz2 -C /usr/local/src
cd /usr/local/src/libgpg-error-1.27
./configure
make
gmake install

ftp -o /usr/local/dist/libksba-1.3.5.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2
sha512=$(sha512 /usr/local/dist/libksba-1.3.5.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " 60179bfd109b7b4fd8d2b30a3216540f03f5a13620d9a5b63f1f95788028708a420911619f172ba57e945a6a2fcd2ef7eaafc5585a0eb2b9652cfadf47bf39a2" ] ; then
  echo 'bad sum for libksba-1.3.5.tar.bz2' 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/libksba-1.3.5.tar.bz2 -C /usr/local/src
cd /usr/local/src/libksba-1.3.5
./configure
make
make install

ftp -o /usr/local/dist/libassuan-2.4.3.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/libassuan/libassuan-2.4.3.tar.bz2
sha512=$(sha512 /usr/local/dist/libassuan-2.4.3.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " 2b0f58682b408fc58fa0ec2980b36e54ba66701bf504cf6c98ec652af43501bc7c18573bc78c5b83260f5a3bdb0ec8f4e0662bafd9bba3fe7287e77598e8e4c1" ] ; then
  echo 'bad sum for libassuan-2.4.3.tar.bz2' 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/libassuan-2.4.3.tar.bz2 -C /usr/local/src
cd /usr/local/src/libassuan-2.4.3
patch -p1 < /tmp/libassuan-assuan-socket.c.patch
./configure
make
make install

ftp -o /usr/local/dist/libgcrypt-1.7.6.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/libgcrypt/libgcrypt-1.7.6.tar.bz2
sha512=$(sha512 /usr/local/dist/libgcrypt-1.7.6.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " fb7e20c50280f2ca715c3fc9a457f1cc22224797812f8dfa3ec756471bd0049c2cf75ffe12daa543aefe6cdcd1b90b4b9f943f148c073ad99d3a7dee42a8173f" ] ; then
  echo 'bad sum for libgcrypt-1.7.6.tar.bz2' 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/libgcrypt-1.7.6.tar.bz2 -C /usr/local/src
cd /usr/local/src/libgcrypt-1.7.6
./configure
make
make install

# gnupg wants gcc 4.6 or newer?
export CC=egcc

ftp -o /usr/local/dist/gnupg-2.1.19.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/gnupg/gnupg-2.1.19.tar.bz2
sha512=$(sha512 /usr/local/dist/gnupg-2.1.19.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " c6d0a2cb7f1f7ce851729559edab08d2356dffe00ee836fc1d71eb4c4e34b566e214a0352934d2985fb0183b9e7ecc1221422d258f3bd467e735c0a5c8a3d0ca" ] ; then
  echo 'bad sum for gnupg-2.1.19.tar.bz2' 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/gnupg-2.1.19.tar.bz2 -C /usr/local/src
cd /usr/local/src/gnupg-2.1.19
# old texinfo? dndk
./configure --disable-doc --enable-ccid-driver
make
make install

unset CC

ftp -o /usr/local/dist/gnupg-1.4.21.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/gnupg/gnupg-1.4.21.tar.bz2
sha512=$(sha512 /usr/local/dist/gnupg-1.4.21.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " 619e0fbc10310c7e55d129027e2945791fe91a0884b1d6f53acb4b2e380d1c6e71d1a516a59876182c5c70a4227d44a74ceda018c343b5291fa9a5d6de77c984" ] ; then
  echo 'bad sum for gnupg-1.4.21.tar.bz2' 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/gnupg-1.4.21.tar.bz2 -C /usr/local/src
cd /usr/local/src/gnupg-1.4.21
./configure --prefix=/usr/local/gnupg14
make
make install

printf '\nPATH=${PATH}:/usr/local/gnupg14/bin\nexport PATH\n' >> /root/.profile

ftp -o /usr/local/dist/pinentry-1.0.0.tar.bz2 ${GNUPG_MIRROR}/ftp/gcrypt/pinentry/pinentry-1.0.0.tar.bz2
sha512=$(sha512 /usr/local/dist/pinentry-1.0.0.tar.bz2 | cut -d= -f2)
set +e
if [ "${sha512}" != " f109236707c51871b5020ef807a551366461fafcfbe09bf8cda19d4b163a42cf622562b905ceb41429f1d648b3f3d27807538709da6a135b67f9888709eccd62" ] ; then
  echo 'bad sum for pinentry-1.0.0.tar.bz2' 1>&2
  exit 1
fi
set -e
tar xjf /usr/local/dist/pinentry-1.0.0.tar.bz2 -C /usr/local/src
cd /usr/local/src/pinentry-1.0.0
./configure
make
make install

pkg_add easy-rsa

printf '\nexport GNUPGHOME=/tmp/.gnupg;mkdir -p $GNUPGHOME\nchmod 0700 $GNUPGHOME\n' >> /root/.profile

# copy management scripts to /root
pkg_add bash
pkg_add fdupes
pkg_add gawk

cp /tmp/key-twincard.sh /root
cp /tmp/weighted-share.sh /root
cp /tmp/reset-yk-applet.gp /root
cp /tmp/reset-yk-applet.sh /root
