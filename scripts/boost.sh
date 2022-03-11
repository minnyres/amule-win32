#!/usr/bin/bash

set -e

export BUILDDIR=$PWD/build-$TARGET

cd src
7z x boost_1_78_0.7z
cd boost_1_78_0/

cd tools/build/
./bootstrap.sh
./b2 install --prefix=$BUILDDIR/boost.build

export PATH=$PATH:$BUILDDIR/boost.build/bin
cd ../../
echo "using gcc : mingw : $TARGET-g++ ;"  > user-config.jam
b2 --user-config=./user-config.jam --with-system --build-dir=$PWD/build-boost --prefix=$BUILDDIR/boost \
    link=static runtime-link=static toolset=gcc-mingw target-os=windows \
    variant=release threading=multi address-model=32 install || true
cd ..
rm -rf boost_1_78_0/