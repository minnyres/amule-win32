#!/bin/bash

set -e

cd src/libpng
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/libpng --with-zlib-prefix=$BUILDDIR/zlib --enable-shared=no
mkdir -p $BUILDDIR/libpng/lib
ln -snf lib $BUILDDIR/libpng/lib64
make -j$(nproc)
make install
sed -i 's/libs="-lpng16"/libs="-lpng16 -lz"/g' $BUILDDIR/libpng/bin/libpng-config
make clean
