#!/bin/bash

set -e

cd src/gettext-0.21
mkdir build-$TARGET
cd build-$TARGET
../configure CPPFLAGS="-I$BUILDDIR/libiconv/include" LDFLAGS="-L$BUILDDIR/libiconv/lib" \
    --host=$TARGET --prefix=$BUILDDIR/gettext --with-libiconv-prefix=$BUILDDIR/libiconv \
    --enable-shared=no --enable-static=yes --enable-threads=posix
mkdir -p $BUILDDIR/gettext/lib
ln -s lib $BUILDDIR/gettext/lib64
make -j$(nproc)
make install
make clean