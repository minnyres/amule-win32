#!/usr/bin/bash

set -e

export BUILDDIR=$PWD/build-$TARGET

cd src
mkdir cryptopp
cd cryptopp
7z x ../cryptopp860.zip

tar -xf ../cryptopp-autotools-CRYPTOPP_8_6_0.tar.gz
cp  cryptopp-autotools-CRYPTOPP_8_6_0/* .
mkdir -p "$PWD/m4/"

sed -i 's/TestVectors\/ocb.txt//g' Makefile.am

autoupdate
libtoolize --force --install
autoreconf --force --install

CPPFLAGS="-DNDEBUG" CXXFLAGS="-g2 -O3" ./configure --prefix=$BUILDDIR/cryptopp --host=$TARGET --enable-shared=no --enable-static 
make -j$(nproc) || true
make install

cd ..
rm -rf cryptopp