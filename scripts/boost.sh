#!/bin/bash

set -e

cd src/boost

cd tools/build/
./bootstrap.sh
./b2 install --prefix=$BUILDDIR/boost.build

PATH=$PATH:$BUILDDIR/boost.build/bin
cd ../../
echo "using gcc : mingw : $TARGET-g++ ;" >user-config.jam
b2 --user-config=./user-config.jam --with-system --build-dir=$PWD/build-boost --prefix=$BUILDDIR/boost \
    link=static runtime-link=static toolset=gcc-mingw target-os=windows \
    variant=release threading=multi address-model=32 install || true
b2 --clean release
