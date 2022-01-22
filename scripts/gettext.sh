#!/usr/bin/bash

set -e

export BUILDDIR=$PWD/build-$TARGET

cd src
tar -xf gettext-0.21.tar.xz
cd gettext-0.21
./configure CPPFLAGS="-I$BUILDDIR/libiconv/include"  LDFLAGS="-L$BUILDDIR/libiconv/lib" \
    --host=$TARGET --prefix=$BUILDDIR/gettext --with-libiconv-prefix=$BUILDDIR/libiconv \
    --enable-shared=no --enable-static=yes --enable-threads=posix
mkdir -p $BUILDDIR/gettext/lib
ln -s lib $BUILDDIR/gettext/lib64
make -j$(nproc) && make install
cd ..
rm -rf gettext-0.21