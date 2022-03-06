#!/usr/bin/bash

set -e

export BUILDDIR=$PWD/build-$TARGET
cd src
tar -xf libgd-2.3.3.tar.xz
cd libgd-2.3.3
cmake -DBUILD_TEST=0 -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_PNG=1 -DENABLE_ICONV=1 -DCMAKE_INSTALL_PREFIX=$BUILDDIR/libgd \
    -DCMAKE_LIBRARY_PATH="$BUILDDIR/zlib/lib;$BUILDDIR/libiconv/lib;$BUILDDIR/libpng/lib" \
    -DCMAKE_INCLUDE_PATH="$BUILDDIR/zlib/include;$BUILDDIR/libiconv/include;$BUILDDIR/libpng/include" \
    -DCMAKE_SYSTEM_NAME=Windows -DCMAKE_C_COMPILER=$TARGET-gcc -DCMAKE_CXX_COMPILER=$TARGET-g++ \
    -DBUILD_SHARED_LIBS=1 -DBUILD_STATIC_LIBS=0 .
make -j$(nproc) && make install 
cd ..
rm -rf libgd-2.3.3
$TARGET-strip $BUILDDIR/libgd/bin/libgd.dll