#!/bin/bash

set -e

cd src
mkdir cryptopp
cd cryptopp
7z x ../cryptopp860.zip

tar -xf ../cryptopp-autotools-CRYPTOPP_8_6_0.tar.gz
cp cryptopp-autotools-CRYPTOPP_8_6_0/* .
mkdir -p "$PWD/m4/"

sed -i 's/TestVectors\/ocb.txt//g' Makefile.am

autoupdate
libtoolize --force --install
autoreconf --force --install

CPPFLAGS="-DNDEBUG" CXXFLAGS="-g0 -O3" LDFLAGS="-s" ./configure --prefix=$BUILDDIR/cryptopp --host=$TARGET --enable-shared=no --enable-static
mkdir -p $BUILDDIR/cryptopp/lib
ln -s lib $BUILDDIR/cryptopp/lib64
make -j$(nproc)
make install

cd ..
rm -rf cryptopp
