#!/usr/bin/bash

set -e

cd src
tar -xf libpng-1.6.37.tar.xz
cd libpng-1.6.37
./configure CPPFLAGS="-I$BUILDDIR/zlib/include" LDFLAGS="-L$BUILDDIR/zlib/lib" \
    --host=$TARGET --prefix=$BUILDDIR/libpng --with-zlib-prefix=$BUILDDIR/zlib --enable-shared=no
mkdir -p $BUILDDIR/libpng/lib
ln -s lib $BUILDDIR/libpng/lib64
make
make install
sed -i 's/libs="-lpng16"/libs="-lpng16 -lz"/g' $BUILDDIR/libpng/bin/libpng-config
cd ..
rm -rf libpng-1.6.37
