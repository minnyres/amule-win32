#!/bin/bash

set -e

cd src/wxWidgets
git apply ../../patches/wx-fix-arm32-support.patch
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/wxwidgets --with-zlib=sys --with-libpng=sys --with-msw --with-libiconv-prefix=$BUILDDIR/libiconv \
    --disable-shared --disable-debug_flag --disable-mediactrl --enable-optimise --enable-unicode
mkdir -p $BUILDDIR/wxwidgets/lib
ln -snf lib $BUILDDIR/wxwidgets/lib64
make -j$(nproc)
make install
make clean

cd ..
git restore .
git clean -f

cd $BUILDDIR/wxwidgets/lib

for file in *.a; do
    newfile="${file//"-$TARGET"/""}"
    ln -snf $file $newfile
done
