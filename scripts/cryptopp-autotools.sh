#!/bin/bash

set -e

cd src/cryptopp

sed -i 's/TestVectors\/ocb.txt//g' Makefile.am

autoupdate
libtoolize --force --install
autoreconf --force --install

CPPFLAGS="-DNDEBUG" CXXFLAGS="-g0 -O3" LDFLAGS="-s" ./configure --prefix=$BUILDDIR/cryptopp --host=$TARGET --enable-shared=no --enable-static
mkdir -p $BUILDDIR/cryptopp/lib
ln -snf lib $BUILDDIR/cryptopp/lib64
make -j$(nproc)
make install
make clean
