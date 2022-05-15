#!/bin/bash

set -e

cd src/libiconv-1.16
mkdir build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/libiconv --enable-static=yes --enable-shared=no
mkdir -p $BUILDDIR/libiconv/lib
ln -s lib $BUILDDIR/libiconv/lib64
make -j$(nproc)
make install
make clean
