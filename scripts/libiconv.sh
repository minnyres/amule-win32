#!/bin/bash

set -e

cd src
tar -xf libiconv-1.16.tar.gz
cd libiconv-1.16
./configure --host=$TARGET --prefix=$BUILDDIR/libiconv --enable-static=yes --enable-shared=no
mkdir -p $BUILDDIR/libiconv/lib
ln -s lib $BUILDDIR/libiconv/lib64
make -j$(nproc)
make install
cd ..
rm -rf libiconv-1.16
