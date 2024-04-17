#!/bin/bash

set -e

cd src/gettext
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/gettext --with-libiconv-prefix=$BUILDDIR/libiconv \
    --enable-shared=no --enable-static=yes --enable-threads=posix
mkdir -p $BUILDDIR/gettext/lib
ln -snf lib $BUILDDIR/gettext/lib64
make -j$(nproc)
make install
make clean