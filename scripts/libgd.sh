#!/bin/bash

set -e

if [ "$USE_LLVM" == "yes" ]; then
    cppflags="-Wno-error=deprecated-non-prototype"
fi

cd src/libgd
patch -p1 <../../patches/libgd-fix-static-use.patch
./bootstrap.sh
mkdir -p build-$TARGET
cd build-$TARGET
../configure CPPFLAGS="$CPPFLAGS $cppflags" \
    --host=$TARGET --prefix=$BUILDDIR/libgd  \
    --with-zlib=$BUILDDIR/zlib --with-png=$BUILDDIR/libpng \
    --enable-shared=no --enable-static
mkdir -p $BUILDDIR/libgd/lib
ln -snf lib $BUILDDIR/libgd/lib64
make -j$(nproc)
make install
make clean