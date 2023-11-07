#!/bin/bash -xv

set -eo pipefail

LOOP="/dev/loop7"
ROOT="/dev/loop7p1"

VERSION="2020.9-2"
if [ "$1" != "" ]; then
    VERSION="$1"
fi

sudo umount root || true
sudo losetup -d $LOOP || true

sudo rm -fR root kiss-chroot* kiss.img
mkdir root

export http_proxy=http://192.168.1.201:8080 ; export https_proxy=$http_
proxy

wget https://github.com/kisslinux/repo/releases/download/${VERSION}/kiss-chroot-${VERSION}.tar.xz

wget https://github.com/kisslinux/repo/releases/download/${VERSION}/kiss-chroot-${VERSION}.tar.xz.sha256
sha256sum -c < kiss-chroot-${VERSION}.tar.xz.sha256

dd if=/dev/zero of=kiss.img bs=1G count=8

fdisk kiss.img <<EOF
o
n
p
1


a
w
EOF

sudo losetup -v -P $LOOP kiss.img
sudo mkfs.ext4 $ROOT
sudo mount $ROOT root

sudo tar xf kiss-chroot-${VERSION}.tar.xz -C root --strip-components 1

sudo cp stage2.sh root/

echo "Run ./stage2.sh in the chroot..."

sudo root/bin/kiss-chroot ./root

sudo umount root
sudo losetup -d $LOOP

echo "Success!"
