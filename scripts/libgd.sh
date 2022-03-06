#!/usr/bin/bash

set -e

export BUILDDIR=$PWD/build-$TARGET
cd src
tar -xf libgd-2.3.3.tar.xz
cd libgd-2.3.3
./configure --host=$TARGET --prefix=$BUILDDIR/libgd --enable-static=yes --enable-shared=no --with-zlib=$BUILDDIR/zlib --with-libiconv-prefix=$BUILDDIR/libiconv --with-png=$BUILDDIR/libpng
make -j$(nproc) && make install
cd ..
rm -rf libgd-2.3.3
