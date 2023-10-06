#!/bin/bash

set -e

cd src/libiconv
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/libiconv --enable-static=yes --enable-shared=no
mkdir -p $BUILDDIR/libiconv/lib
ln -snf lib $BUILDDIR/libiconv/lib64
make -j$(nproc)
make install
make clean
